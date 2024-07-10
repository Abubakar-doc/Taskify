import 'package:flutter/material.dart';

// Define custom colors
const Color customBgGrey = Color(0xff21222d);
const Color customAqua = Color(0xffa9dfd8);
const Color customDarkGrey = Color(0xff171821);
const Color customLightGrey = Color(0xff2f353e);

// Dark theme definition
final ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: customDarkGrey,
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    color: customDarkGrey,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: customLightGrey,
  ),
  iconTheme: const IconThemeData(color: Colors.white),
);
