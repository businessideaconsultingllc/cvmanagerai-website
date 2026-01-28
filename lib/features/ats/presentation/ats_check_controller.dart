import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/data/auth_repository.dart';
import '../../credits/presentation/credits_provider.dart';
import '../domain/ats_score_model.dart';
import '../data/ats_repository.dart';

class ATSCheckController extends StateNotifier<AsyncValue<ATSScoreModel?>> {
  final Ref _ref;

  ATSCheckController(this._ref) : super(const AsyncValue.data(null));

  void reset() {
    state = const AsyncValue.data(null);
  }

  Future<void> checkATSScore(String cvContent,
      {required String targetLanguage}) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      // Check if user has credits
      final creditService = _ref.read(creditServiceProvider);
      final hasCredits = await creditService.hasCredits(user.id);
      if (!hasCredits) {
        throw InsufficientCreditsException();
      }

      // Construct prompt for DeepSeek
      final prompt = '''
      You are an expert ATS (Applicant Tracking System) consultant. 
      Analyze the following CV content and provide a DETAILED ATS compatibility score (0-100) based on the following MANDATORY WEIGHTED RUBRIC.
      
      STANDARDIZED SCORING RUBRIC (Sum these points for the final score):
      1. SECTION HEADERS (15 pts): Must include sections for: Work Experience, Education, Skills, and Professional Summary.
         - Do NOT penalized for minor variations (e.g., "Summary" vs "Professional Summary", "Experience" vs "Work Experience").
         - If the CV is in a language other than English, look for the corresponding translated headers.
         - Do NOT penalize for punctuation like colons (e.g., "Skills:" is valid).
         - Full points if all 4 sections are present. 10 pts for 3. 5 pts for 2.
      2. CONTACT INFO (5 pts): Includes Email, Phone, and at least one professional link (LinkedIn/Website).
      3. PROFESSIONAL SUMMARY (10 pts): Keyword-rich, concise, and focused on value proposition.
      4. ACTION VERBS (15 pts): BULLET POINTS in the experience section should ideally start with strong action verbs.
         - Only deduct points if the majority of bullet points are passive or start with weak phrases (e.g., "Responsible for", "Handled").
      5. QUANTIFIABLE METRICS (25 pts): Presence of %, \$, or specific numbers in experience bullet points.
         - 25 pts for significant usage (>5 bullet points). 15 pts for 2-4 points. 5 pts for minimal usage.
      6. SKILLS CLARITY (15 pts): Skills clearly listed and ideally categorized (e.g., Technical, Soft, Tools).
      7. FORMATTING & DATES (15 pts): Clean text, consistent date format (e.g., Month Year or MM/YYYY), and logical spacing.

      CRITICAL INSTRUCTIONS:
      - Be flexible and encouraging. This is a tool to HELP users, not just criticize them.
      - NEVER report a header as missing if a synonymous or translated header is present.
      - If you report a problem about a header, ensure the "instead of" part actually points to a DIFFERENT text. NEVER say "uses 'X' instead of 'X'".
      - If the header is "Professional Summary:", it is EXACTLY what is required. Do NOT flag it.
      - PROVIDE ALL FEEDBACK (`problems`, `fixPoints`, `howToOptimize`) IN THE FOLLOWING LANGUAGE: $targetLanguage.

      CV CONTENT:
      $cvContent

      RETURN ONLY VALID JSON matching this structure:
      {
        "score": 85,
        "problems": ["Specific issue based on rubric. Be brief and clear."],
        "howToOptimize": "A few sentences of encouraging, actionable feedback.",
        "fixPoints": ["Short actionable point aligned with rubric"]
      }
      ''';

      // Call DeepSeek API (using the same proxy as CV generation)
      final aiResponseContent = await _callDeepSeekAPI(prompt);

      // Parse response
      final Map<String, dynamic> result = _parseAIResponse(aiResponseContent);

      final checkModel = ATSScoreModel(
        id: const Uuid().v4(),
        userId: user.id,
        cvContent: cvContent,
        score: result['score'] ?? 0,
        problems: List<String>.from(result['problems'] ?? []),
        fixPoints: List<String>.from(result['fixPoints'] ?? []),
        howToOptimize: result['howToOptimize'] ?? '',
        createdAt: DateTime.now(),
      );

      // Save to Supabase
      await _ref.read(atsRepositoryProvider).saveATSCheck(checkModel);

      // Deduct 1 credit
      await creditService.useCredits(
        userId: user.id,
        operationType: 'ats_check',
        amount: 1,
      );

      state = AsyncValue.data(checkModel);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Map<String, dynamic> _parseAIResponse(String content) {
    try {
      final startIndex = content.indexOf('{');
      final endIndex = content.lastIndexOf('}');
      if (startIndex == -1 || endIndex == -1) {
        throw Exception('No JSON found in AI response');
      }
      final jsonString = content.substring(startIndex, endIndex + 1);
      return jsonDecode(jsonString);
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
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
        'systemMessage': 'You are an expert ATS consultant.',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'];
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception('Failed to check ATS score: ${errorData['error']}');
    }
  }
}

class InsufficientCreditsException implements Exception {
  @override
  String toString() => 'Insufficient Credits';
}

final atsCheckControllerProvider =
    StateNotifierProvider<ATSCheckController, AsyncValue<ATSScoreModel?>>(
        (ref) {
  return ATSCheckController(ref);
});

final userATSChecksProvider = FutureProvider<List<ATSScoreModel>>((ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return [];
  return ref.watch(atsRepositoryProvider).getUserATSChecks(user.id);
});
