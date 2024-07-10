import 'package:flutter/material.dart';

class MobileHomePage extends StatelessWidget {
  const MobileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Home Page'),
      ),
      body: const Center(
        child: Text('This is the mobile layout'),
      ),
    );
  }
}