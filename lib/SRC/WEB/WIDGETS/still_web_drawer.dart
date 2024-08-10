import 'package:flutter/material.dart';
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
  final GlobalKey manageUserRegistrations;
  final GlobalKey membersAndDepartmentKey;

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
    required this.manageUserRegistrations,
    required this.membersAndDepartmentKey,
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
                  manageUserRegistrations: manageUserRegistrations,
                  membersAndDepartmentKey: membersAndDepartmentKey),
            ),
            buildExpansionTile(
              context,
              title: 'Manage Departments',
              icon: Icons.business,
              indices: [1, 2, 3, 4],
              children: [
                buildChildTile(
                  context,
                  title: 'Create Department',
                  icon: Icons.add,
                  index: 1,
                  widget: ManageDepartment(
                      createDepartmentKey: createDepartmentKey,
                      viewEditSearchDepartmentsKey:
                          viewEditSearchDepartmentsKey,
                      addMembersInDepartmentKey: addMembersInDepartmentKey,
                      membersAndDepartmentKey: membersAndDepartmentKey),
                ),
                buildChildTile(
                  context,
                  title: 'View Departments',
                  icon: Icons.remove_red_eye,
                  index: 2,
                  widget: ManageDepartment(
                      createDepartmentKey: createDepartmentKey,
                      viewEditSearchDepartmentsKey:
                          viewEditSearchDepartmentsKey,
                      addMembersInDepartmentKey: addMembersInDepartmentKey,
                      membersAndDepartmentKey: membersAndDepartmentKey),
                ),
                buildChildTile(
                  context,
                  title: 'Add Members in Department',
                  icon: Icons.add_box_outlined,
                  index: 3,
                  widget: ManageDepartment(
                      createDepartmentKey: createDepartmentKey,
                      viewEditSearchDepartmentsKey:
                          viewEditSearchDepartmentsKey,
                      addMembersInDepartmentKey: addMembersInDepartmentKey,
                      membersAndDepartmentKey: membersAndDepartmentKey),
                ),
                buildChildTile(
                  context,
                  title: 'Departments and Members',
                  icon: Icons.remove_red_eye,
                  index: 4,
                  widget: ManageDepartment(
                      createDepartmentKey: createDepartmentKey,
                      viewEditSearchDepartmentsKey:
                          viewEditSearchDepartmentsKey,
                      addMembersInDepartmentKey: addMembersInDepartmentKey,
                      membersAndDepartmentKey: membersAndDepartmentKey),
                ),
              ],
            ),
            buildExpansionTile(
              context,
              title: 'Manage Members',
              icon: Icons.person,
              indices: [5],
              children: [
                buildChildTile(
                  context,
                  title: 'Manage User Registrations',
                  icon: Icons.check,
                  index: 5,
                  widget: ManageMember(
                    manageUserRegistrations: manageUserRegistrations,
                  ),
                ),
              ],
            ),
            buildExpansionTile(
              context,
              title: 'Manage Tasks',
              icon: Icons.task,
              indices: [6, 7, 8, 9, 10],
              children: [
                buildChildTile(
                  context,
                  title: 'Create Tasks',
                  icon: Icons.add,
                  index: 6,
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
                  index: 7,
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
                  index: 8,
                  widget: ManageTasks(
                    createTasksKey: createTasksKey,
                    viewEditSearchTasksKey: viewEditSearchTasksKey,
                    assignTasksToMembersKey: assignTasksToMembersKey,
                    evaluateTasksKey: evaluateTasksKey,
                  ),
                ),
                // buildChildTile(
                //   context,
                //   title: 'View Assigned Tasks to Members',
                //   icon: Icons.add_box_outlined,
                //   index: 9,
                //   widget: AssignTasksToMembersWidget(
                //     key: assignTasksToMembersKey,
                //   ),
                // ),
                buildChildTile(
                  context,
                  title: 'Evaluate Tasks',
                  icon: Icons.check,
                  index: 10,
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
              index: 11,
              widget: const ManageReports(),
            ),
            buildTile(
              context,
              title: 'Settings',
              icon: Icons.settings,
              index: 12,
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
      leading:
          Icon(icon, color: selectedIndex == index ? customAqua : Colors.grey),
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
