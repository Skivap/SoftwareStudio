import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> likePost(String id, bool isLiked) async {
    if (_currentUser == null) return;

    try {
      await _db.runTransaction((transaction) async {
        DocumentReference postRef = _db.collection('products').doc(id);
        DocumentSnapshot postSnapshot = await transaction.get(postRef);

        if (postSnapshot.exists) {
          Map<String, dynamic>? postData = postSnapshot.data() as Map<String, dynamic>?;
          List<dynamic> likedBy = postData?['likedBy'] ?? [];

          if (!likedBy.contains(_currentUser!.uid)) {
            // Add the user to the likedBy list and increment the likes count
            transaction.update(postRef, {
              'likes': FieldValue.increment(1),
              'likedBy': FieldValue.arrayUnion([_currentUser!.uid]),
            });
          } else {
            // Remove the user from the likedBy list and decrement the likes count
            transaction.update(postRef, {
              'likes': FieldValue.increment(-1),
              'likedBy': FieldValue.arrayRemove([_currentUser!.uid]),
            });
          }
        } else {
          print("Post does not exist.");
        }
      });
    } catch (e) {
      print("Error liking post: $e");
    }
  }

  Future<bool> hasLikedPost(String postId) async {
    if (_currentUser == null) return false;

    try {
      DocumentSnapshot postSnapshot = await _db.collection('products').doc(postId).get();

      if (postSnapshot.exists) {
        Map<String, dynamic>? postData = postSnapshot.data() as Map<String, dynamic>?;
        List<dynamic> likedBy = postData?['likedBy'] ?? [];
        return likedBy.contains(_currentUser!.uid);
      }
      return false;
    } catch (e) {
      print("Error checking if post is liked: $e");
      return false;
    }
  }
}
