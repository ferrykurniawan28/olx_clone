import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/model.dart';

class DatabaseFirestore {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<bool> CreateUser(String email, String username) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        "id": _auth.currentUser!.uid,
        'username': username,
        "email": email,
      });
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return true;
    }
  }

  Future<bool> uploadImage(String url) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({"image": url});
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return true;
    }
  }

  Future<void> toggleFavorites(String postId) async {
    try {
      DocumentReference userDocRef = _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('favorites')
          .doc(_auth.currentUser!.uid);

      DocumentSnapshot userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        await userDocRef.set({
          'watchlist': [postId],
        });
      } else {
        List<String> favoriteList =
            List<String>.from(userDoc.get('watchlist') as List<dynamic>? ?? []);

        if (favoriteList.contains(postId)) {
          favoriteList.remove(postId);
        } else {
          favoriteList.add(postId);
        }

        await userDocRef.update({
          'watchlist': favoriteList,
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> addToFavorites(String postId) async {
    if (postId != null) {
      try {
        DocumentReference userDocRef = _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('favorites')
            .doc(_auth.currentUser!.uid);

        DocumentSnapshot userDoc = await userDocRef.get();

        if (!userDoc.exists) {
          await userDocRef.set({
            'watchlist': [postId],
          });
        } else {
          List<String> favoriteList = List<String>.from(
              userDoc.get('watchlist') as List<dynamic>? ?? []);

          if (!favoriteList.contains(postId)) {
            favoriteList.add(postId);
          }

          await userDocRef.update({
            'watchlist': favoriteList,
          });
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Future<void> addPostItem(PostItem postItem) async {
    try {
      // Uuid uuid = Uuid();
      // String postId = uuid.v4();
      await _firestore.collection('posts').add({
        'postID': postItem.postId,
        'username': postItem.username,
        'email': postItem.email,
        'title': postItem.title,
        'price': postItem.price,
        'posteddate': postItem.posteddate,
        'description': postItem.description,
        'address': postItem.address,
        'phoneNumber': postItem.phoneNumber,
        'imageUrl': postItem.imageUrl,
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
