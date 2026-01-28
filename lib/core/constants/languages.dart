class AppLanguages {
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ar': 'العربية',
    'fr': 'Français',
    'es': 'Español',
    'de': 'Deutsch',
    'it': 'Italiano',
    'pt': 'Português',
    'nl': 'Nederlands',
    'ru': 'Русский',
    'zh': '中文',
    'ja': '日本語',
  };

  static bool isRtl(String languageCode) {
    return ['ar', 'he', 'fa', 'ur'].contains(languageCode);
  }

  static String getName(String code) {
    return supportedLanguages[code] ?? 'English';
  }
}
