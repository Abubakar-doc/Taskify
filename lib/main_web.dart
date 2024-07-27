import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/MODEL/authenticatiion.dart';
import 'package:taskify/SRC/WEB/SCREENS/HOME/admin_panel.dart';
import 'package:taskify/SRC/WEB/SCREENS/WELCOME/welcome.dart';
import 'package:taskify/SRC/WEB/SERVICES/authentication.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({super.key});

  @override
  _WebHomePageState createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  late Future<AppUser?> _userFuture;

  @override
  void initState() {
    super.initState();
    AuthService authService = AuthService();
    _userFuture = authService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return const AdminPanel();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}