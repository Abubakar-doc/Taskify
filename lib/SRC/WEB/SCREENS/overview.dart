import 'package:flutter/material.dart';
import 'package:taskify/THEME/theme.dart';
import 'manage_department.dart';
import 'manage_member.dart';
import 'manage_reports.dart';
import 'manage_settings.dart';
import 'manage_tasks.dart';

class Overview extends StatefulWidget {
  final Function(int, Widget) onItemTapped;

  const Overview({Key? key, required this.onItemTapped}) : super(key: key);

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
              widget.onItemTapped(5, const Settings());
            },
          ),
        ),
      ],
    );
  }
}


class DashboardCard extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onPressed;

  const DashboardCard({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: customLightGrey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: HoverableElevatedButton(
                text: buttonText,
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class HoverableElevatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const HoverableElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  _HoverableElevatedButtonState createState() =>
      _HoverableElevatedButtonState();
}

class _HoverableElevatedButtonState extends State<HoverableElevatedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _mouseEnter(true),
      onExit: (_) => _mouseEnter(false),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isHovered ? customAqua.withOpacity(0.8) : customAqua,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: widget.onPressed,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _mouseEnter(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }
}
