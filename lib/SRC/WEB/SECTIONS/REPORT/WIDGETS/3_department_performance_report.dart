import 'package:flutter/material.dart';

class DepertmentPerformanceReportWidget extends StatelessWidget {
  const DepertmentPerformanceReportWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Department Performance Report',
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