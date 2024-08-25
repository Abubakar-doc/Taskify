import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class MobUtils {
  int millisecond = 300;

  static void showSuccessToast(BuildContext context, String message) {
    showToast(
      message,
      context: context,
      position: StyledToastPosition.top,
      animation: StyledToastAnimation.slideFromTop,
      backgroundColor: Colors.green,
      textStyle: const TextStyle(color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }

  static void showFailureToast(BuildContext context, String message) {
    showToast(
      message,
      context: context,
      position: StyledToastPosition.top,
      animation: StyledToastAnimation.slideFromTop,
      backgroundColor: Colors.red,
      textStyle: const TextStyle(color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }

  static void showInfoToast(BuildContext context, String message) {
    showToast(
      message,
      context: context,
      position: StyledToastPosition.top,
      animation: StyledToastAnimation.slideFromTop,
      backgroundColor: Colors.grey,
      textStyle: const TextStyle(color: Colors.black),
      duration: const Duration(seconds: 4),
    );
  }

  void pushSlideTransition(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: millisecond),
      ),
    );
  }

  void pushReplaceSlideTransition(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: millisecond),
      ),
    );
  }

  void pushAndRemoveUntilSlideTransition(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: millisecond),
      ),
      (route) => false, // This will remove all previous routes
    );
  }
}
