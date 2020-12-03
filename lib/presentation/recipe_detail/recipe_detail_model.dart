import 'package:charaben_app/common/likes.dart';
import 'package:charaben_app/common/storage_path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:charaben_app/common/recipe.dart';

import '../../main.dart';

class RecipeDetailModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<Likes> likes;
  Recipe recipe;
  bool isMyLike = false;
  bool isLoading = true;
  User user;

  String userStoragePath = '';
  String imageStoragePath = '';
  String errorMessage = '';


  RecipeDetailModel(Recipe this.recipe) {
    startLoading();
    fetchStragePath();
    fetchLikes();
    fetchUser();
    endLoading();
  }

  Future fetchStragePath() async {
    this.userStoragePath = UsersStoragePath();
    this.imageStoragePath = ImagesStoragePath();
    endLoading();
    notifyListeners();
  }

  Future fetchLikes() async {
    startLoading();
    try {
      User user = FirebaseAuth.instance.currentUser;
      final targetId = recipe.documentId;
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('charaben/${targetId}/likes')
          .get();
      likes = snapshot.docs.map((doc) => Likes.doc(doc)).toList ();
      final myLike = likes.singleWhere((like) => like.id == user.uid, orElse: () => null);
      isMyLike = myLike != null;
    } catch(e) {
      print(e.toString());
      errorMessage = 'エラーが発生しました\n前のページに戻ってもう一度やり直してください';
    }
    endLoading();
    notifyListeners();
  }

  Future fetchUser() async {
    try {
      user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    } catch (e) {
      //throw (e.toString());
    }
    notifyListeners();
  }

  Future fetchRecipe() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('recipes').doc(recipe.documentId).get();
    this.recipe = Recipe(doc);
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
