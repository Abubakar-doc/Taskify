import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/SECTIONS/DEPARTMENT/widgets/1_create_department%20_widget.dart';
import 'package:taskify/SRC/WEB/SECTIONS/DEPARTMENT/widgets/2_View_Edit_Search_Departments_widget.dart';
import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';

import 'WIDGETS/3_add_members_in_department_Widget.dart';

class ManageDepartment extends StatefulWidget {
  final GlobalKey createDepartmentKey;
  final GlobalKey viewEditSearchDepartmentsKey;
  final GlobalKey addMembersInDepartmentKey;

  const ManageDepartment({
    super.key,
    required this.createDepartmentKey,
    required this.viewEditSearchDepartmentsKey,
    required this.addMembersInDepartmentKey,
  });

  @override
  State<ManageDepartment> createState() => _ManageDepartmentState();
}

class _ManageDepartmentState extends State<ManageDepartment> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CreateDepartmentWidget(key: widget.createDepartmentKey),
            const divider(),
            ViewEditSearchDepartmentsWidget(key: widget.viewEditSearchDepartmentsKey),
            const divider(),
            AddMembersInDepartmentWidget(key: widget.addMembersInDepartmentKey),
          ],
        ),
      ),
    );
  }
}