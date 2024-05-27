import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmailPassword(String email, String password, String name, String idempotencyKey) async {
  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = result.user;

    if (user != null) {
      await _firestore.runTransaction((transaction) async {
        DocumentReference userRef = _firestore.collection('users').doc(user.uid);
        DocumentReference idempotencyRef = _firestore.collection('idempotencyKeys').doc(idempotencyKey);
        DocumentSnapshot idempotencySnapshot = await transaction.get(idempotencyRef);

        if (!idempotencySnapshot.exists) {
          transaction.set(userRef, {
            'name': name,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          });

          CollectionReference cartRef = userRef.collection('cart');
          transaction.set(cartRef.doc(), {});

          transaction.set(idempotencyRef, {
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          throw Exception('Idempotency key already exists');
        }
      });
    }
    return user;
  } catch (e) {
    print('Error: $e');
    return null;
  }
}


  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return user;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
