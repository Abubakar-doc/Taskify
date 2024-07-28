import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/SECTIONS/DEPARTMENT/WIDGETS/3_add_members_in_department_Widget.dart';
import 'package:taskify/SRC/WEB/SECTIONS/DEPARTMENT/manage_department.dart';
import 'package:taskify/SRC/WEB/SECTIONS/MEMBER/manage_member.dart';
import 'package:taskify/SRC/WEB/SECTIONS/REPORT/manage_reports.dart';
import 'package:taskify/SRC/WEB/SECTIONS/SETTINGS/manage_settings.dart';
import 'package:taskify/SRC/WEB/SECTIONS/TASK/WIDGETS/3_assign_task_to_members_Widget.dart';
import 'package:taskify/SRC/WEB/SECTIONS/TASK/manage_tasks.dart';
import 'package:taskify/SRC/WEB/SECTIONS/OVERVIEW/overview.dart';
import 'package:taskify/THEME/theme.dart';

class DrawerWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int, Widget) onItemTapped;

  // Add keys as parameters
  final GlobalKey createDepartmentKey;
  final GlobalKey viewEditSearchDepartmentsKey;
  final GlobalKey addMembersInDepartmentKey;
  final GlobalKey createTasksKey;
  final GlobalKey viewEditSearchTasksKey;
  final GlobalKey assignTasksToMembersKey;
  final GlobalKey evaluateTasksKey;
  final GlobalKey approveNewUserRegistrationKey;
  final GlobalKey activeMemberKey;
  final GlobalKey rejectedMemberKey;

  const DrawerWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.createDepartmentKey,
    required this.viewEditSearchDepartmentsKey,
    required this.addMembersInDepartmentKey,
    required this.createTasksKey,
    required this.viewEditSearchTasksKey,
    required this.assignTasksToMembersKey,
    required this.evaluateTasksKey,
    required this.approveNewUserRegistrationKey,
    required this.activeMemberKey,
    required this.rejectedMemberKey,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double drawerWidth = screenWidth / 3;
    double maxWidth = 250.0;

    if (drawerWidth > maxWidth) {
      drawerWidth = maxWidth;
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: customLightGrey,
        ),
        width: drawerWidth,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            buildTile(
              context,
              title: 'Overview',
              icon: Icons.dashboard,
              index: 0,
              widget: Overview(
                onItemTapped: onItemTapped,
                createDepartmentKey: createDepartmentKey,
                viewEditSearchDepartmentsKey: viewEditSearchDepartmentsKey,
                addMembersInDepartmentKey: addMembersInDepartmentKey,
                createTasksKey: createTasksKey,
                viewEditSearchTasksKey: viewEditSearchTasksKey,
                assignTasksToMembersKey: assignTasksToMembersKey,
                evaluateTasksKey: evaluateTasksKey,
                approveNewUserRegistrationKey: approveNewUserRegistrationKey,
                activeMemberKey: activeMemberKey,
                rejectedMemberKey: rejectedMemberKey,
              ),
            ),
            buildExpansionTile(
              context,
              title: 'Manage Departments',
              icon: Icons.business,
              indices: [1, 2, 3],
              children: [
                buildChildTile(
                  context,
                  title: 'Create Department',
                  icon: Icons.add,
                  index: 1,
                  widget: ManageDepartment(
                    createDepartmentKey: createDepartmentKey,
                    viewEditSearchDepartmentsKey: viewEditSearchDepartmentsKey,
                    addMembersInDepartmentKey: addMembersInDepartmentKey,
                  ),
                ),
                buildChildTile(
                  context,
                  title: 'View Departments',
                  icon: Icons.remove_red_eye,
                  index: 2,
                  widget: ManageDepartment(
                    createDepartmentKey: createDepartmentKey,
                    viewEditSearchDepartmentsKey: viewEditSearchDepartmentsKey,
                    addMembersInDepartmentKey: addMembersInDepartmentKey,
                  ),
                ),
                buildChildTile(
                  context,
                  title: 'Add Members in Department',
                  icon: Icons.add_box_outlined,
                  index: 3,
                  widget: AddMembersInDepartmentWidget(
                    key: addMembersInDepartmentKey,
                  ),
                ),
              ],
            ),
            buildExpansionTile(
              context,
              title: 'Manage Members',
              icon: Icons.person,
              indices: [4, 5, 6, 7], // Update indices
              children: [
                buildChildTile(
                  context,
                  title: 'Approve New User Registrations',
                  icon: Icons.check,
                  index: 4,
                  widget: ManageMember(
                    approveNewUserRegistrationKey: approveNewUserRegistrationKey,
                    activeMemberKey: activeMemberKey,
                    rejectedMemberKey: rejectedMemberKey,
                  ),
                ),
                buildChildTile(
                  context,
                  title: 'View Active Members',
                  icon: Icons.person,
                  index: 5,
                  widget: ManageMember(
                    approveNewUserRegistrationKey: approveNewUserRegistrationKey,
                    activeMemberKey: activeMemberKey,
                    rejectedMemberKey: rejectedMemberKey,
                  ),
                ),
                buildChildTile(
                  context,
                  title: 'View Rejected Members',
                  icon: Icons.person_off_rounded,
                  index: 6,
                  widget: ManageMember(
                    approveNewUserRegistrationKey: approveNewUserRegistrationKey,
                    activeMemberKey: activeMemberKey,
                    rejectedMemberKey: rejectedMemberKey,
                  ),
                ),
                buildChildTile(
                  context,
                  title: 'View Assigned Tasks to Members',
                  icon: Icons.remove_red_eye,
                  index: 7,
                  widget: ManageMember(
                    approveNewUserRegistrationKey: approveNewUserRegistrationKey,
                    activeMemberKey: activeMemberKey,
                    rejectedMemberKey: rejectedMemberKey,
                  ),
                ),
              ],
            ),
            buildExpansionTile(
              context,
              title: 'Manage Tasks',
              icon: Icons.task,
              indices: [8, 9, 10, 11],
              children: [
                buildChildTile(
                  context,
                  title: 'Create Tasks',
                  icon: Icons.add,
                  index: 8,
                  widget: ManageTasks(
                    createTasksKey: createTasksKey,
                    viewEditSearchTasksKey: viewEditSearchTasksKey,
                    assignTasksToMembersKey: assignTasksToMembersKey,
                    evaluateTasksKey: evaluateTasksKey,
                  ),
                ),
                buildChildTile(
                  context,
                  title: 'View Tasks',
                  icon: Icons.remove_red_eye,
                  index: 9,
                  widget: ManageTasks(
                    createTasksKey: createTasksKey,
                    viewEditSearchTasksKey: viewEditSearchTasksKey,
                    assignTasksToMembersKey: assignTasksToMembersKey,
                    evaluateTasksKey: evaluateTasksKey,
                  ),
                ),
                buildChildTile(
                  context,
                  title: 'Assign Tasks to Members',
                  icon: Icons.add_box_outlined,
                  index: 10,
                  widget: AssignTasksToMembersWidget(
                    key: assignTasksToMembersKey,
                  ),
                ),
                buildChildTile(
                  context,
                  title: 'Evaluate Tasks',
                  icon: Icons.check,
                  index: 11,
                  widget: ManageTasks(
                    createTasksKey: createTasksKey,
                    viewEditSearchTasksKey: viewEditSearchTasksKey,
                    assignTasksToMembersKey: assignTasksToMembersKey,
                    evaluateTasksKey: evaluateTasksKey,
                  ),
                ),
              ],
            ),
            buildTile(
              context,
              title: 'Manage Reports',
              icon: Icons.file_copy_outlined,
              index: 12,
              widget: const ManageReports(),
            ),
            buildTile(
              context,
              title: 'Settings',
              icon: Icons.settings,
              index: 13,
              widget: const Settings(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTile(
      BuildContext context, {
        required String title,
        required IconData icon,
        required int index,
        required Widget widget,
      }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: selectedIndex == index ? customAqua : Colors.grey,
        ),
      ),
      leading: Icon(icon, color: selectedIndex == index ? customAqua : Colors.grey),
      selected: selectedIndex == index,
      onTap: () => onItemTapped(index, widget),
    );
  }

  Widget buildChildTile(
      BuildContext context, {
        required String title,
        required IconData icon,
        required int index,
        required Widget widget,
      }) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, right: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: TextStyle(
            color: selectedIndex == index ? Colors.white : Colors.grey,
            fontSize: selectedIndex == index ? 16 : 14,
          ),
        ),
        leading: Icon(icon,
            color: selectedIndex == index ? Colors.white : Colors.grey,
            size: 20),
        selected: selectedIndex == index,
        onTap: () => onItemTapped(index, widget),
      ),
    );
  }

  Widget buildExpansionTile(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<int> indices,
        required List<Widget> children,
      }) {
    bool isSelected = indices.contains(selectedIndex);
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? customAqua : Colors.grey,
        ),
      ),
      leading: Icon(icon, color: isSelected ? customAqua : Colors.grey),
      iconColor: isSelected ? customAqua : Colors.grey,
      children: children,
    );
  }
}
