// In a file like widgets/theme_selector.dart
import 'package:flutter/material.dart';

class ThemeSelector extends StatelessWidget {
  final bool isLightTheme;
  final Function(bool) onThemeChanged;

  const ThemeSelector({
    Key? key,
    required this.isLightTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isLightTheme ? Icons.dark_mode : Icons.light_mode),
      onPressed: () => onThemeChanged(!isLightTheme),
      tooltip: isLightTheme ? 'Switch to dark theme' : 'Switch to light theme',
    );
  }
}