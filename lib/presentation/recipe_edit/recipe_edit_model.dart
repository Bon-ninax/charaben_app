import 'dart:io';

import 'package:charaben_app/common/recipe.dart';
import 'package:charaben_app/common/recipe_add.dart';
import 'package:charaben_app/common/storage_path.dart';
import 'package:charaben_app/common/text_process.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../main.dart';

class RecipeEditModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Recipe recipe;
  List<Recipe> recipes = [];
  File imageFile;
  File thumbnailImageFile;
  bool isUploading = false;
  String errorCaption = '';
  String errorReference = '';
  bool isCaptionValid = false;
  bool isReferenceValid = true;
  String _generatedId;
  String storagePath;

  RecipeEditModel(this.recipe) {
    fetchStragePath();
  }

  Future fetchStragePath() async {
    //this.userStoragePath = UsersStoragePath();
    this.storagePath = ImagesStoragePath();
    endLoading();
    notifyListeners();
  }

  Future showImagePicker() async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }

    File pickedImage = File(pickedFile.path);

    if (pickedImage == null) {
      return;
    }
    // 画像をアスペクト比 1:1 で 切り抜く
    File _croppedImageFile = await ImageCropper.cropImage(
      sourcePath: pickedImage.path,
      maxHeight: 200,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 10,
      iosUiSettings: IOSUiSettings(
        title: '編集',
        ),
      );

    // レシピ画像（W: 400, H:300 @2x）
    this.imageFile = await FlutterNativeImage.compressImage(
      _croppedImageFile.path,
      targetWidth: 400,
      targetHeight: 400,
      );

    // サムネイル用画像（W: 200, H: 30 @2x）
    this.thumbnailImageFile = await FlutterNativeImage.compressImage(
      _croppedImageFile.path,
      targetWidth: 200,
      targetHeight: 200,
      );

    notifyListeners();
  }

  Future addRecipeToFirebase() async {
    String uid = _auth.currentUser.uid;

    // tokenMap を作成するための入力となる文字列のリスト
    /// レシピ名とレシピの全文を検索対象にする場合
    List _preTokenizedList = [];
    _preTokenizedList.add(recipe.name);
    _preTokenizedList.add(recipe.caption);

    List _tokenizedList = tokenize(_preTokenizedList);
    recipe.tokenMap =
        Map.fromIterable(_tokenizedList, key: (e) => e, value: (_) => true);
    print(recipe.tokenMap);

    try {
      DocumentSnapshot _doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (_doc.data() == null) {
        throw('登録に失敗しました。');
      }

      await FirebaseFirestore.instance
          .collection ('charaben')
          .doc(recipe.documentId)
          .update(
            {
              'name': recipe.name,
              'caption': recipe.caption,
              'reference': recipe.reference,
              'tokenMap': recipe.tokenMap,
              'updatedAt': FieldValue.serverTimestamp (),
            },
            ).then((_) async => {
              if (this.imageFile != null) {
                // 画像が変更されている場合のみ実行する
                _uploadImage ()
              }
            });
    } catch(e) {
      throw('登録に失敗しました。');
    }
    notifyListeners();
  }

  // Firestore に画像をアップロードする
  Future<String> _uploadImage() async {
    FirebaseStorage _storage = FirebaseStorage.instance;
    StorageTaskSnapshot _snapshot = await _storage
        .ref()
        .child('images/' + recipe.documentId)
        .putFile(this.imageFile)
        .onComplete;
  }

  // Firestore にサムネイル用画像をアップロードする
  Future<String> _uploadThumbnail() async {
    String _fileName = "thumbnail_" +
        DateTime.now().toString() +
        "_" +
        _auth.currentUser.uid +
        '.jpg';
    FirebaseStorage _storage = FirebaseStorage.instance;
    StorageTaskSnapshot _snapshot = await _storage
        .ref()
        .child('thumbnails/' + _generatedId)
        .putFile(this.thumbnailImageFile)
        .onComplete;
  }

  Future deleteRecipe() async {
    try {
      await FirebaseFirestore.instance
          .collection ('charaben')
          .doc (recipe.documentId)
          .delete ().then ((_) async =>
      {
        FirebaseStorage.instance
            .ref ()
            .child ('images/' + recipe.documentId)
            .delete ()
      });
    } catch(e) {
      print(e.toString());
      throw('削除に失敗しました。');
    }
  }


  void changeRecipeCaption(text) {
    this.recipe.caption = text;
    if (text.isEmpty) {
      this.isCaptionValid = false;
      this.errorCaption = 'レシピの内容を入力して下さい。';
    } else if (text.length > 200) {
      this.isCaptionValid = false;
      this.errorCaption = '200文字以内で入力して下さい。';
    } else {
      this.isCaptionValid = true;
      this.errorCaption = '';
    }
    notifyListeners();
  }

  void changeRecipeReference(text) {
    this.recipe.reference = text;
    if (text.length > 100) {
      this.isReferenceValid = false;
      this.errorReference = '100文字以内で入力して下さい。';
    } else {
      this.isReferenceValid = true;
      this.errorReference = '';
    }
    notifyListeners();
  }

  void startLoading() {
    this.isUploading = true;
    notifyListeners();
  }

  void endLoading() {
    this.isUploading = false;
    notifyListeners();
  }
}
