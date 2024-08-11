import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskify/SRC/COMMON/MODEL/member.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> registerWithEmailAndPassword(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        DateTime now = DateTime.now();
        UserModel userModel = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          createdAt: now,
          updatedAt: now,
        );
        await _firestore.collection('Users').doc(user.uid).set(userModel.toMap());
        return userModel;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
