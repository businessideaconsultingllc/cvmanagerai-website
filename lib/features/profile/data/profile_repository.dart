import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response =
          await _client.from('profiles').select().eq('id', userId).single();
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
  }) async {
    await _client.from('profiles').update({
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'address': address,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }
}
