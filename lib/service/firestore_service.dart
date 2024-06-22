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
          List<dynamic> likedBy = postData?.containsKey('likedBy') == true
              ? postData!['likedBy']
              : [];

          if (likedBy.isEmpty || !likedBy.contains(_currentUser!.uid)) {
            likedBy.add(_currentUser!.uid);
            transaction.update(postRef, {
              'likes': FieldValue.increment(1),
              'likedBy': likedBy,
            });
          } else {
            likedBy.remove(_currentUser!.uid);
            transaction.update(postRef, {
              'likes': FieldValue.increment(-1),
              'likedBy': likedBy,
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
      DocumentSnapshot postSnapshot = await _db.collection('posts').doc(postId).get();

      if (postSnapshot.exists) {
        Map<String, dynamic>? postData = postSnapshot.data() as Map<String, dynamic>?;
        List<dynamic> likedBy = postData?.containsKey('likedBy') == true
            ? postData!['likedBy']
            : [];
        return likedBy.contains(_currentUser!.uid);
      }
      return false;
    } catch (e) {
      print("Error checking if post is liked: $e");
      return false;
    }
  }
}
