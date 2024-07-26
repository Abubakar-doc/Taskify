import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/MODEL/authenticatiion.dart';
import 'package:taskify/SRC/WEB/SCREENS/admin_panel.dart';
import 'package:taskify/SRC/WEB/SERVICES/authentication.dart';
import 'package:taskify/SRC/WEB/UTILS/web_utils.dart';
import 'package:taskify/THEME/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

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
                'Taskify Admin Panel Login',
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
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: customLightGrey,
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: customAqua),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: customAqua),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        String pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
                        RegExp regex = RegExp(pattern);
                        if (!regex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: customLightGrey,
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
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              AppUser? user = await _authService.signInWithEmailAndPassword(
                                _emailController.text,
                                _passwordController.text,
                              );
                              if (user != null) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AdminPanel(),
                                  ),
                                      (route) => false,
                                );
                                WebUtils().showSuccessToast('Welcome back', context);
                              }
                            } on FirebaseAuthException catch (e) {
                              String errorMessage;
                              switch (e.code) {
                                case 'user-not-found':
                                  errorMessage = 'No user found for that email.';
                                  break;
                                case 'wrong-password':
                                  errorMessage = 'Wrong password provided.';
                                  break;
                                case 'invalid-email':
                                  errorMessage = 'The email address is not valid.';
                                  break;
                                case 'user-disabled':
                                  errorMessage = 'This user has been disabled.';
                                  break;
                                case 'too-many-requests':
                                  errorMessage = 'Too many login attempts. Try again later.';
                                  break;
                                default:
                                  errorMessage = 'Login failed. Please try again.';
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage, style: const TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.red.shade400,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('An error occurred. Please try again.', style: TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.red.shade400,
                                ),
                              );
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(customAqua),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SizedBox(
                            width: 23.0,
                            height: 23.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade800),
                            ),
                          ),
                        )
                            : const Text(
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
