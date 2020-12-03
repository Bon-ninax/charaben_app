import 'package:charaben_app/common/recipe.dart';
import 'package:charaben_app/common/storage_path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchModel extends ChangeNotifier {
  String userStoragePath;
  String imageStoragePath;

  SearchModel(){
    getCharabenList();
    fetchStragePath();
  }
  Future getCharabenList() async {
    final snapshot = await FirebaseFirestore.instance.collection('charaben').get();
    final docs = snapshot.docs;
    charabenList = docs.map((doc) => Recipe(doc)).toList();
    notifyListeners();
  }

  List<Recipe> charabenList;
  // ページインデックス保存用
  int currentIndex = 0;

  Future changeScreen(index) async {
    this.currentIndex = index;
    notifyListeners();
  }

  Future fetchStragePath() async {
    this.userStoragePath = UsersStoragePath();
    this.imageStoragePath = ImagesStoragePath();
    notifyListeners();
  }
}