import 'package:cloud_firestore/cloud_firestore.dart';

class Likes {
  Likes._(
      this.id,
      this.name,
      this.createdAt
      );

  factory Likes.doc(DocumentSnapshot doc) {
    final data = doc.data();
    return Likes._(
      data['userId'],
      data['name'],
      data['createdAt']
      );
  }

  String id;
  String name;
  Timestamp createdAt;
}