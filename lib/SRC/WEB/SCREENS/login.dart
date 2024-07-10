import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/SCREENS/admin_panel.dart';
import 'package:taskify/THEME/theme.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // Key to identify the form

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customDarkGrey,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: customBgGrey,
            borderRadius: BorderRadius.circular(10.0),
          ),
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Admin Panel Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            customLightGrey, // Background color for text fields
                        labelText: 'Username',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: customAqua),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: customAqua),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            customLightGrey, // Background color for text fields
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: customAqua),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: customAqua),
                        ),
                      ),
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, // Make button take the full width
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AdminPanel()),
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(customAqua),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(color: customDarkGrey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
