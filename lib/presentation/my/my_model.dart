import 'package:charaben_app/common/recipe.dart';
import 'package:charaben_app/common/storage_path.dart';
import 'package:charaben_app/common/user.dart';
import 'package:charaben_app/common/user_state.dart';
import 'package:charaben_app/presentation/top/top_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class MyModel extends ChangeNotifier {
  List charabenList = [];
  bool canLoadMoreList = true;
  QueryDocumentSnapshot lastVisible;
  int loadLimit = 10;
  UserState userState;
  UserData user;
  String storagePath;
  String errorMessage;
  DateTime updateTime;
  bool isLoading = false;
  String userStoragePath;
  String imageStoragePath;

  MyModel(this.userState) {
    startLoading();
    fetchUser();
    fetchCharabenList();
    fetchStragePath();
    updateTime = DateTime.now();
    endLoading();
  }

  // ユーザを取得する
  Future fetchUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        userState = UserState.signedOut;
        charabenList = [];
        return;
      }
      final userId = currentUser.uid;
      /// ユーザー登録確認
      DocumentSnapshot _mySnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (_mySnap.exists) {
        userState = UserState.registered;
        await fetchStragePath();
        user = UserData.doc(_mySnap);
        fetchCharabenList();
      } else {
        userState = UserState.signedIn;
      }

    } catch (e) {
      throw (e.toString());
    }
  }

  Future fetchCharabenList() async {
    try {
      if (userState != UserState.registered) {
        charabenList = [];
      } else if (!canLoadMoreList) {
        return;
      } else {
         var query = await FirebaseFirestore.instance
            .collection ('charaben')
            .where ('author.id', isEqualTo: user.userId)
            .orderBy('updatedAt', descending: true)
            .limit(this.loadLimit);
        if (lastVisible != null) {
          query = query.startAfterDocument(this.lastVisible);
        }
        final snapshot = await query.get();
        final docs = snapshot.docs;
        List<Recipe> loadMyList = docs.map ((doc) => Recipe (doc)).toList ();
        canLoadMoreList = loadMyList.length < loadLimit;
        lastVisible = docs.last;
        charabenList.addAll(loadMyList);
      }
    } catch(e){
      print(e.toString());
      errorMessage = 'エラーが発生しました。';
    }
    notifyListeners();
  }

  Future checkIfNeedUpdate(DateTime datetime) async {
    this.updateTime = datetime;
    if (charabenList != null &&
        charabenList.isNotEmpty &&
        charabenList.toList().first.updatedAt.toDate().isBefore(datetime)) {
      this.charabenList = [];
      this.lastVisible = null;
      this.canLoadMoreList = true;
      await fetchCharabenList();
    }
  }

  Future fetchStragePath() async {
    this.userStoragePath = UsersStoragePath();
    this.imageStoragePath = ImagesStoragePath();
    endLoading();
    notifyListeners();
  }

  void startLoading() {
    this.isLoading = false;
    notifyListeners();
  }

  void endLoading() {
    this.isLoading = true;
    notifyListeners();
  }
}