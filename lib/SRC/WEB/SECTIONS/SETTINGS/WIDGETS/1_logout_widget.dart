import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/SCREENS/AUTHENTICATION/login.dart';
import 'package:taskify/SRC/WEB/SERVICES/authentication.dart';
import 'package:taskify/SRC/WEB/WIDGETS/hoverable_stretched_aqua_button.dart';
import 'package:taskify/THEME/theme.dart';

class LogoutWidget extends StatelessWidget {
  const LogoutWidget({super.key});

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          backgroundColor: customLightGrey, // Customize as needed
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: customAqua), // Match your theme color
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _logOut(context); // Proceed with logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400, // Customize as needed
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logOut(BuildContext context) async {
    AuthService authService = AuthService();
    try {
      await authService.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        HoverableElevatedButton(
          text: 'Log Out',
          onPressed: () => _showLogoutConfirmationDialog(context), // Show confirmation dialog
        ),
      ],
    );
  }
}
