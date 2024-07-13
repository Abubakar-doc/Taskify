import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:taskify/SRC/WEB/SCREENS/login.dart';
import 'package:taskify/THEME/theme.dart';

class WelcomeScreen extends StatelessWidget {
  final bool _isHovered = false;

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customDarkGrey,
      body: Center(
        child: Row(
          children: [
            // Left side with the image
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(
                    'assets/pyramid.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Right side with content
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      SimpleIcons.task,
                      color: customAqua,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Taskify',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Admin Panel',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isHovered
                            ? customAqua.withOpacity(0.8)
                            : customAqua,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 5),
                      ),
                      child: Text(
                        'Proceed',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold,color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
