import 'dart:io';

import 'package:charaben_app/common/recipe.dart';
import 'package:charaben_app/common/recipe_add.dart';
import 'package:charaben_app/common/text_process.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class RecipeAddModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  RecipeAdd recipeAdd = RecipeAdd();
  List<Recipe> recipes = [];
  File imageFile;
  File thumbnailImageFile;
  bool isUploading = false;
  String errorName = '';
  String errorCaption = '';
  String errorReference = '';
  bool isNameValid = false;
  bool isCaptionValid = false;
  bool isReferenceValid = true;
  String _generatedId;

  Future fetchRecipeAdd(context) async {
    QuerySnapshot docs =
    await FirebaseFirestore.instance.collection('recipes').get();
    List<Recipe> recipes = docs.docs.map((doc) => Recipe(doc)).toList();
    this.recipes = recipes;
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

    // レシピ画像（W: 400, H:400 @2x）
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
    String name;
    // 画像が変更されている場合のみ実行する
    if (this.imageFile != null) {
      String dateTime = DateTime.now().toString();
    }

    // tokenMap を作成するための入力となる文字列のリスト
    /// レシピ名とレシピの全文を検索対象にする場合
    List _preTokenizedList = [];
    _preTokenizedList.add(recipeAdd.name);
    _preTokenizedList.add(recipeAdd.caption);

    List _tokenizedList = tokenize(_preTokenizedList);
    recipeAdd.tokenMap =
        Map.fromIterable(_tokenizedList, key: (e) => e, value: (_) => true);
    print(recipeAdd.tokenMap);

    try {
      DocumentSnapshot _doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (_doc.data() == null) {
        throw('');
      }

      name=_doc.data()['name'];

      await FirebaseFirestore.instance
          .collection ('charaben')
          .add (
        {
          'author': {
            'id': uid,
            'name': name
          },
          'name': recipeAdd.name,
          'caption': recipeAdd.caption,
          'reference': recipeAdd.reference,
          'tokenMap': recipeAdd.tokenMap,
          'createdAt': FieldValue.serverTimestamp (),
          'updatedAt': FieldValue.serverTimestamp (),
        },
        ).then((docRef) async => {_generatedId = docRef.id})
          .then((_) async => {
            _uploadImage()
          });
    } catch(e) {
      return;
    }

    notifyListeners();
  }

  // Firestore に画像をアップロードする
  Future<String> _uploadImage() async {
    FirebaseStorage _storage = FirebaseStorage.instance;
    StorageTaskSnapshot _snapshot = await _storage
        .ref()
        .child('images/' + _generatedId)
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

  void changeRecipeName(text) {
    this.recipeAdd.name = text;
    if (text.isEmpty) {
      this.isNameValid = false;
      this.errorName = 'レシピ名を入力して下さい。';
    } else if (text.length > 30) {
      this.isNameValid = false;
      this.errorName = '30文字以内で入力して下さい。';
    } else {
      this.isNameValid = true;
      this.errorName = '';
    }
    notifyListeners();
  }

  void changeRecipeCaption(text) {
    this.recipeAdd.caption = text;
    if (text.isEmpty) {
      this.isCaptionValid = false;
      this.errorCaption = 'レシピの内容を入力して下さい。';
    } else if (text.length > 100) {
      this.isCaptionValid = false;
      this.errorCaption = '200文字以内で入力して下さい。';
    } else {
      this.isCaptionValid = true;
      this.errorCaption = '';
    }
    notifyListeners();
  }

  void changeRecipeReference(text) {
    this.recipeAdd.reference = text;
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
