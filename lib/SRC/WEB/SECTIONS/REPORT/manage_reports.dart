import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/SECTIONS/REPORT/WIDGETS/1_task_status_report.dart';
import 'package:taskify/SRC/WEB/SECTIONS/REPORT/WIDGETS/2_member_activity_report.dart';
import 'package:taskify/SRC/WEB/SECTIONS/REPORT/WIDGETS/3_department_performance_report.dart';
import 'package:taskify/SRC/WEB/SECTIONS/REPORT/WIDGETS/4_task_performance_report.dart';
import 'package:taskify/SRC/WEB/SECTIONS/REPORT/WIDGETS/5_pending_underApproval_task_report.dart';
import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';

class ManageReports extends StatelessWidget {
  const ManageReports({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskStatusReportWidget(),
            divider(),
            MemberActivityReportWidget(),
            divider(),
            DepertmentPerformanceReportWidget(),
            divider(),
            TaskPerformanceReportWidget(),
            divider(),
            PendingAndUnderApprovalTaskReportWidget()
          ],
        ),
      ),
    );
  }
}
