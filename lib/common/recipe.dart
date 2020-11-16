
import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  Recipe(QueryDocumentSnapshot doc) {
    this.id = doc.data()['id'];
    this.caption = doc.data()['caption'];
    this.imageURL = doc.data()['imageURL'];
    this.thumbnailURL = doc.data()['thumbnailURL'];
    this.imageName = doc.data()['imageName'];
    this.thumbnailName = doc.data()['thumbnailName'];
    this.athouer = doc.data()['athouer'];
    this.likes = doc.data()['likes'].map((doc) => Likes(doc)).toList();
    this.views = doc.data()['views'];
    this.tokenMap = doc.data()['tokenMap'];
    this.createAt = doc.data()['createAt'];
    this.updateAt = doc.data()['updateAt'];
    final Timestamp timestamp = doc.data()['createAt'];
  }
  String id;
  String caption;
  String imageURL;
  String thumbnailURL;
  String imageName;
  String thumbnailName;
  Map athouer;
  Map likes;//いいね人数
  int views;//再生回数
  Map tokenMap;
  DateTime createAt;
  DateTime updateAt;
}

class Likes {
  Likes(data) {
    userId = data.likes.userId;
    thumbnailURL = data.likes.thumbnailURL;
  }
  String userId;
  String thumbnailURL;
}