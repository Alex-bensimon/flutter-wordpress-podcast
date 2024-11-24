export './fonts.dart';
export './themes.dart';

import 'package:flutter/material.dart';

bool isAppInDarkMode(BuildContext context) {
  final brightness = MediaQuery.of(context).platformBrightness;
  return brightness == Brightness.dark;
}

Color getBackgroundColor({required bool isDarkMode}) {
  return isDarkMode ? Colors.black : Colors.white;
}
