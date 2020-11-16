import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:charaben_app/common/recipe.dart';

class RecipeDetailModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  Recipe recipe;


  RecipeDetailModel(Recipe this.recipe) {
    endLoading();
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
