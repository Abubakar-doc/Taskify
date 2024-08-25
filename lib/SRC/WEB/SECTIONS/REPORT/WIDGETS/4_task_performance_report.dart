import 'package:flutter/material.dart';

class TaskPerformanceReportWidget extends StatelessWidget {
  const TaskPerformanceReportWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Performance Report',
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