import 'package:charaben_app/common/convert_error_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupModel extends ChangeNotifier {
  String mail = '';
  String password = '';
  String confirm = '';
  String errorMail = '';
  String errorPassword = '';
  String errorConfirm = '';
  bool isLoading = false;
  bool isMailValid = false;
  bool isPasswordValid = false;
  bool isConfirmValid = false;
  User user;

  Future shinUp() async {
    try {
      // アカウント作成
      UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: mail, password: password);
      user = result.user;
      FirebaseAuth.instance.currentUser.sendEmailVerification();
    } catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      throw (convertErrorMessage(e.code));
    }
  }

  /// ログイン（ユーザー登録直後に叩く）
  Future login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: this.mail,
        password: this.password,
        );
    } catch (e) {
      print('${e.code}: $e');
      throw (convertErrorMessage(e.code));
    }
  }

  void changeMail(text) {
    this.mail = text.trim();
    if (text.length == 0) {
      this.isMailValid = false;
      this.errorMail = 'メールアドレスを入力して下さい。';
    } else if (!text.contains('@') || !text.contains('.')) {
      isMailValid=false;
      this.errorMail = '正しいフォーマットを入力してください 例) xxxx@yyy.com';
    } else {
      this.isMailValid = true;
      this.errorMail = '';
    }
    notifyListeners();
  }

  void changePassword(text) {
    this.password = text;
    if (text.length == 0) {
      isPasswordValid = false;
      this.errorPassword = 'パスワードを入力して下さい。';
    } else if (text.length < 8 || text.length > 20) {
      isPasswordValid = false;
      this.errorPassword = 'パスワードは8文字以上20文字以内です。';
    } else {
      isPasswordValid = true;
      this.errorPassword = '';
    }
    notifyListeners();
  }

  void changeConfirm(text) {
    this.confirm = text;
    if (text.length == 0) {
      isConfirmValid = false;
      this.errorConfirm = 'パスワードを再入力して下さい。';
    } else if (text.length < 8 || text.length > 20) {
      isConfirmValid = false;
      this.errorConfirm = 'パスワードは8文字以上20文字以内です。';
    } else if (this.password != this.confirm) {
      isConfirmValid = false;
      this.errorConfirm = 'パスワードが一致しません。';
    } else {
      isConfirmValid = true;
      this.errorConfirm = '';
    }
    notifyListeners();
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
