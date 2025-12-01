import '../data/credits_repository.dart';

/// Service class to manage credit operations
class CreditService {
  final CreditsRepository _repository;

  CreditService(this._repository);

  /// Check if user has sufficient credits for an operation
  Future<bool> hasCredits(String userId, {int required = 1}) async {
    // First check if monthly reset is needed
    await _repository.checkAndResetMonthlyCredits(userId);

    final balance = await _repository.getUserCredits(userId);
    return balance >= required;
  }

  /// Get current credit balance
  Future<int> getBalance(String userId) async {
    await _repository.checkAndResetMonthlyCredits(userId);
    return await _repository.getUserCredits(userId);
  }

  /// Use credits for an operation
  Future<void> useCredits({
    required String userId,
    required String operationType,
    int amount = 1,
  }) async {
    // Check if reset is needed first
    await _repository.checkAndResetMonthlyCredits(userId);

    // Deduct credits
    await _repository.deductCredits(
      userId: userId,
      amount: amount,
      operationType: operationType,
    );
  }

  /// Get next reset date
  Future<DateTime> getNextResetDate(String userId) async {
    return await _repository.getNextResetDate(userId);
  }

  /// Get credit history
  Future<List> getCreditHistory(String userId) async {
    return await _repository.getCreditHistory(userId);
  }
}
