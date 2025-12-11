class AppLanguages {
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ar': 'Arabic',
    'fr': 'French',
    'es': 'Spanish',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'nl': 'Dutch',
    'ru': 'Russian',
    'zh': 'Chinese',
    'ja': 'Japanese',
  };

  static bool isRtl(String languageCode) {
    return ['ar', 'he', 'fa', 'ur'].contains(languageCode);
  }

  static String getName(String code) {
    return supportedLanguages[code] ?? 'English';
  }
}
