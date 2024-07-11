import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class Utils {
  int millisecond = 300;

  void toastmsg(dynamic error, BuildContext context) {
    showToast(
      error,
      context: context,
      position:
          StyledToastPosition.top, // Show toast at the center of the screen
      duration: const Duration(seconds: 5), // Adjust the duration here
      borderRadius: BorderRadius.circular(8.0),
      backgroundColor: Colors.red,
      textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
      animation: StyledToastAnimation.fade,
      reverseAnimation: StyledToastAnimation.fade,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
  }

  void greentoastmsg(dynamic msg, BuildContext context) {
    showToast(
      msg,
      context: context,
      position:
          StyledToastPosition.top, // Show toast at the center of the screen
      duration: const Duration(seconds: 5), // Adjust the duration here
      borderRadius: BorderRadius.circular(8.0),
      backgroundColor: Colors.green.shade600,
      textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
      animation: StyledToastAnimation.fade,
      reverseAnimation: StyledToastAnimation.fade,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
  }


}
