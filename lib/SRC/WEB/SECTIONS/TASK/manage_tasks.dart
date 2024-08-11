// import 'package:flutter/material.dart';
// import 'package:taskify/SRC/WEB/SECTIONS/TASK/WIDGETS/3_assign_task_to_members_Widget.dart';
// import 'package:taskify/SRC/WEB/SECTIONS/TASK/WIDGETS/4_assigned_tasks_widget.dart';
// import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';
// import 'WIDGETS/1_create_tasks _widget.dart';
// import 'WIDGETS/2_view_Edit_Search_tasks_widget.dart';
// import 'WIDGETS/5_evaluate_tasks.dart';
//
// class ManageTasks extends StatefulWidget {
//   final GlobalKey createTasksKey;
//   final GlobalKey viewEditSearchTasksKey;
//   final GlobalKey assignTasksToMembersKey;
//   final GlobalKey evaluateTasksKey;
//
//   const ManageTasks({
//     super.key,
//     required this.createTasksKey,
//     required this.viewEditSearchTasksKey,
//     required this.assignTasksToMembersKey,
//     required this.evaluateTasksKey,
//   });
//
//   @override
//   State<ManageTasks> createState() => _ManageTasksState();
// }
//
// class _ManageTasksState extends State<ManageTasks> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.topLeft,
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CreateTasksWidget(key: widget.createTasksKey),
//             const divider(),
//             ViewEditSearchTasksWidget(key: widget.viewEditSearchTasksKey),
//             const divider(),
//             AssignTasksToMembersWidget(key: widget.assignTasksToMembersKey),
//             const divider(),
//             const AssignedTasksWidget(),
//             const divider(),
//             EvaluateTasksWidget(key: widget.evaluateTasksKey),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/SECTIONS/TASK/WIDGETS/3_assign_task_to_members_Widget.dart';
import 'package:taskify/SRC/WEB/SECTIONS/TASK/WIDGETS/4_assigned_tasks_widget.dart';
import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';
import 'WIDGETS/1_create_tasks _widget.dart';
import 'WIDGETS/2_view_Edit_Search_tasks_widget.dart';
import 'WIDGETS/5_evaluate_tasks.dart';

class ManageTasks extends StatefulWidget {
  final GlobalKey createTasksKey;
  final GlobalKey viewEditSearchTasksKey;
  final GlobalKey assignTasksToMembersKey;
  final GlobalKey evaluateTasksKey;
  final GlobalKey assignedTasksKey;

  const ManageTasks({
    super.key,
    required this.createTasksKey,
    required this.viewEditSearchTasksKey,
    required this.assignTasksToMembersKey,
    required this.evaluateTasksKey,
    required this.assignedTasksKey,
  });

  @override
  State<ManageTasks> createState() => _ManageTasksState();
}

class _ManageTasksState extends State<ManageTasks> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CreateTasksWidget(key: widget.createTasksKey),
            const divider(),
            ViewEditSearchTasksWidget(key: widget.viewEditSearchTasksKey),
            const divider(),
            AssignTasksToMembersWidget(key: widget.assignTasksToMembersKey),
            const divider(),
            AssignedTasksWidget(key: widget.assignedTasksKey),
            const divider(),
            EvaluateTasksWidget(key: widget.evaluateTasksKey),
          ],
        ),
      ),
    );
  }
}
