import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskify/SRC/WEB/MODEL/authenticatiion.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? _userFromFirebaseUser(User? user) {
    return user != null ? AppUser(uid: user.uid, email: user.email) : null;
  }

  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Authenticate the user with Firebase Authentication
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check the user's admin role in Firestore after authentication
      bool isAdmin = await _checkAdminRole(email);
      if (!isAdmin) {
        await _auth.signOut();  // Sign out the user if they are not an admin
        return AuthResult(errorMessage: "Unauthorized: You are not an admin");
      }

      return AuthResult(user: _userFromFirebaseUser(result.user));
    } catch (e) {
      // Return the exception message to the UI
      return AuthResult(errorMessage: e.toString());
    }
  }

  Future<bool> _checkAdminRole(String email) async {
    try {
      // Get the document with the email as the document ID
      DocumentSnapshot doc = await _firestore.collection('User_Role').doc(email).get();

      // Check if the document exists and if the role field is "admin"
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        return data?['role'] == 'admin';
      }
      return false;
    } catch (e) {
      // Handle potential errors
      print("Error checking admin role: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AppUser?> getCurrentUser() async {
    User? user = _auth.currentUser;
    return _userFromFirebaseUser(user);
  }
}

class AuthResult {
  final AppUser? user;
  final String? errorMessage;

  AuthResult({this.user, this.errorMessage});
}
