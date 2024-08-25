import 'package:flutter/material.dart';

class PendingAndUnderApprovalTaskReportWidget extends StatelessWidget {
  const PendingAndUnderApprovalTaskReportWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pending and Under Approval Task Report',
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