import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cover_letter_model.dart';

class CoverLetterRepository {
  final SupabaseClient _supabase;

  CoverLetterRepository(this._supabase);

  Future<void> saveCoverLetter(CoverLetterModel coverLetter) async {
    await _supabase.from('cover_letters').upsert(coverLetter.toMap());
  }

  Future<List<CoverLetterModel>> getUserCoverLetters(String userId) async {
    final response = await _supabase
        .from('cover_letters')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CoverLetterModel.fromMap(json))
        .toList();
  }

  Future<void> deleteCoverLetter(String id) async {
    await _supabase.from('cover_letters').delete().eq('id', id);
  }
}

final coverLetterRepositoryProvider = Provider<CoverLetterRepository>((ref) {
  return CoverLetterRepository(Supabase.instance.client);
});

final userCoverLettersProvider =
    FutureProvider.autoDispose<List<CoverLetterModel>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  final repo = ref.read(coverLetterRepositoryProvider);
  return repo.getUserCoverLetters(user.id);
});
