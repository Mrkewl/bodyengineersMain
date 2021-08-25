import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class MyTheme with ChangeNotifier {
  static bool _isDark = false;
  late SharedPreferences prefs;
  MyTheme() {
    getSharedPreferences();
  }
  void getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? false;
    notifyListeners();
  }

  ThemeMode currentTheme() {
    return _isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void switchTheme() {
    prefs.setBool('isDark', !_isDark);
    _isDark = !_isDark;
    notifyListeners();
  }
}
