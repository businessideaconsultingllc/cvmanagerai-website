import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/feedback_repository.dart';
import '../domain/user_feedback_model.dart';

final feedbackControllerProvider =
    StateNotifierProvider<FeedbackController, AsyncValue<List<UserFeedback>>>(
        (ref) {
  return FeedbackController(ref.watch(feedbackRepositoryProvider));
});

class FeedbackController extends StateNotifier<AsyncValue<List<UserFeedback>>> {
  final FeedbackRepository _repository;

  FeedbackController(this._repository) : super(const AsyncValue.loading()) {
    loadFeedback();
  }

  Future<void> loadFeedback() async {
    try {
      state = const AsyncValue.loading();
      final feedback = await _repository.getAllFeedback();
      state = AsyncValue.data(feedback);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      // Optimistic update or reload
      state.whenData((currentList) {
        state = AsyncValue.data(currentList.map((item) {
          if (item.id == id) {
            // We can't modify the object since it's final, so we'd need copyWith or create new
            // Assuming UserFeedback is immutable, we reconstruct it roughly or just reload
            // Ideally UserFeedback should have copyWith. I didn't add it.
            // Let's just reload for simplicity.
            return item;
          }
          return item;
        }).toList());
      });
      await loadFeedback();
    } catch (e) {
      // Handle error
    }
  }
}
