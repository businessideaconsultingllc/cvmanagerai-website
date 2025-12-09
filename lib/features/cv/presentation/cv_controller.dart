import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/data/auth_repository.dart';

import '../../credits/presentation/credits_provider.dart';
import '../../profile/data/profile_repository.dart';
import '../data/cv_repository.dart';
import '../domain/cv_model.dart';

class CVController extends StateNotifier<AsyncValue<CVModel?>> {
  final Ref _ref;

  CVController(this._ref) : super(const AsyncValue.data(null));

  Future<void> generateCV({
    required String jobTitle,
    required String fullName,
    required String email,
    String targetLanguage = 'en',
    String? address,
    String? phone,
    String? customNotes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      // Check if user has credits
      final creditService = _ref.read(creditServiceProvider);
      final hasCredits = await creditService.hasCredits(user.id);
      if (!hasCredits) {
        throw Exception(
            'Insufficient credits. You need 1 credit to generate a CV.');
      }

      // Fetch user profile for work experience context only
      final profileRepo = _ref.read(profileRepositoryProvider);
      final profile = await profileRepo.getProfile(user.id);

      if (profile == null) throw Exception('Profile not found');

      // Create modified profile with provided personal info
      final modifiedProfile = Map<String, dynamic>.from(profile);
      final nameParts = fullName.trim().split(' ');
      modifiedProfile['first_name'] =
          nameParts.isNotEmpty ? nameParts.first : '';
      modifiedProfile['last_name'] =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      modifiedProfile['email'] = email;
      modifiedProfile['address'] = address ?? '';
      modifiedProfile['phone'] = phone ?? '';

      // Construct prompt for DeepSeek
      final prompt = _buildPrompt(
        profile: modifiedProfile,
        jobTitle: jobTitle,
        targetLanguage: targetLanguage,
        customNotes: customNotes,
      );

      // Call DeepSeek API
      final aiResponseContent = await _callDeepSeekAPI(prompt);

      // Parse response
      final cvDataMap = _parseAIResponse(aiResponseContent);
      final cvData = CVData.fromMap(cvDataMap);

      final cvModel = CVModel(
        id: const Uuid().v4(),
        userId: user.id,
        title: 'CV for $jobTitle',
        data: cvData,
        language: targetLanguage,
        cvType: CVType.generated,
        createdAt: DateTime.now(),
      );

      // Save generated CV to Supabase
      await _ref.read(cvRepositoryProvider).saveCV(cvModel);

      // Deduct credits after successful generation
      await creditService.useCredits(
        userId: user.id,
        operationType: 'generate_cv',
      );

      state = AsyncValue.data(cvModel);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCV(CVModel cv) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(cvRepositoryProvider).updateCV(cv);
      // Invalidate providers to refresh the CV lists
      _ref.invalidate(userCVsProvider);
      _ref.invalidate(generatedCVsProvider);
      _ref.invalidate(optimizedCVsProvider);
      _ref.invalidate(tailoredCVsProvider);
      state = AsyncValue.data(cv);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> optimizeCV(String content,
      {String targetLanguage = 'en'}) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      // Check if user has credits
      final creditService = _ref.read(creditServiceProvider);
      final hasCredits = await creditService.hasCredits(user.id);
      if (!hasCredits) {
        throw Exception(
            'Insufficient credits. You need 1 credit to optimize a CV.');
      }

      // Construct prompt for DeepSeek
      final prompt = '''
      You are an expert CV writer. Your task is to OPTIMIZE the existing CV content provided below.
      
      TARGET LANGUAGE: $targetLanguage
      
      ORIGINAL CV CONTENT:
      $content
      
      CRITICAL INSTRUCTIONS:
      1. PRESERVE ALL EXISTING DATA: You MUST extract and keep all personal information, work experience, education, certificates, skills, and languages from the original content.
      2. DO NOT GENERATE OR INFER: If you cannot find a specific field in the original content, leave it as an empty string. DO NOT create placeholder or fake data.
      3. TRANSLATION REQUIREMENTS:
         - ALL text content (summary, descriptions, skills, education degrees, certificates, languages) MUST be translated to $targetLanguage
         - Translate education degree names (e.g., "Bachelor of Science" → translate to target language)
         - Translate school names ONLY if they are descriptive (e.g., "University of Technology") but keep proper names as-is
         - Translate certificate names and issuers to $targetLanguage
         - Translate ALL skill names to $targetLanguage
         - Translate ALL language names to $targetLanguage (e.g., "English" → translate to target language word for English)
      4. PRESERVE FACTUAL INFORMATION:
         - DO NOT change company names (keep as original)
         - DO NOT change dates
         - Keep personal contact information exactly as-is
         - Keep job titles in their original form OR translate them naturally
      5. OPTIMIZATION FOCUS:
         - Improve grammar and language quality in the TARGET LANGUAGE
         - Make the tone more professional
         - Highlight key achievements with better wording
         - Ensure ATS-friendly formatting
      6. FORMATTING: Ensure 'description' fields are formatted as bullet points separated by newline characters (\\n). Do not use HTML or Markdown tags like <ul> or <li>.
      7. Return ONLY valid JSON matching this exact structure:
      {
        "personalInfo": {
          "firstName": "Extract from original or leave empty",
          "lastName": "Extract from original or leave empty",
          "email": "Extract from original or leave empty",
          "phone": "Extract from original or leave empty",
          "address": "Extract from original or leave empty",
          "linkedin": "Extract from original or leave empty",
          "website": "Extract from original or leave empty"
        },
        "summary": "Optimized summary FULLY TRANSLATED to $targetLanguage",
        "experience": [
          {
            "jobTitle": "Job title from original (translated or kept as-is based on context)",
            "company": "Exact company name from original (keep unchanged)",
            "startDate": "Exact start date from original",
            "endDate": "Exact end date from original",
            "description": "Optimized description FULLY TRANSLATED to $targetLanguage. IMPORTANT: Format as bullet points separated by newline characters (\\n). Example: '- Achievement 1\\n- Achievement 2'"
          }
        ],
        "education": [
          {
            "degree": "Degree name TRANSLATED to $targetLanguage",
            "school": "School name from original (translate if descriptive, keep proper names)",
            "startDate": "Exact start date from original",
            "endDate": "Exact end date from original",
            "description": "Extract from original and TRANSLATE to $targetLanguage, or leave empty"
          }
        ],
        "certificates": [
          {
            "name": "Certificate name TRANSLATED to $targetLanguage",
            "issuer": "Issuer name from original",
            "date": "Exact date from original",
            "description": "Extract from original and TRANSLATE to $targetLanguage, or leave empty"
          }
        ],
        "skills": ["ALL skills TRANSLATED to $targetLanguage"],
        "languages": ["ALL language names TRANSLATED to $targetLanguage (e.g., 'English' becomes target language word for English)"]
      }
      
      REMEMBER: EVERYTHING you write in the response MUST be in $targetLanguage. Your job is to OPTIMIZE existing content AND translate it to the target language.
      ''';

      // Call DeepSeek API
      final aiResponseContent = await _callDeepSeekAPI(prompt);

      // Parse response
      final cvDataMap = _parseAIResponse(aiResponseContent);
      final cvData = CVData.fromMap(cvDataMap);

      final cvModel = CVModel(
        id: const Uuid().v4(),
        userId: user.id,
        title: 'Optimized CV',
        data: cvData,
        language: targetLanguage,
        cvType: CVType.optimized,
        createdAt: DateTime.now(),
      );

      // Save to Supabase
      await _ref.read(cvRepositoryProvider).saveCV(cvModel);

      // Deduct 2 credits after successful optimization
      await creditService.useCredits(
        userId: user.id,
        operationType: 'optimize_cv',
        amount: 2, // Optimize CV costs 2 credits
      );

      state = AsyncValue.data(cvModel);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> tailorCV({
    required String cvContent,
    required String jobDescription,
    String targetLanguage = 'en',
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      // Check if user has credits
      final creditService = _ref.read(creditServiceProvider);
      final hasCredits = await creditService.hasCredits(user.id);
      if (!hasCredits) {
        throw Exception(
            'Insufficient credits. You need 1 credit to tailor a CV.');
      }

      // Construct prompt for DeepSeek
      final prompt = '''
      You are an expert CV writer. Your task is to TAILOR the existing CV content to match a specific Job Description.
      
      TARGET LANGUAGE: $targetLanguage
      
      JOB DESCRIPTION:
      $jobDescription
      
      ORIGINAL CV CONTENT:
      $cvContent
      
      CRITICAL INSTRUCTIONS:
      1. PRESERVE FACTUAL INFORMATION: Keep all dates, company names, and certificate information exactly as they are in the original.
      2. TRANSLATION REQUIREMENTS:
         - ALL text content (summary, descriptions, skills, education degrees, certificates, languages) MUST be translated to $targetLanguage
         - Translate education degree names to $targetLanguage
         - Translate school names ONLY if they are descriptive, keep proper names as-is
         - Translate certificate names and issuers to $targetLanguage
         - Translate ALL skill names to $targetLanguage
         - Translate ALL language names to $targetLanguage (e.g., "English" → translate to target language word for English)
      3. TAILORING REQUIREMENTS:
         - Rewrite the professional summary to highlight skills and experiences relevant to the Job Description
         - Rewrite experience descriptions to emphasize achievements and skills that match the Job Description
         - Incorporate relevant keywords from the Job Description into the summary and experience sections
         - Keep job titles in their original form OR translate them naturally
      4. FORMATTING: Ensure 'description' fields are formatted as bullet points separated by newline characters (\\n). Do not use HTML or Markdown tags like <ul> or <li>.
      5. Return ONLY valid JSON matching this exact structure:
      {
        "personalInfo": {
          "firstName": "Extract from original",
          "lastName": "Extract from original",
          "email": "Extract from original",
          "phone": "Extract from original",
          "address": "Extract from original",
          "linkedin": "Extract from original",
          "website": "Extract from original"
        },
        "summary": "Tailored professional summary FULLY TRANSLATED to $targetLanguage",
        "experience": [
          {
            "jobTitle": "Job title from original (translated or kept as-is based on context)",
            "company": "Exact company name from original (keep unchanged)",
            "startDate": "Exact start date from original",
            "endDate": "Exact end date from original",
            "description": "Tailored description FULLY TRANSLATED to $targetLanguage with keywords. IMPORTANT: Format as bullet points separated by newline characters (\\n)."
          }
        ],
        "education": [
          {
            "degree": "Degree name TRANSLATED to $targetLanguage",
            "school": "School name from original (translate if descriptive, keep proper names)",
            "startDate": "Exact start date from original",
            "endDate": "Exact end date from original",
            "description": "Extract from original and TRANSLATE to $targetLanguage, or leave empty"
          }
        ],
        "certificates": [
          {
            "name": "Certificate name TRANSLATED to $targetLanguage",
            "issuer": "Issuer name from original",
            "date": "Exact date from original",
            "description": "Extract from original and TRANSLATE to $targetLanguage, or leave empty"
          }
        ],
        "skills": ["ALL skills TRANSLATED to $targetLanguage, prioritized based on Job Description relevance"],
        "languages": ["ALL language names TRANSLATED to $targetLanguage (e.g., 'English' becomes target language word for English)"]
      }
      
      REMEMBER: EVERYTHING you write in the response MUST be in $targetLanguage. Your job is to TAILOR existing content to match the job description AND translate it to the target language.
      ''';

      // Call DeepSeek API
      final aiResponseContent = await _callDeepSeekAPI(prompt);

      // Parse response
      final cvDataMap = _parseAIResponse(aiResponseContent);
      final cvData = CVData.fromMap(cvDataMap);

      final cvModel = CVModel(
        id: const Uuid().v4(),
        userId: user.id,
        title: 'Tailored CV',
        data: cvData,
        language: targetLanguage,
        cvType: CVType.tailored,
        createdAt: DateTime.now(),
      );

      // Save to Supabase
      await _ref.read(cvRepositoryProvider).saveCV(cvModel);

      // Deduct 2 credits after successful tailoring
      await creditService.useCredits(
        userId: user.id,
        operationType: 'tailor_cv',
        amount: 2, // Tailor CV costs 2 credits
      );

      state = AsyncValue.data(cvModel);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Map<String, dynamic> _parseAIResponse(String content) {
    try {
      // Find the JSON block in the response
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

  String _buildPrompt({
    required Map<String, dynamic> profile,
    required String jobTitle,
    String targetLanguage = 'en',
    String? customNotes,
  }) {
    final customNotesSection = customNotes != null && customNotes.isNotEmpty
        ? '''
    
    ADDITIONAL INFORMATION PROVIDED BY USER:
    $customNotes
    
    IMPORTANT: Intelligently incorporate the above information into the appropriate CV sections:
    - Work experience → Add to experience section
    - Skills/languages → Add to skills or languages sections  
    - Certifications → Add to certificates section
    - Education → Add to education section
    '''
        : '';

    return '''
    You are an expert CV writer. Generate a professional CV for the following candidate targeting a specific job.
    
    TARGET LANGUAGE: $targetLanguage
    
    CANDIDATE DETAILS:
    Name: ${profile['first_name']} ${profile['last_name']}
    Email: ${profile['email']}
    Phone: ${profile['phone']}
    Address: ${profile['address']}
    
    TARGET JOB: $jobTitle$customNotesSection
    
    INSTRUCTIONS:
    1. Generate ALL content in $targetLanguage.
    2. Create a professional summary tailored to the target job ($jobTitle).
    3. GENERATE relevant key skills for a $jobTitle.
    4. GENERATE a realistic but hypothetical experience summary and bullet points for a $jobTitle (assuming the candidate has relevant experience).
    5. GENERATE a placeholder education section relevant to the role.
    6. GENERATE relevant certificates/certifications for the role.
    7. GENERATE relevant languages for the candidate.
    8. Return ONLY valid JSON matching the following structure:
    {
      "personalInfo": {
        "firstName": "${profile['first_name']}",
        "lastName": "${profile['last_name']}",
        "email": "${profile['email']}",
        "phone": "${profile['phone']}",
        "address": "${profile['address']}",
        "linkedin": "",
        "website": ""
      },
      "summary": "Professional summary here...",
      "experience": [
        {
          "jobTitle": "Job Title",
          "company": "Company Name",
          "startDate": "Start Date",
          "endDate": "End Date",
          "description": "Bullet point 1\\nBullet point 2"
        }
      ],
      "education": [
        {
          "degree": "Degree Name",
          "school": "University Name",
          "startDate": "Start Date",
          "endDate": "End Date",
          "description": "Optional description"
        }
      ],
      "certificates": [
        {
          "name": "Certificate Name",
          "issuer": "Issuing Organization",
          "date": "Issue Date",
          "description": "Optional description"
        }
      ],
      "skills": ["Skill 1", "Skill 2"],
      "languages": ["Language 1"]
    }
    ''';
  }

  Future<String> _callDeepSeekAPI(String prompt,
      {String systemMessage = 'You are an expert CV writer.'}) async {
    final url = Uri.parse(AppConstants.deepSeekEdgeFunctionUrl);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConstants.supabaseAnonKey}',
      },
      body: jsonEncode({
        'prompt': prompt,
        'systemMessage': systemMessage,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'];
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception('Failed to generate CV: ${errorData['error']}');
    }
  }
}

final cvControllerProvider =
    StateNotifierProvider<CVController, AsyncValue<CVModel?>>((ref) {
  return CVController(ref);
});
