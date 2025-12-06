import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/data/auth_repository.dart';

import '../../credits/presentation/credits_provider.dart';
import '../../profile/data/profile_repository.dart';
import '../data/cover_letter_repository.dart';
import '../domain/cover_letter_model.dart';

final coverLetterRepositoryProvider = Provider<CoverLetterRepository>((ref) {
  return CoverLetterRepository(Supabase.instance.client);
});

final coverLetterControllerProvider =
    StateNotifierProvider<CoverLetterController, AsyncValue<CoverLetterModel?>>(
        (ref) {
  return CoverLetterController(ref);
});

class CoverLetterController
    extends StateNotifier<AsyncValue<CoverLetterModel?>> {
  final Ref _ref;

  CoverLetterController(this._ref) : super(const AsyncValue.data(null));

  Future<void> generateCoverLetter({
    required String jobTitle,
    required String companyName,
    String? jobDescription,
    String? cvContent,
    String targetLanguage = 'en',
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      // Check credits
      final creditService = _ref.read(creditServiceProvider);
      final hasCredits = await creditService.hasCredits(user.id);
      if (!hasCredits) {
        throw Exception(
            'Insufficient credits. You need 1 credit to generate a cover letter.');
      }

      // Get profile
      final profileRepo = _ref.read(profileRepositoryProvider);
      final profile = await profileRepo.getProfile(user.id);
      if (profile == null) throw Exception('Profile not found');

      // Build prompt
      final prompt = _buildPrompt(
        profile: profile,
        jobTitle: jobTitle,
        companyName: companyName,
        jobDescription: jobDescription,
        cvContent: cvContent,
        targetLanguage: targetLanguage,
      );

      // Call API
      final content = await _callDeepSeekAPI(prompt);

      // Create model
      final coverLetter = CoverLetterModel(
        id: const Uuid().v4(),
        userId: user.id,
        title: 'Cover Letter for $jobTitle at $companyName',
        content: content,
        jobTitle: jobTitle,
        companyName: companyName,
        jobDescription: jobDescription,
        language: targetLanguage,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to DB
      await _ref
          .read(coverLetterRepositoryProvider)
          .saveCoverLetter(coverLetter);

      // Deduct credits
      await creditService.useCredits(
        userId: user.id,
        operationType: 'cover_letter',
      );

      state = AsyncValue.data(coverLetter);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String _buildPrompt({
    required Map<String, dynamic> profile,
    required String jobTitle,
    required String companyName,
    String? jobDescription,
    String? cvContent,
    String targetLanguage = 'en',
  }) {
    return '''
    You are an expert career coach. Write a professional cover letter for the following candidate.
    
    TARGET LANGUAGE: $targetLanguage
    
    CANDIDATE:
    Name: ${profile['first_name']} ${profile['last_name']}
    Email: ${profile['email']}
    Phone: ${profile['phone']}
    Address: ${profile['address']}
    
    ${cvContent != null ? 'CV CONTENT:\n$cvContent\n' : ''}
    
    TARGET JOB:
    Title: $jobTitle
    Company: $companyName
    ${jobDescription != null ? 'Job Description: $jobDescription' : ''}
    
    INSTRUCTIONS:
    1. Write the ENTIRE cover letter in $targetLanguage.
    2. Use a professional, persuasive tone appropriate for $targetLanguage.
    3. Highlight enthusiasm for the role and company.
    4. If a job description is provided, tailor the content to match key requirements.
    5. If CV content is provided, highlight relevant skills and experiences from the CV that match the job.
    6. Return ONLY the body of the cover letter (no placeholders like [Your Name] unless absolutely necessary, use provided data).
    ''';
  }

  Future<String> _callDeepSeekAPI(String prompt) async {
    final url = Uri.parse(AppConstants.deepSeekEdgeFunctionUrl);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConstants.supabaseAnonKey}',
      },
      body: jsonEncode({
        'prompt': prompt,
        'systemMessage': 'You are an expert career coach.',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'];
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception('Failed to generate cover letter: ${errorData['error']}');
    }
  }
}
