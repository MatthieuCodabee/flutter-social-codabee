import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorTheme {

  //Sans le Context
  bool isDarkMode() {
    final window = WidgetsBinding.instance.window;
    final mode = MediaQueryData.fromWindow(window).platformBrightness;
    return (mode == Brightness.dark);
  }

  //Avec le Context
  bool isDarkModeWithContext(BuildContext context) {
    final mode = MediaQuery.of(context).platformBrightness;
    return (mode == Brightness.dark);
  }

  Color pointer() => Colors.teal;
  Color base() => (isDarkMode()) ? Color.fromRGBO(33, 33, 33, 1) : Colors.white;
  Color accent() => (isDarkMode()) ? Colors.grey : Colors.grey;
  Color textColor() => (isDarkMode()) ? Colors.white: Colors.black;

}

