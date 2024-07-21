import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';

import 'WIDGETS/1_create_tasks _widget.dart';
import 'WIDGETS/2_view_Edit_Search_tasks_widget.dart';
import 'WIDGETS/3_assign_task_to_members_Widget.dart';
import 'WIDGETS/4_evaluate_tasks.dart';

class ManageTasks extends StatefulWidget {
  const ManageTasks({super.key});

  @override
  State<ManageTasks> createState() => _ManageTasksState();
}

class _ManageTasksState extends State<ManageTasks> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: const SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CreateTasksWidget(),
            divider(),
            ViewEditSearchTasksWidget(),
            divider(),
            AssignTasksToMembersWidget(),
            divider(),
            EvaluateTasksWidget()
          ],
        ),
      ),
    );
  }
}
