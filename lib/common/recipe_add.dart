import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeAdd {
  RecipeAdd({
    this.author,
    this.name,
    this.caption = '',
    this.ingredients,
    this.reference = '',
    this.tokenMap,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, String> author;
  String name = '';
  String caption = '';
  String ingredients = '';
  String reference = '';
  Map<String, bool> tokenMap;
  Timestamp createdAt;
  Timestamp updatedAt;
}