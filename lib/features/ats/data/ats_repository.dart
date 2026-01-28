import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/ats_score_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ATSRepository {
  final SupabaseClient _supabase;

  ATSRepository(this._supabase);

  Future<void> saveATSCheck(ATSScoreModel check) async {
    await _supabase.from('ats_checks').insert(check.toMap());
  }

  Future<List<ATSScoreModel>> getUserATSChecks(String userId) async {
    final response = await _supabase
        .from('ats_checks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((data) => ATSScoreModel.fromMap(data))
        .toList();
  }
}

final atsRepositoryProvider = Provider<ATSRepository>((ref) {
  return ATSRepository(Supabase.instance.client);
});
