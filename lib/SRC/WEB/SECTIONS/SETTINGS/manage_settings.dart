// import 'package:flutter/material.dart';
//
// class Settings extends StatelessWidget {
//   const Settings({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
import 'package:flutter/material.dart';


class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final List<GlobalKey> _body1Keys = List.generate(3, (_) => GlobalKey());
  final List<GlobalKey> _body2Keys = List.generate(3, (_) => GlobalKey());
  final List<GlobalKey> _body3Keys = List.generate(3, (_) => GlobalKey());

  int _currentBodyIndex = 0;

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context,
          duration: Duration(seconds: 1), curve: Curves.easeInOut);
    }
    Navigator.of(context!).pop(); // Close the drawer
  }

  Widget _buildSection(GlobalKey key, String title, Color color) {
    return Container(
      key: key,
      height: MediaQuery.of(context).size.height,
      color: color,
      child: Center(child: Text(title, style: TextStyle(fontSize: 24, color: Colors.white))),
    );
  }

  Widget _buildBody(List<GlobalKey> keys, String bodyTitle) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          _buildSection(keys[0], '$bodyTitle - Section 1', Colors.redAccent),
          _buildSection(keys[1], '$bodyTitle - Section 2', Colors.greenAccent),
          _buildSection(keys[2], '$bodyTitle - Section 3', Colors.blueAccent),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodies = [
      _buildBody(_body1Keys, 'Body 1'),
      _buildBody(_body2Keys, 'Body 2'),
      _buildBody(_body3Keys, 'Body 3'),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Multiple Bodies Example'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Body 1 - Section 1'),
              onTap: () {
                setState(() {
                  _currentBodyIndex = 0;
                });
                _scrollToSection(_body1Keys[0]);
              },
            ),
            ListTile(
              title: Text('Body 1 - Section 2'),
              onTap: () {
                setState(() {
                  _currentBodyIndex = 0;
                });
                _scrollToSection(_body1Keys[1]);
              },
            ),
            ListTile(
              title: Text('Body 1 - Section 3'),
              onTap: () {
                setState(() {
                  _currentBodyIndex = 0;
                });
                _scrollToSection(_body1Keys[2]);
              },
            ),
            Divider(),
            ListTile(
              title: Text('Body 2 - Section 1'),
              onTap: () {
                setState(() {
                  _currentBodyIndex = 1;
                });
                _scrollToSection(_body2Keys[0]);
              },
            ),
            ListTile(
              title: Text('Body 2 - Section 2'),
              onTap: () {
                setState(() {
                  _currentBodyIndex = 1;
                });
                _scrollToSection(_body2Keys[1]);
              },
            ),
            ListTile(
              title: Text('Body 2 - Section 3'),
              onTap: () {
                setState(() {
                  _currentBodyIndex = 1;
                });
                _scrollToSection(_body2Keys[2]);
              },
            ),
            Divider(),
            ListTile(
              title: Text('Body 3 - Section 1'),
              onTap: () {
                setState(() {
                  _currentBodyIndex = 2;
                });
                _scrollToSection(_body3Keys[0]);
              },
            ),
            ListTile(
              title: Text('Body 3 - Section 2'),
              onTap: () {
                setState(() {
                  _currentBodyIndex = 2;
                });
                _scrollToSection(_body3Keys[1]);
              },
            ),
            ListTile(
              title: Text('Body 3 - Section 3'),
              onTap: () {
                setState(() {
                  _currentBodyIndex = 2;
                });
                _scrollToSection(_body3Keys[2]);
              },
            ),
          ],
        ),
      ),
      body: bodies[_currentBodyIndex],
    );
  }
}
