import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:taskify/SRC/MOBILE/SERVICES/authentication.dart';
import 'package:taskify/SRC/MOBILE/UTILS/mobile_utils.dart';
import 'package:taskify/THEME/theme.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

final AuthService _authService = AuthService();
bool _isLoading = false;

class _SettingViewState extends State<SettingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: customDarkGrey,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: customAqua,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Add your onPressed code here!
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: customAqua,
                  padding: const EdgeInsets.symmetric(
                      vertical: 18), // Increased padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12), // Slightly larger border radius
                  ),
                ),
                onPressed: _isLoading
                    ? null
                    : () {
                        _showLogoutConfirmationDialog(context);
                      },
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Log out',
                        style: TextStyle(
                          color: customDarkGrey,
                          fontSize: 18, // Slightly larger font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: customDarkGrey,
          title: const Text(
            'Confirm Logout',
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: customAqua),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop(); // Dismiss the dialog
                      _logout();
                    },
              child: const Text(
                'Log out',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.logout(context);
    } catch (e) {
      MobUtils.showFailureToast(context, 'Error logging out: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
