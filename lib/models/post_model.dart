import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String uid;
  final String username;
  final String userProfilePicBase64;
  final String imageBase64;
  final String caption;
  final DateTime createdAt;

  PostModel({
    required this.postId,
    required this.uid,
    required this.username,
    required this.userProfilePicBase64,
    required this.imageBase64,
    required this.caption,
    required this.createdAt,
  });

  // Convert Firestore data → PostModel
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'] ?? '',
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      userProfilePicBase64: map['userProfilePicBase64'] ?? '',
      imageBase64: map['imageBase64'] ?? '',
      caption: map['caption'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert PostModel → Firestore data
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'uid': uid,
      'username': username,
      'userProfilePicBase64': userProfilePicBase64,
      'imageBase64': imageBase64,
      'caption': caption,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
