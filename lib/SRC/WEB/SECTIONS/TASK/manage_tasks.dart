import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';

import 'WIDGETS/1_create_tasks _widget.dart';
import 'WIDGETS/2_View_Edit_Search_tasks_widget.dart';

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
          ],
        ),
      ),
    );
  }
}
