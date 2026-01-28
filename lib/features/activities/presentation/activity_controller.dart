import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/activity_repository.dart';
import '../domain/user_activity_model.dart';

final activityControllerProvider =
    StateNotifierProvider<ActivityController, AsyncValue<List<UserActivity>>>(
        (ref) {
  return ActivityController(ref.watch(activityRepositoryProvider));
});

class ActivityController extends StateNotifier<AsyncValue<List<UserActivity>>> {
  final ActivityRepository _repository;

  ActivityController(this._repository) : super(const AsyncValue.loading()) {
    loadActivities();
  }

  Future<void> loadActivities() async {
    try {
      state = const AsyncValue.loading();
      final activities = await _repository.getAllActivities();
      state = AsyncValue.data(activities);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
