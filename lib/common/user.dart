import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  UserData._(
      this.userId,
      this.introduction,
      this.name,
      this.image,
      this.createdAt,
      this.updateAt,
      );

  factory UserData.doc(DocumentSnapshot doc) {
    final data = doc.data();
    return UserData._(
      doc.id,
      data['introduction'],
      data['name'],
      data['image'],
      data['createdAt'],
      data['updateAt'],
      );
  }

  String userId;
  String introduction;
  String name;
  bool image;
  Timestamp createdAt;
  Timestamp updateAt;
}