import 'package:flutter/material.dart';

class WebUtils {
  OverlayEntry? _overlayEntry;

  void showErrorToast(String message, BuildContext context) {
    _showToast(message, Colors.red, Icons.error, context);
  }

  void showInfoToast(String message, BuildContext context) {
    _showToast(message, Colors.blue, Icons.info, context);
  }

  void showSuccessToast(String message, BuildContext context) {
    _showToast(message, Colors.green, Icons.check_circle, context);
  }

  void _showToast(
      String message, Color color, IconData icon, BuildContext context) {
    _removeToast();

    // Create a GlobalKey for the container to access its size
    GlobalKey containerKey = GlobalKey();

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          bottom: 20.0,
          right: 20.0,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 200),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0.0, (1 - value) * 20),
                  child: AnimatedContainer(
                    key: containerKey,
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    width: 300.0,
                    child: Row(
                      children: <Widget>[
                        Icon(icon, color: Colors.white),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            _removeToast();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Schedule removal after 4 seconds
    Future.delayed(const Duration(seconds: 5), () {
      _removeToast();
    });
  }

  void _removeToast() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void showCustomSnackBar(BuildContext context, String message, Color backgroundColor, Color textColor, {Duration duration = const Duration(seconds: 5)}) {
    final snackBar = SnackBar(
      content: Expanded(
        child: Text(
          message,
          style: TextStyle(color: textColor),
        ),
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating, // Add this line
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void SuccessSnackBar(BuildContext context, String message, {Duration duration = const Duration(seconds: 5)}) {
    showCustomSnackBar(context, message, Colors.green, Colors.grey.shade900, duration: duration);
  }

  void ErrorSnackBar(BuildContext context, String message, {Duration duration = const Duration(seconds: 5)}) {
    showCustomSnackBar(context, message, Colors.red.shade400, Colors.white, duration: duration);
  }

  void InfoSnackBar(BuildContext context, String message, {Duration duration = const Duration(seconds: 5)}) {
    showCustomSnackBar(context, message, Colors.grey, Colors.grey.shade900, duration: duration);
  }




}
