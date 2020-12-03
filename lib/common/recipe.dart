import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  Recipe(QueryDocumentSnapshot doc) {
    this.documentId = doc.id;
    this.name = doc.data()['name'];
    this.author = doc.data()['author'];
    this.caption = doc.data()['caption'];
    this.reference = doc.data()['reference'];
    this.tokenMap = doc.data()['tokenMap'];
    this.createdAt = doc.data()['createdAt'];
    this.updatedAt = doc.data()['updatedAt'];
  }

  String documentId;
  Map author;
  String name;
  String caption;
  String ingredients = '';
  String reference = '';
  Map tokenMap;
  Timestamp createdAt;
  Timestamp updatedAt;
}