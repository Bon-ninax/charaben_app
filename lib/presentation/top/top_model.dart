import 'package:charaben_app/common/recipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TopModel extends ChangeNotifier {
  TopModel(){
    getCharabenList();
  }
  Future getCharabenList() async {
    final snapshot = await FirebaseFirestore.instance.collection('charaben').get();
    final docs = snapshot.docs;
    charabenList = docs.map((doc) => Recipe(doc)).toList();
    notifyListeners();
  }

  List<Recipe> charabenList;
  // ページインデックス保存用
  int screen = 0;

  Future changeScreen(index) async {
    this.screen = index;
    notifyListeners();
  }
}