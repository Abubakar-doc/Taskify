import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskify/SRC/COMMON/MODEL/Member.dart';
import 'package:taskify/SRC/COMMON/SERVICES/member.dart';
import 'package:taskify/SRC/MOBILE/SCREENS/AUTHENTICATION/REGISTER/registraion_status.dart';
import 'package:taskify/SRC/MOBILE/SCREENS/AUTHENTICATION/WELCOME/welcome.dart';
import 'package:taskify/SRC/MOBILE/SCREENS/HOME/home.dart';
import 'package:taskify/SRC/MOBILE/UTILS/mobile_utils.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MemberService _memberService = MemberService();

  Future<void> signUp(
      BuildContext context, String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        DateTime now = DateTime.now();

        UserModel userModel = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          status: 'pending',
          createdAt: now,
          updatedAt: now,
        );

        await _firestore
            .collection('Users')
            .doc(user.uid)
            .set(userModel.toMap());

        await _checkUserStatusAndNavigate(context, userModel);
      }
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage =
                'This email is already in use. Please try logging in.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Email/password accounts are not enabled.';
            break;
          case 'weak-password':
            errorMessage = 'The password is too weak.';
            break;
          default:
            errorMessage = 'An unknown error occurred.';
            break;
        }
      } else {
        errorMessage = 'An unknown error occurred.';
      }
      MobUtils.showFailureToast(context, errorMessage);
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } catch (e) {
      MobUtils.showFailureToast(context, 'Error logging out: $e');
    }
  }

  Future<void> isSignedIn(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1), () {});

    User? user = _auth.currentUser;

    if (user == null) {
      MobUtils().pushAndRemoveUntilSlideTransition(context, const WelcomeScreen());
      return;
    }

    if (user.email != null) {
      UserModel? userModel = await _memberService.getUserByEmail(user.email!);
      await _checkUserStatusAndNavigate(context, userModel);
    }
  }

  Future<void> signIn(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        UserModel? userModel = await _memberService.getUserByEmail(user.email!);

        if (userModel != null) {
          await _checkUserStatusAndNavigate(context, userModel);
        } else {
          MobUtils.showFailureToast(context, 'User data not found. Please try again.');
        }
      } else {
        MobUtils.showFailureToast(context, 'Sign in failed. Please try again.');
      }
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email. Please sign up first.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'user-disabled':
            errorMessage = 'This user account has been disabled.';
            break;
          default:
            errorMessage = 'An unknown error occurred. Please try again.';
            break;
        }
      } else {
        errorMessage = 'Sign in failed: $e';
      }
      MobUtils.showFailureToast(context, errorMessage);
    }
  }

  Future<void> _checkUserStatusAndNavigate(
      BuildContext context, UserModel? userModel) async {

    String? name = userModel?.name;

    if (userModel != null) {
      if (userModel.status == 'pending') {
        MobUtils().pushAndRemoveUntilSlideTransition(context, const StatusScreen(
          title: 'Registration in Progress',
          message:
          'Thank you for registering! Your application is under review. Please wait for approval.',
          imagePath: 'assets/pending.png',
          width: 400,
          height: 400,
        ));
        MobUtils.showInfoToast(context, 'Registration under progress');
      } else if (userModel.status == 'Rejected') {
        MobUtils().pushAndRemoveUntilSlideTransition(context, StatusScreen(
          title: 'Registration Rejected',
          message:
          'We appreciate your patience. Unfortunately, your registration was not approved.',
          imagePath: 'assets/rejected.png',
          width: 400,
          height: 400,
          buttonText: 'Apply again',
          onButtonPressed: () {
            logout(context);
          },
        ));
        MobUtils.showInfoToast(context, 'Application rejected');
      } else if (userModel.status == 'Approved') {
        if (userModel.departmentId == "" || userModel.departmentId == null) {
          MobUtils().pushAndRemoveUntilSlideTransition(context, const StatusScreen(
            title: 'No Department Assigned',
            message:
            'It looks like no department has been allocated to you yet. We apologize for the inconvenience.',
            imagePath: 'assets/noDepartment.png',
            width: 400,
            height: 400,
          ));
          MobUtils.showInfoToast(context, ' Missing department reported, assistance will be provided shortly.');
        } else {
          MobUtils().pushAndRemoveUntilSlideTransition(context, HomeScreen(userModel: userModel));
          // MobUtils.showSuccessToast(context, 'Welcome $name');
        }
      } else {
        MobUtils().pushAndRemoveUntilSlideTransition(context, const WelcomeScreen());
      }
    } else {
      MobUtils().pushAndRemoveUntilSlideTransition(context, const WelcomeScreen());
    }
  }
}
