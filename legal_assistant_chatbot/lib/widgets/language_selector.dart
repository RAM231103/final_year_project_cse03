import 'package:flutter/material.dart';
import 'package:legal_assistant_chatbot/models/language_option.dart';

// Language selector widget - consistent across the app
class LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;
  final List<LanguageOption> languages;

  const LanguageSelector({
    Key? key,
    required this.currentLanguage,
    required this.onLanguageChanged,
    required this.languages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: onLanguageChanged,
      itemBuilder: (context) {
        return languages.map((language) {
          return PopupMenuItem<String>(
            value: language.code,
            child: Row(
              children: [
                Text(language.name),
                const SizedBox(width: 8),
                if (language.code == currentLanguage)
                  const Icon(Icons.check, size: 18),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}