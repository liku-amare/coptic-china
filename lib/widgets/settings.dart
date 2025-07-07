import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'values.dart';

class AppSettings {
  static const _fontSizeKey = 'font_size';
  static const _fontStyleKey = 'font_style';
  static const _fontColorKey = 'font_color';
  static const _languageKey = 'default_language';
  static const _language1Key = 'language1';
  static const _language2Key = 'language2';
  static const _themeModeKey = 'theme_mode';
  // static const String _languageKey = 'default_language';
  static String _cachedLangCode = 'en'; // fallback default

  /// Call this once at startup to initialize language settings
  static Future<void> initSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String lang = prefs.getString(_languageKey) ?? 'English';
    _cachedLangCode = getLangCode(lang);
  }

  // Theme Mode Methods
  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
    return ThemeMode.values[themeModeIndex];
  }

  static Future<void> setThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, themeMode.index);
  }

  static Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 16.0;
  }

  static Future<void> setFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, value);
  }

  static Future<String> getFontStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fontStyleKey) ?? 'Roboto';
  }

  static Future<void> setFontStyle(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontStyleKey, value);
  }

  static Future<Color> getFontColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorInt = prefs.getInt(_fontColorKey) ?? Colors.black.value;
    return Color(colorInt);
  }

  static Future<void> setFontColor(Color value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontColorKey, value.value);
  }

  static Future<String> getDefaultLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'English';
  }

  static Future<void> setDefaultLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
  }

  static Future<String> getLanguage1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_language1Key) ?? 'English';
  }

  static Future<void> setLanguage1(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_language1Key, value);
  }

  static Future<String> getLanguage2() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_language2Key) ?? 'العربية';
  }

  static Future<void> setLanguage2(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_language2Key, value);
  }

  static String getNameValue(String key) {
    String label = Values.nameValues[_cachedLangCode]?[key] ?? key;
    return label;
  }

  static String getLangCodeFromId(int langId) {
    List<String> langIds = ['ar', 'en', 'zh_hant', 'zh_hans', 'coptic'];
    return langIds[langId - 1];
  }

  static String getLangCode(String langName) {
    Map<String, String> langIds = {
      'العربية': 'ar',
      'English': 'en',
      '中文（繁體）': 'zh_hant',
      '中文（简体）': 'zh_hans',
      'Coptic': 'coptic',
    };
    return langIds[langName] ?? 'en';
  }

  static int getLangId(String langName) {
    Map<String, String> langCodes = {
      'العربية': 'ar',
      'English': 'en',
      '中文（繁體）': 'zh_hant',
      '中文（简体）': 'zh_hans',
      'Coptic': 'coptic',
    };
    String code = langCodes[langName] ?? 'en';
    List<String> langIdList = ['ar', 'en', 'zh_hant', 'zh_hans', 'coptic'];
    return langIdList.indexOf(code) + 1;
  }

  static String getCachedLang() {
    return _cachedLangCode;
  }

  static int getCachedLangId() {
    List<String> langIds = ['ar', 'en', 'zh_hant', 'zh_hans', 'coptic'];
    return langIds.indexOf(_cachedLangCode) + 1;
  }

  static int getLandIdFromCode(String code) {
    List<String> langIds = ['ar', 'en', 'zh_hant', 'zh_hans', 'coptic'];
    return langIds.indexOf(code) + 1;
  }

  static void updateCachedLanguage(String languageCode) {
    _cachedLangCode = languageCode;
  }
}
