import 'package:flutter/material.dart';
import 'package:taskify/SRC/COMMON/MODEL/Member.dart';
import 'package:taskify/SRC/MOBILE/SCREENS/HOME/VIEWS/HOME/home_view.dart';
import 'package:taskify/SRC/MOBILE/SCREENS/HOME/VIEWS/SETTINGS/setting_view.dart';
import 'package:taskify/SRC/MOBILE/SCREENS/HOME/VIEWS/TASK/task_view.dart';
import 'package:taskify/THEME/theme.dart';

class HomeScreen extends StatefulWidget {
  final UserModel userModel;

  const HomeScreen({super.key, required this.userModel});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomeView(userModel: widget.userModel),
          TaskView(userModel: widget.userModel),
          const SettingView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: customAqua,
        unselectedItemColor: Colors.white,
        backgroundColor: customDarkGrey,
        onTap: _onItemTapped,
      ),
    );
  }
}
