import 'package:charaben_app/common/convert_error_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginModel extends ChangeNotifier {
  String mail = '';
  String password = '';
  String sendMail = '';
  String confirm = '';
  String errorMail = '';
  String errorPassword = '';
  String errorConfirm = '';
  String errorSendMail = '';
  bool isLoading = false;
  bool isMailValid = false;
  bool isPasswordValid = false;
  bool isSendMailValid = false;
  bool isVerified;
  String existsError;
  User user;

  /// ログイン
  Future login() async {
    try {
      isVerified = FirebaseAuth.instance.currentUser.emailVerified;

      if (!isVerified) {
        throw ('メールアドレスが認証されていません。\nご登録のメールアドレスに届いた認証メールをご確認ください。');
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: this.mail,
        password: this.password,
        );
    } catch (e) {
      throw (e.toString());
    }
  }

  Future sendPasswordResetEmail() async {
    try {
      final _auth = FirebaseAuth.instance;
      final providers = await _auth.fetchSignInMethodsForEmail(sendMail);
      if (!providers.contains('password')) {
        existsError =  '入力されたメールアドレスは登録されていません';
        return;
      }
      await _auth.sendPasswordResetEmail(email: sendMail);
      return;
    } catch (error) {
      print(error.code);
      return '送信に失敗しました。';
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

  void changeSendMail(text) {
    this.sendMail = text.trim();
    if (text.length == 0) {
      this.isMailValid = false;
      this.errorSendMail = 'メールアドレスを入力して下さい。';
    } else if (!text.contains('@') || !text.contains('.')) {
      isSendMailValid=false;
      this.errorSendMail = '正しいフォーマットを入力してください 例) xxxx@yyy.com';
    } else {
      this.isSendMailValid = true;
      this.errorSendMail = '';
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
