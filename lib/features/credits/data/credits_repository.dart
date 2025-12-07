import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/credit_transaction.dart';

class CreditsRepository {
  final SupabaseClient _supabase;

  CreditsRepository(this._supabase);

  /// Get user's current credit balance
  Future<int> getUserCredits(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('credits_balance')
        .eq('id', userId)
        .single();

    return response['credits_balance'] ?? 0;
  }

  /// Check if user needs monthly credit reset and perform if needed
  Future<bool> checkAndResetMonthlyCredits(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('credits_reset_date, credits_balance')
        .eq('id', userId)
        .single();

    final resetDateStr = response['credits_reset_date'];
    final resetDate = resetDateStr != null && resetDateStr.toString().isNotEmpty
        ? DateTime.tryParse(resetDateStr.toString()) ?? DateTime.now()
        : DateTime.now();
    final daysSinceReset = DateTime.now().difference(resetDate).inDays;

    // Reset if 30 days have passed
    if (daysSinceReset >= 30) {
      await _supabase.from('profiles').update({
        'credits_balance': 5,
        'credits_reset_date': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // Log reset transaction
      await _logTransaction(
        userId: userId,
        operationType: 'reset',
        creditsUsed: -5, // Negative means added
        balanceAfter: 5,
      );

      return true;
    }

    return false;
  }

  /// Deduct credits from user's balance
  Future<void> deductCredits({
    required String userId,
    required int amount,
    required String operationType,
  }) async {
    // Get current balance
    final currentBalance = await getUserCredits(userId);

    if (currentBalance < amount) {
      throw Exception('Insufficient credits');
    }

    final newBalance = currentBalance - amount;

    // Get current total used
    final profile = await _supabase
        .from('profiles')
        .select('total_credits_used')
        .eq('id', userId)
        .single();
    final currentTotalUsed = profile['total_credits_used'] ?? 0;

    // Update balance and total used
    await _supabase.from('profiles').update({
      'credits_balance': newBalance,
      'total_credits_used': currentTotalUsed + amount,
    }).eq('id', userId);

    // Log transaction
    await _logTransaction(
      userId: userId,
      operationType: operationType,
      creditsUsed: amount,
      balanceAfter: newBalance,
    );
  }

  /// Log a credit transaction
  Future<void> _logTransaction({
    required String userId,
    required String operationType,
    required int creditsUsed,
    required int balanceAfter,
  }) async {
    await _supabase.from('credit_transactions').insert({
      'user_id': userId,
      'operation_type': operationType,
      'credits_used': creditsUsed,
      'balance_after': balanceAfter,
    });
  }

  /// Get user's credit transaction history
  Future<List<CreditTransaction>> getCreditHistory(String userId,
      {int limit = 50}) async {
    final response = await _supabase
        .from('credit_transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => CreditTransaction.fromMap(json))
        .toList();
  }

  /// Get next reset date
  Future<DateTime> getNextResetDate(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('credits_reset_date')
        .eq('id', userId)
        .single();

    final resetDateStr = response['credits_reset_date'];
    final resetDate = resetDateStr != null && resetDateStr.toString().isNotEmpty
        ? DateTime.tryParse(resetDateStr.toString()) ?? DateTime.now()
        : DateTime.now();
    return resetDate.add(const Duration(days: 30));
  }
}
