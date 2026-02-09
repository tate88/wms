// ignore: file_names
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2b4e86);
  static const Color lightBlue = Color(0xFF3a5998);
  static const Color accentBlue = Color(0xFF1E3A8A);
  static const Color orange = Colors.orange;
  static const Color textMedium = Color(0xFF4A5568);
  static const Color textDark = Color(0xFF1A202C);
  static const Color backgroundGray = Color(0xFFF8F9FA);
  static const Color borderGray = Color(0xFFE2E8F0);
  static const Color backgroundColor = Color(0xFFF9F9F9);
}

Color primaryColor = "#02b4e86".toColor();
Color backgroundColor = "#F9F9F9".toColor();
Color fontBlack = "#000000".toColor();
Color greyFont = "#616161".toColor();
Color cardColor = Colors.white;
Color shadowColor = Colors.black12;


extension ColorExtension on String {
  toColor() {
    var hexColor = replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}
