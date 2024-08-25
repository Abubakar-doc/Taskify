import 'package:flutter/material.dart';
import 'package:taskify/THEME/theme.dart';

class StatusScreen extends StatelessWidget {
  final String title;
  final String message;
  final String imagePath;
  final double width;
  final double height;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const StatusScreen({
    super.key,
    required this.title,
    required this.message,
    required this.imagePath,
    required this.width,
    required this.height,
    this.buttonText, // Optional button text
    this.onButtonPressed, // Optional callback for button press
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: customDarkGrey,
      ),
      backgroundColor: customDarkGrey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: width,
            height: height,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              message,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70),
              textAlign: TextAlign.justify,
            ),
          ),
          if (buttonText != null && onButtonPressed != null) // Check if button is required
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customAqua,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onButtonPressed,
                  child: Text(
                    buttonText!,
                    style: const TextStyle(
                      color: customDarkGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
