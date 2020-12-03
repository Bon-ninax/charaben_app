import 'package:charaben_app/common/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IntroductionEditModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String introduction;
  bool isUploading = false;
  String errorIntroduction = '';
  String errorMessage = '';
  bool isIntroductionValid = false;
  bool isReferenceValid = true;
  UserData user;

  IntroductionEditModel(this.user) {
    this.introduction = user.introduction;
  }

  Future updateIntroduction() {
    try {
      FirebaseFirestore.instance.collection ('users')
          .doc (user.userId)
          .update (
          { 'introduction': this.introduction }
          );
    } catch(e) {
      this.errorMessage = '登録に失敗しました。';
      throw (errorMessage);
    }

  }

  void changeIntroduction(text) {
    if (text.isEmpty) {
      this.isIntroductionValid = false;
      this.errorIntroduction = '自己紹介を入力して下さい。';
    } else if (text.length > 50) {
      this.isIntroductionValid = false;
      this.errorIntroduction = '50文字以内で入力して下さい。';
    } else {
      this.isIntroductionValid = true;
      this.errorIntroduction = '';
      this.introduction = text;
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
