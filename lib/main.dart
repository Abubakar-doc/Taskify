import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taskify/THEME/theme_provider.dart';
import 'package:taskify/main_mobile.dart';
import 'package:taskify/main_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (foundation.kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDSCVtDG8Oh8PNKwgjwyLmsgFaCNsvOyiY",
        authDomain: "taskify-a182c.firebaseapp.com",
        projectId: "taskify-a182c",
        storageBucket: "taskify-a182c.appspot.com",
        messagingSenderId: "129387226201",
        appId: "1:129387226201:web:49b9e5b092d6b9253bfd48",
        measurementId: "G-NJ0G1J4KDY",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const TaskifyApp());
}

class TaskifyApp extends StatelessWidget {
  const TaskifyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.dark,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: foundation.kIsWeb
                ? const WebHomePage()
                : const MobileHomePage(),
          );
        },
      ),
    );
  }
}
