import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/cv_model.dart';

class CVRepository {
  final SupabaseClient _supabase;

  CVRepository(this._supabase);

  Future<void> saveCV(CVModel cv) async {
    await _supabase.from('cvs').insert(cv.toMap());
  }

  Future<void> updateCV(CVModel cv) async {
    await _supabase.from('cvs').update(cv.toMap()).eq('id', cv.id);
  }

  Future<List<CVModel>> getUserCVs(String userId) async {
    final response = await _supabase
        .from('cvs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => CVModel.fromMap(e)).toList();
  }

  Future<List<CVModel>> getCVsByType(String userId, CVType type) async {
    final response = await _supabase
        .from('cvs')
        .select()
        .eq('user_id', userId)
        .eq('cv_type', type.toJson())
        .order('created_at', ascending: false);

    return (response as List).map((e) => CVModel.fromMap(e)).toList();
  }

  Future<CVModel?> getCV(String cvId) async {
    final response =
        await _supabase.from('cvs').select().eq('id', cvId).single();

    return CVModel.fromMap(response);
  }

  Future<void> deleteCV(String cvId) async {
    await _supabase.from('cvs').delete().eq('id', cvId);
  }

  Future<void> deleteCVs(List<String> cvIds) async {
    await _supabase.from('cvs').delete().filter('id', 'in', cvIds);
  }
}

final cvRepositoryProvider = Provider<CVRepository>((ref) {
  return CVRepository(Supabase.instance.client);
});

final userCVsProvider = FutureProvider.autoDispose<List<CVModel>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  final repo = ref.read(cvRepositoryProvider);
  return repo.getUserCVs(user.id);
});

final generatedCVsProvider =
    FutureProvider.autoDispose<List<CVModel>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  final repo = ref.read(cvRepositoryProvider);
  return repo.getCVsByType(user.id, CVType.generated);
});

final optimizedCVsProvider =
    FutureProvider.autoDispose<List<CVModel>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  final repo = ref.read(cvRepositoryProvider);
  return repo.getCVsByType(user.id, CVType.optimized);
});

final tailoredCVsProvider =
    FutureProvider.autoDispose<List<CVModel>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  final repo = ref.read(cvRepositoryProvider);
  return repo.getCVsByType(user.id, CVType.tailored);
});
