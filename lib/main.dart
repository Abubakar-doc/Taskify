import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taskify/main_web.dart';
import 'firebase_options.dart';
import 'package:taskify/THEME/theme_provider.dart';
import 'package:taskify/main_mobile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TaskifyApp());
}

class TaskifyApp extends StatelessWidget {
  const TaskifyApp({super.key});

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
