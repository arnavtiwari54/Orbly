import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();

  // CREATE POST — works on web and mobile
  Future<String> createPost({
    XFile? imageXFile,
    File? imageFile,
    required String caption,
    required UserModel currentUser,
  }) async {
    try {
      String postId = _uuid.v4();
      String imageBase64 = '';

      // On web, use XFile. On mobile, use File
      if (kIsWeb && imageXFile != null) {
        imageBase64 = await _storageService.convertXFileToBase64(imageXFile);
      } else if (imageFile != null) {
        imageBase64 = await _storageService.convertImageToBase64(imageFile);
      }

      if (imageBase64.isEmpty) {
        return 'Failed to process image';
      }

      PostModel newPost = PostModel(
        postId: postId,
        uid: currentUser.uid,
        username: currentUser.username,
        userProfilePicBase64: currentUser.profilePicBase64,
        imageBase64: imageBase64,
        caption: caption,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('posts').doc(postId).set(newPost.toMap());

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update({'postsCount': FieldValue.increment(1)});

      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  // GET ALL POSTS
  Stream<List<PostModel>> getAllPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList());
  }

  // GET USER POSTS
  Stream<List<PostModel>> getUserPosts(String uid) {
    return _firestore
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList());
  }
}
