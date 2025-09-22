import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register a new user
  Future<bool> signup(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      print('Error during signup: ${e.message}');
      return false;
    }
  }

  // Login existing user
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      print('Error during login: ${e.message}');
      return false;
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
