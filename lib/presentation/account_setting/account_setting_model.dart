import 'dart:io';
import 'package:charaben_app/common/convert_error_message.dart';
import 'package:charaben_app/common/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class AccountSettingModel extends ChangeNotifier {
  String name = '';
  String errorName = '';
  bool isLoading = false;
  bool isNameValid = false;
  String existsError;
  User user;
  UserState userState;

  /// usersに登録
  Future register() async {
    try {
      http.Response response = await http.get('https://firebasestorage.googleapis.com/v0/b/dev-charaben-app.appspot.com/o/users%2F%E4%BA%BA%E7%89%A9%E3%82%A2%E3%82%A4%E3%82%B3%E3%83%B3.jpeg?alt=media&token=33350637-e282-4565-affd-69de5f699304');

      final file = File('${(await getTemporaryDirectory()).path}img_photo_default.png');
      await file.writeAsBytes(response.bodyBytes);
      final userId=FirebaseAuth.instance.currentUser.uid;

      if (userId != null) {
        /// ユーザー登録確認
        final snap = FirebaseStorage.instance.ref()
            .child('users/' + userId)
            .putFile(file)
            .onComplete
            .then((_) async => {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .set(
              {
                'id': userId,
                'name': this.name,
                'introduction': '',
                'createdAt': FieldValue.serverTimestamp (),
                'updatedAt': FieldValue.serverTimestamp (),
              })
            });
      } else {
        throw ('登録に失敗しました。\n時間をあけて再度実行してください。');
      }
    } catch (e) {
      print(e.toString ());
      throw ('登録に失敗しました。\n時間をあけて再度実行してください。');
    }
  }

  void changeName(text) async {
    this.name = text.trim();

    if (text.length == 0) {
      this.isNameValid = false;
      this.errorName = 'ユーザーネームを入力して下さい。';
    } else if (RegExp(r'^[._]$').hasMatch(name)) {
      isNameValid=false;
      this.errorName = '頭文字は半角小文字英字で入力してください。';
    } else if (RegExp(r'^[^0-9a-z._]*$').hasMatch(name)) {
      isNameValid=false;
      this.errorName = '半角小文字英数字、記号(_.)で入力してください。';
    } else if (name.length > 15) {
      isNameValid=false;
      this.errorName = '15文字以下で入力してください。';
    } else {
      this.isNameValid = true;
      this.errorName = '';
      // あとでテスト
      await checkUsedName();
    }
    notifyListeners();
  }

  Future checkUsedName() async {
    try {
      QuerySnapshot registeredUser = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: this.name)
          .get();

      if(registeredUser.docs.length > 0) {
        isNameValid=false;
        this.errorName = '入力されたユーザーネームは使用されています。';
      }
    } catch (e) {
      throw (e.toString());
    }
  }

  void startLoading() {
    this.isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    this.isLoading = false;
    notifyListeners();
  }
}
