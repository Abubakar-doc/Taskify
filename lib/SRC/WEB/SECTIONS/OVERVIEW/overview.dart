import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/SECTIONS/REPORT/manage_reports.dart';
import 'package:taskify/SRC/WEB/SECTIONS/TASK/manage_tasks.dart';
import '../DEPARTMENT/manage_department.dart';
import '../MEMBER/manage_member.dart';
import '../SETTINGS/manage_settings.dart';
import 'WIDGETS/1_dashboard_card_widget.dart';

class Overview extends StatefulWidget {
  final Function(int, Widget) onItemTapped;

  const Overview({super.key, required this.onItemTapped});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
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
                  onPressed: () {
                    widget.onItemTapped(1, const ManageDepartment());
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: DashboardCard(
                  title: 'View Members',
                  buttonText: 'Go to Members',
                  onPressed: () {
                    widget.onItemTapped(2, const ManageMember());
                  },
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
                  onPressed: () {
                    widget.onItemTapped(3, const ManageTasks());
                  },
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
              widget.onItemTapped(5, Settings());
            },
          ),
        ),
      ],
    );
  }
}



