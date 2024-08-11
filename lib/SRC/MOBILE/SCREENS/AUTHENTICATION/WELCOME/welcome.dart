import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:taskify/SRC/MOBILE/SCREENS/AUTHENTICATION/LOGIN/login.dart';
import 'package:taskify/SRC/MOBILE/SCREENS/AUTHENTICATION/REGISTER/registration.dart';
import 'package:taskify/SRC/MOBILE/UTILS/mobile_utils.dart';
import 'package:taskify/THEME/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customDarkGrey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                SimpleIcons.task,
                color: customAqua,
                size: 100,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to Taskify',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Manage your tasks efficiently and effectively',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: customAqua,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  MobUtils()
                      .pushSlideTransition(context, const RegistrationScreen());
                },
                child: const Text(
                  'Join Taskify',
                  style: TextStyle(
                    color: customDarkGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already a member?',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      MobUtils()
                          .pushSlideTransition(context, const LoginScreen());
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: customAqua,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    theme: darkTheme,
    home: const WelcomeScreen(),
  ));
}
