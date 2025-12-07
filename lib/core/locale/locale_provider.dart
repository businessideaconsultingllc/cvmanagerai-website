import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for managing locale state
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'app_locale';

  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  // Load saved locale from shared preferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      if (localeCode != null) {
        state = Locale(localeCode);
      }
    } catch (e) {
      // If loading fails, stick with default locale
      debugPrint('Failed to load locale: $e');
    }
  }

  // Set new locale and persist it
  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      debugPrint('Failed to save locale: $e');
    }
  }

  // Predefined list of supported locales
  static const List<LocaleOption> supportedLocales = [
    LocaleOption(
      locale: Locale('en'),
      name: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
    ),
    LocaleOption(
      locale: Locale('es'),
      name: 'Spanish',
      nativeName: 'Español',
      flag: '🇪🇸',
    ),
    LocaleOption(
      locale: Locale('fr'),
      name: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
    ),
    LocaleOption(
      locale: Locale('ar'),
      name: 'Arabic',
      nativeName: 'العربية',
      flag: '🇸🇦',
    ),
    LocaleOption(
      locale: Locale('nl'),
      name: 'Dutch',
      nativeName: 'Nederlands',
      flag: '🇳🇱',
    ),
    LocaleOption(
      locale: Locale('de'),
      name: 'German',
      nativeName: 'Deutsch',
      flag: '🇩🇪',
    ),
    LocaleOption(
      locale: Locale('ru'),
      name: 'Russian',
      nativeName: 'Русский',
      flag: '🇷🇺',
    ),
  ];
}

class LocaleOption {
  final Locale locale;
  final String name;
  final String nativeName;
  final String flag;

  const LocaleOption({
    required this.locale,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}
