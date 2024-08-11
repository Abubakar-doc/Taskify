import 'package:flutter/material.dart';
import 'package:taskify/THEME/theme.dart';

class WaitForApprovalScreen extends StatelessWidget {
  const WaitForApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wait for Approval'),
        backgroundColor: customDarkGrey,
      ),
      backgroundColor: customDarkGrey,
      body: Center(
        child: Text(
          'Thank you for registering! Please wait for the approval.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}