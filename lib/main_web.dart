import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/SCREENS/login.dart';
import 'package:taskify/SRC/WEB/SCREENS/welcome.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({super.key});

  @override
  _WebHomePageState createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return WelcomeScreen();
    return LoginScreen();
    // return const AdminPanel();
  }
}


