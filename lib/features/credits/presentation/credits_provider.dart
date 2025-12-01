import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/auth_repository.dart';
import '../data/credits_repository.dart';
import '../domain/credit_service.dart';
import '../domain/credit_transaction.dart';

// Provider for CreditsRepository
final creditsRepositoryProvider = Provider<CreditsRepository>((ref) {
  return CreditsRepository(Supabase.instance.client);
});

// Provider for CreditService
final creditServiceProvider = Provider<CreditService>((ref) {
  final repository = ref.watch(creditsRepositoryProvider);
  return CreditService(repository);
});

// Provider for current user's credit balance
final creditBalanceProvider = StreamProvider<int>((ref) async* {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) {
    yield 0;
    return;
  }

  final creditService = ref.watch(creditServiceProvider);

  // Initial balance
  yield await creditService.getBalance(user.id);

  // Listen for changes
  final stream = Supabase.instance.client
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', user.id)
      .map((data) {
        if (data.isEmpty) return 0;
        return (data.first['credits_balance'] ?? 0) as int;
      });

  yield* stream;
});

// Provider for credit history
final creditHistoryProvider =
    FutureProvider<List<CreditTransaction>>((ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return [];

  final repository = ref.watch(creditsRepositoryProvider);
  return await repository.getCreditHistory(user.id);
});

// Provider for next reset date
final nextResetDateProvider = FutureProvider<DateTime>((ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return DateTime.now();

  final repository = ref.watch(creditsRepositoryProvider);
  return await repository.getNextResetDate(user.id);
});
