import 'package:charaben_app/common/recipe.dart';
import 'package:charaben_app/common/storage_path.dart';
import 'package:charaben_app/common/user.dart';
import 'package:charaben_app/common/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class HomeModel extends ChangeNotifier {
  List charabenList = [];
  bool canLoadMoreList = true;
  QueryDocumentSnapshot lastVisible;
  int loadLimit = 10;
  String userStoragePath;
  String imageStoragePath;
  List likes;
  UserState userState;
  User user;
  UserData userData;
  DateTime updateTime;
  bool isLoading = false;
  bool guideToLogin = false;
  String errorMessage;
  HomeModel(this.userState) {
    startLoading();
    fetchStragePath();
    fetchUser();
    fetchCharabenList();
    updateTime = DateTime.now();
    endLoading();
  }

  Future fetchStragePath() async {
    this.userStoragePath = UsersStoragePath();
    this.imageStoragePath = ImagesStoragePath();
    endLoading();
    notifyListeners();
  }

  Future fetchUser() async {
    user = await FirebaseAuth.instance.currentUser;
    if (user == null) {
      likes = [];
    } else {
      final doc = await FirebaseFirestore.instance.collection ('users')
          .doc(user.uid)
          .get();
      this.userData = UserData.doc(doc);
      final likesDoc = await FirebaseFirestore.instance.collection('users/${user.uid}/likes')
          .get();
      likes=
      likesDoc == null ? [] : likesDoc.docs.map ((doc) => doc['id']).toList();
    }
    endLoading();
    notifyListeners();
  }

  Future fetchCharabenList() async {
    try {
      startLoading ();
      if (!canLoadMoreList) {
        return;
      }
      var query = await FirebaseFirestore.instance.collection('charaben')
          .orderBy ('updatedAt', descending: true)
          .limit (this.loadLimit);
      if (lastVisible != null) {
        query = query.startAfterDocument(this.lastVisible);
      }
      final snapshot = await query.get();
      final docs = snapshot.docs;
      List<Recipe> _loadList = await docs.map ((doc) => Recipe(doc)).toList();
      canLoadMoreList = _loadList.length == this.loadLimit;
      lastVisible = docs.last;
      charabenList.addAll(_loadList);
    } catch(e){
      print(e.toString());
      errorMessage = 'エラーが発生しました。';
    }
    endLoading();
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

  void changeLike(index) async {
    startLoading();
    try {
    User user = await FirebaseAuth.instance.currentUser;
    if (user == null || user.uid == null) {
      guideToLogin = true;
    } else {
        final targetId=this.charabenList[index].documentId;
        WriteBatch _batch=FirebaseFirestore.instance.batch ();

        DocumentReference _usersCollection=FirebaseFirestore.instance
            .collection ('users/${user.uid}/likes')
            .doc (targetId);
        DocumentReference _charabenCollection=FirebaseFirestore.instance
            .collection('charaben')
            .doc(targetId);

        DocumentReference _charabenLikeCollection=FirebaseFirestore.instance
            .collection ('charaben/${targetId}/likes')
            .doc (user.uid);

        // いいねしてる時
        if (this.likes.contains (targetId)) {
          // userから削除
          _batch.delete (_usersCollection);
          // キャラ弁から削除
          await _batch.delete (_charabenLikeCollection);
          _batch.commit ();

          this.likes.remove (targetId);

          // いいねしてない時
        } else {
          // userに登録
          _batch.set (_usersCollection,
                          {
                            'id': targetId,
                            'createdAt': FieldValue.serverTimestamp (),
                          }
                      );
          // キャラ弁に登録
          _batch.set(_charabenLikeCollection,
                                {
                                  'userId': user.uid,
                                  'name': this.userData.name,
                                  'createdAt': FieldValue.serverTimestamp (),
                                }
                            );

          _batch.commit ();
          this.likes.add (targetId);
        }
      }
    } catch(e) {
      endLoading();
      print(e.toString());
      throw ('エラーが発生しました');
    }
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