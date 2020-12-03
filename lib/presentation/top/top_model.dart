import 'package:charaben_app/common/recipe.dart';
import 'package:charaben_app/common/storage_path.dart';
import 'package:charaben_app/common/text_process.dart';
import 'package:charaben_app/common/user_state.dart';
import 'package:charaben_app/common/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TopModel extends ChangeNotifier {
  UserState userState;
  UserData user;
  String message;
  String detailMessage;
  bool canLoadMoreList = true;
  bool canLoadMoreMyList = true;
  QueryDocumentSnapshot lastVisible;
  QueryDocumentSnapshot myLastVisible;

  List<Recipe> charabenList;
  List<Recipe> serchedCharabenList;
  List<Recipe> myCharabenList;
  int serchedCharabenListLength = 0;
  bool isLoading = false;
  // ページインデックス保存用
  int currentIndex = 0;
  double hederHeight = 60.0;
  int loadLimit = 20;
  String errorText = '';
  String userStoragePath;
  String imageStoragePath;
  DateTime updateTime = DateTime.now();

  TopModel(){
    fetchUser();
    fetchMyCharabenList();
    fetchStragePath();
    this.serchedCharabenList = [];
  }

  Future fetchUser() async {
    try {
      final auth = FirebaseAuth.instance.currentUser;

      if (auth == null) {
        userState = UserState.signedOut;
        message = 'ログインする';
        detailMessage = 'ログイン後に、いいねや投稿できるようになります。';
      } else {
        // ユーザー登録確認
        DocumentSnapshot _mySnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.uid)
            .get();

        if (_mySnap.exists) {
          userState = UserState.registered;
          user = UserData.doc(_mySnap);
          message = 'ユーザー情報を修正する';
          detailMessage = '';
        } else {
          userState = UserState.signedIn;
          message = 'ユーザー情報を登録する';
          detailMessage = '下のボタンよりユーザ-ネームを登録して会員登録完了してください。';
        }
      }
      notifyListeners();
    } catch (e) {
      //throw (e.toString());
    }
  }

  Future fetchMyCharabenList() async {
    if (userState != UserState.registered) {
      myCharabenList = [];
    } else {
      final snapshot=await FirebaseFirestore.instance
          .collection ('charaben')
          .where ('author.id', isEqualTo: user.userId)
          .startAfterDocument(this.myLastVisible)
          .limit(this.loadLimit)
          .get ();
      final docs = snapshot.docs;
      List<Recipe> loadMyList = docs.map ((doc) => Recipe (doc)).toList ();
      canLoadMoreMyList = loadMyList.length < loadLimit;
      myLastVisible = docs.last;
      myCharabenList.addAll(loadMyList);
    }
    notifyListeners();
  }

  Future changeScreen(index) async {
    this.currentIndex = index;
    switch (currentIndex) {
      case 0 : hederHeight = 63.0;
      break;
      case 1 : hederHeight = 90.0;
      break;
      case 2 : hederHeight = 280;
      break;
    }
    notifyListeners();
  }

  Future fetchStragePath() async {
    this.userStoragePath = UsersStoragePath();
    this.imageStoragePath = ImagesStoragePath();
    notifyListeners();
  }

  void changeMySearchWords(text) {
    if (text.length == 1) {
      this.errorText = '検索ワードは2文字以上で入力して下さい。';
    } else if (text.length > 50) {
      this.errorText = '検索ワードは50文字以内で入力して下さい。';
    } else {
      this.errorText = '';
    }
    notifyListeners();
  }

  Future filterMyRecipe(String input) async {
    startLoading();
    /// 検索文字数が2文字に満たない場合は検索を行わず、検索結果のリストを空にする
    if (input.length < 2) {
      this.serchedCharabenList = [];
      return;
    }

    /// 検索用フィールドに入力された文字列の前処理
    List<String> _words = input.trim().split(' ');

    /// 文字列のリストを渡して、bi-gram を実行
    List tokens = tokenize(_words);

    /// クエリの生成（bi-gram の結果のトークンマップを where 句に反映）
    Query _query =
    FirebaseFirestore.instance.collection('charaben');
    tokens.forEach((word) {
      _query =
          _query.where('tokenMap.$word', isEqualTo: true).limit(this.loadLimit);
    });

    QuerySnapshot _snap = await _query.get();

    /// 絞り込んだレシピが1件以上あるか確認
    if (_snap.docs.length == 0) {
      this.serchedCharabenList = [];
    } else {
      serchedCharabenList = await _snap.docs.map ((doc) => Recipe (doc)).toList ();
    }
    endLoading();
    notifyListeners();
  }

  void refreshUpdateTime() {
    this.updateTime = DateTime.now();
    notifyListeners();
  }

  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  endLoading() {
    isLoading = false;
    notifyListeners();
  }
}