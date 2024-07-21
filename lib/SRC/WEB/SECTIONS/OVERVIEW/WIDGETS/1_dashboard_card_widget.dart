import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/WIDGETS/hoverable_stretched_aqua_button.dart';
import 'package:taskify/THEME/theme.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onPressed;

  const DashboardCard({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: customLightGrey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: HoverableElevatedButton(
                text: buttonText,
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}