import 'package:flutter/material.dart';

class MemberActivityReportWidget extends StatelessWidget {
  const MemberActivityReportWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Member Activity Report',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}