import 'package:flutter/material.dart';

class InVoidTheme {
  static const Color primaryColor = Color(0xff54B0F3);
  static const Color primaryColorLight = Color(0xff93d0fa);
  static const Color primaryColorDark = Color(0xff306c96);
  static const Color accentColor = Color(0xffF9C034);
  static const Color buttonColor = Color(0xffAC7FFC);
  static const Color textColor = Color(0xff223851);
  static const Color scaffoldBGColor = Color(0xffDBE0EA);

  static final TextTheme _textTheme = ThemeData.light().textTheme;

  static ThemeData get theme => ThemeData(
      primaryColor: primaryColor,
      primaryColorLight: primaryColorLight,
      primaryColorDark: primaryColorDark,
      accentColor: accentColor,
      buttonColor: buttonColor,
      scaffoldBackgroundColor: scaffoldBGColor,
      textTheme: _textTheme.copyWith(
          headline1: _textTheme.headline1.copyWith(
              fontSize: 20.0, color: textColor, fontWeight: FontWeight.w700),
          headline2: _textTheme.headline2.copyWith(
              fontSize: 15.0, color: textColor, fontWeight: FontWeight.w600)));
}
