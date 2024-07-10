import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:taskify/SRC/WEB/SCREENS/overview.dart';
import 'package:taskify/SRC/WEB/WIDGETS/still_web_drawer.dart';
import 'package:taskify/THEME/theme.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({super.key});

  @override
  _WebHomePageState createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  int _selectedIndex = 0;
  late Widget _selectedWidget;

  @override
  void initState() {
    super.initState();
    _selectedWidget = Overview(onItemTapped: _onItemTapped);
  }

  void _onItemTapped(int index, Widget widget) {
    setState(() {
      _selectedIndex = index;
      _selectedWidget = widget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customBgGrey,
      appBar: AppBar(
        backgroundColor: customDarkGrey,
        title: const Row(
          children: [
            Icon(
              SimpleIcons.task,
              color: customAqua,
            ),
            SizedBox(width: 8),
            Text(
              'Taskify AdminPanel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: customAqua,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Add your onPressed code here!
            },
          ),
        ],
      ),
      body: Row(
        children: [
          DrawerWidget(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: _selectedWidget,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
