import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> likePost(String id,bool isLiked) async {
  if (_currentUser == null) return;

  try {
    DocumentReference postRef = _db.collection('products').doc(id);
    DocumentSnapshot postSnapshot = await postRef.get();

    if (postSnapshot.exists) {
      List<dynamic> likedBy = postSnapshot['likedby'] ?? [];

      // Check if the current user has already liked the post
      if (!likedBy.contains(_currentUser.uid)||!isLiked) {
        likedBy.add(_currentUser.uid);

        // Update the post with the new like count and likedBy list
        await postRef.update({
          'likes': FieldValue.increment(1),
          'likedby': likedBy,
        });

        print("Post liked successfully.");
      } else {
        print('else');
        likedBy.remove(_currentUser.uid);
        await postRef.update({
          'likes': FieldValue.increment(-1),
          'likedby': likedBy,
        });
      }
    } else {
      print("Post does not exist.");
    }
  } catch (e) {
    print("Error liking post: $e");
  }
}


  Future<bool> hasLikedPost(String postId) async {
    if (_currentUser == null) return false;

    DocumentSnapshot postSnapshot = await _db.collection('posts').doc(postId).get();

    if (postSnapshot.exists) {
      List<dynamic> likedBy = postSnapshot['likedBy'] ?? [];
      return likedBy.contains(_currentUser!.uid);
    }
    return false;
  }
}
