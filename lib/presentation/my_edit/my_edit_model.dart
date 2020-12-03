import 'dart:io';

import 'package:charaben_app/common/convert_error_message.dart';
import 'package:charaben_app/common/storage_path.dart';
import 'package:charaben_app/common/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class MyEditModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  File imageFile;
  bool isUploading = false;
  UserData user;
  String userStoragePath;

  MyEditModel(this.user) {
    fetchStragePath();
  }

  Future getUser() async {
    startLoading();
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot _doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (_doc.exists) {
        user = UserData.doc(_doc);
      }
    }
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

    // アイコン画像（W: 200, H:200 @2x）
    this.imageFile = await FlutterNativeImage.compressImage(
      _croppedImageFile.path,
      targetWidth: 200,
      targetHeight: 200,
      );
    notifyListeners();
  }

  // Firestore に画像をアップロードする
  Future<String> updateImage() async {
    FirebaseStorage _storage = FirebaseStorage.instance;
    StorageTaskSnapshot _snapshot = await _storage
        .ref()
        .child('users/' + user.userId)
        .putFile(this.imageFile)
        .onComplete;
  }

  void clearImage() {
    this.imageFile = null;
    notifyListeners();
  }

  void logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('${e.code}: $e');
      throw (convertErrorMessage(e.code));
    }
  }

  Future fetchStragePath() async {
    this.userStoragePath = UsersStoragePath();
    endLoading();
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
