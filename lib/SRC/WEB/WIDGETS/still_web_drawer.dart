import 'package:flutter/material.dart';
import 'package:taskify/SRC/WEB/SCREENS/manage_department.dart';
import 'package:taskify/SRC/WEB/SCREENS/manage_member.dart';
import 'package:taskify/SRC/WEB/SCREENS/manage_reports.dart';
import 'package:taskify/SRC/WEB/SCREENS/manage_settings.dart';
import 'package:taskify/SRC/WEB/SCREENS/manage_tasks.dart';
import 'package:taskify/SRC/WEB/SCREENS/overview.dart';
import 'package:taskify/THEME/theme.dart';

class DrawerWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int, Widget) onItemTapped;

  const DrawerWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
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
            HoverableListItem(
              title: 'Overview',
              onTap: () => onItemTapped(0, const Overview()),
              icon: const Icon(Icons.dashboard),
              isSelected: selectedIndex == 0,
            ),
            HoverableListItem(
              title: 'Manage Departments',
              onTap: () => onItemTapped(1, const ManageDepartment()),
              icon: const Icon(Icons.business),
              isSelected: selectedIndex == 1,
            ),
            HoverableListItem(
              title: 'Manage Members',
              onTap: () => onItemTapped(2, const ManageMember()),
              icon: const Icon(Icons.person),
              isSelected: selectedIndex == 2,
            ),
            HoverableListItem(
              title: 'Manage Tasks',
              onTap: () => onItemTapped(3, const ManageTasks()),
              icon: const Icon(Icons.task),
              isSelected: selectedIndex == 3,
            ),
            HoverableListItem(
              title: 'Manage Reports',
              onTap: () => onItemTapped(4, const ManageReports()),
              icon: const Icon(Icons.file_copy_outlined),
              isSelected: selectedIndex == 4,
            ),
            HoverableListItem(
              title: 'Settings',
              onTap: () => onItemTapped(5, const Settings()),
              icon: const Icon(Icons.settings),
              isSelected: selectedIndex == 5,
            ),
          ],
        ),
      ),
    );
  }
}

class HoverableListItem extends StatefulWidget {
  final String title;
  final Icon? icon;
  final VoidCallback onTap;
  final bool isSelected;

  const HoverableListItem({super.key, required this.title, required this.onTap, this.icon, required this.isSelected});

  @override
  _HoverableListItemState createState() => _HoverableListItemState();
}

class _HoverableListItemState extends State<HoverableListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _mouseEnter(true),
      onExit: (_) => _mouseEnter(false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: _isHovered || widget.isSelected ? customDarkGrey : Colors.transparent,
          child: ListTile(
            leading: widget.icon,
            title: Text(
              widget.title,
              style: TextStyle(
                color: _isHovered || widget.isSelected ? Colors.white : Colors.grey,
                fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: widget.onTap,
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
