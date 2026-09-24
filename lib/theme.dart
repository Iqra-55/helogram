import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _followSystem = true;

  bool get isDarkMode => _isDarkMode;
  bool get followSystem => _followSystem;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _followSystem = prefs.getBool('followSystem') ?? true;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  void setSystemTheme(Brightness brightness) {
    if (_followSystem) {
      _isDarkMode = brightness == Brightness.dark;
      notifyListeners();
    }
  }

  void toggleTheme() async {
    _followSystem = false;
    _isDarkMode = !_isDarkMode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('followSystem', false);
    await prefs.setBool('isDarkMode', _isDarkMode);
    
    notifyListeners();
  }

  void followSystemTheme() async {
    _followSystem = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('followSystem', true);
    
    notifyListeners();
  }
}