import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/SECTIONS/DEPARTMENT/widgets/1_create_department%20_widget.dart';
import 'package:taskify/SRC/WEB/SECTIONS/DEPARTMENT/widgets/2_View_Edit_Search_Departments_widget.dart';
import 'package:taskify/SRC/WEB/SECTIONS/DEPARTMENT/widgets/3_add_members_in_department_Widget.dart';
import 'package:taskify/SRC/WEB/WIDGETS/small_widgets.dart';

class ManageDepartment extends StatefulWidget {
  const ManageDepartment({super.key});

  @override
  State<ManageDepartment> createState() => _ManageDepartmentState();
}

class _ManageDepartmentState extends State<ManageDepartment> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CreateDepartmentWidget(),
            const divider(),
            ViewEditSearchDepartmentsWidget(),
            const divider(),
            const AddMembersInDepartmentWidget(),
          ],
        ),
      ),
    );
  }
}
