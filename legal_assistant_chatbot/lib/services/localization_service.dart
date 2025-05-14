// In a file like services/localization_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'selectedLanguage';
  static const String defaultLanguage = 'en';

  // Get stored language code, default to 'en'
  static Future<String> getLanguage() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? defaultLanguage;
    } catch (e) {
      // If any error occurs, return the default language
      return defaultLanguage;
    }
  }

  // Save selected language code
  static Future<void> setLanguage(String languageCode) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      // Handle error (optional)
    }
  }

  // Convert language code to locale
  static Locale getLocaleFromLanguage(String languageCode) {
    return Locale(languageCode, '');
  }

  // Get available locales for app
  static List<Locale> get supportedLocales {
    return [
      const Locale('en', ''), // English
      const Locale('es', ''), // Spanish
      const Locale('fr', ''), // French
      const Locale('de', ''), // German
      const Locale('hi', ''), // Hindi
      const Locale('te', ''), // Telugu
    ];
  }
}