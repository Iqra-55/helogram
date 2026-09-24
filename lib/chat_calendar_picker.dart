import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatCalendarPicker {
  static Future<DateTime?> show(BuildContext context, {bool isDark = false}) async {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    surface: Color(0xFF1C1C1E),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF2C3859),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
            dialogBackgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white : const Color(0xFF2C3859),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
