import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/SECTIONS/REPORT/manage_reports.dart';
import 'package:taskify/SRC/WEB/SECTIONS/TASK/manage_tasks.dart';
import '../DEPARTMENT/manage_department.dart';
import '../MEMBER/manage_member.dart';
import '../SETTINGS/manage_settings.dart';
import 'WIDGETS/1_dashboard_card_widget.dart';

class Overview extends StatefulWidget {
  final Function(int, Widget) onItemTapped;
  final GlobalKey createDepartmentKey;
  final GlobalKey viewEditSearchDepartmentsKey;
  final GlobalKey addMembersInDepartmentKey;
  final GlobalKey createTasksKey;
  final GlobalKey viewEditSearchTasksKey;
  final GlobalKey assignTasksToMembersKey;
  final GlobalKey evaluateTasksKey;
  final GlobalKey manageUserRegistrations;

  const Overview({
    super.key,
    required this.onItemTapped,
    required this.createDepartmentKey,
    required this.viewEditSearchDepartmentsKey,
    required this.addMembersInDepartmentKey,
    required this.createTasksKey,
    required this.viewEditSearchTasksKey,
    required this.assignTasksToMembersKey,
    required this.evaluateTasksKey,
    required this.manageUserRegistrations,
  });

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  void _handleDepartmentNavigation() {
    widget.onItemTapped(
      1,
      ManageDepartment(
        createDepartmentKey: widget.createDepartmentKey,
        viewEditSearchDepartmentsKey: widget.viewEditSearchDepartmentsKey,
        addMembersInDepartmentKey: widget.addMembersInDepartmentKey,
      ),
    );
  }

  void _handleTasksNavigation() {
    widget.onItemTapped(
      6,
      ManageTasks(
        createTasksKey: widget.createTasksKey,
        viewEditSearchTasksKey: widget.viewEditSearchTasksKey,
        assignTasksToMembersKey: widget.assignTasksToMembersKey,
        evaluateTasksKey: widget.evaluateTasksKey,
      ),
    );
  }

  void _handleMembersNavigation() {
    widget.onItemTapped(
      4,
      ManageMember(
        manageUserRegistrations: widget.manageUserRegistrations,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'View Departments',
                  buttonText: 'Go to Departments',
                  onPressed: _handleDepartmentNavigation,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: DashboardCard(
                  title: 'View Members',
                  buttonText: 'Go to Members',
                  onPressed: _handleMembersNavigation,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'View Tasks',
                  buttonText: 'Go to Tasks',
                  onPressed: _handleTasksNavigation,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: DashboardCard(
                  title: 'View Reports',
                  buttonText: 'Go to Reports',
                  onPressed: () {
                    widget.onItemTapped(4, const ManageReports());
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: DashboardCard(
            title: 'View Other Actions',
            buttonText: 'Go to Settings',
            onPressed: () {
              widget.onItemTapped(5, const Settings());
            },
          ),
        ),
      ],
    );
  }
}
