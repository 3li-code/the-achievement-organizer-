// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // حالة الثيم الافتراضية، يمكن حفظها محلياً لاحقاً
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  // دالة التبديل بين الوضعين
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners(); // إخطار المستمعين (MaterialApp) للتحديث
  }

  // يمكن إضافة دالة لضبط وضع معين مباشرة
  void setThemeMode(ThemeMode mode) {
    if (mode != _themeMode) {
      _themeMode = mode;
      notifyListeners();
    }
  }
}
