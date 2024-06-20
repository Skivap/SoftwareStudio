import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailPassword(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        return _auth.currentUser;
      }
    } catch (e, stackTrace) {
      print('Error in signUpWithEmailPassword: $e');
      print('Stack trace: $stackTrace');
    }
    return null;
  }

  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return user;
    } catch (e, stackTrace) {
      print('Error in signInWithEmailPassword: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
