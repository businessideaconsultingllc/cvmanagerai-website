import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

// Provider for first launch state
final firstLaunchProvider =
    StateNotifierProvider<FirstLaunchNotifier, AsyncValue<bool>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FirstLaunchNotifier(prefs);
});

class FirstLaunchNotifier extends StateNotifier<AsyncValue<bool>> {
  final SharedPreferences _prefs;
  static const String _firstLaunchKey = 'is_first_launch';

  FirstLaunchNotifier(this._prefs) : super(const AsyncValue.loading()) {
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final isFirstLaunch = _prefs.getBool(_firstLaunchKey) ?? true;
      state = AsyncValue.data(isFirstLaunch);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markFirstLaunchComplete() async {
    try {
      await _prefs.setBool(_firstLaunchKey, false);
      state = const AsyncValue.data(false);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> isFirstLaunch() async {
    return _prefs.getBool(_firstLaunchKey) ?? true;
  }
}
