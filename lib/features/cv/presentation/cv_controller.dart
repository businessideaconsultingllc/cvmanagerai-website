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

  Future<void> optimizeCV(
    String content, {
    String targetLanguage = 'en',
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
            'Insufficient credits. You need 1 credit to optimize a CV.');
      }

      final customNotesSection = customNotes != null && customNotes.isNotEmpty
          ? '''
      
      ADDITIONAL INFORMATION OR REQUESTS PROVIDED BY USER:
      $customNotes
      
      IMPORTANT: Please incorporate the above requests or information into the optimized CV where appropriate.
      '''
          : '';

      // Construct prompt for DeepSeek
      final prompt = '''
      You are an expert CV writer specializing in ATS (Applicant Tracking System) optimization. 
      Your task is to OPTIMIZE the existing CV content to achieve a PERFECT ATS score (90-100%).
      
      TARGET LANGUAGE: $targetLanguage
      
      ORIGINAL CV CONTENT:
      $content
      $customNotesSection
      
      MANDATORY ATS COMPATIBILITY RULES (AI EVALUATION CRITERIA):
      Your output will be graded against the following 7 categories. Each MUST be perfected:
      1. SECTION HEADERS: Use professional headers like "Work Experience", "Education", "Skills", "Professional Summary", "Certificates", "Languages", and descriptive titles for any additional sections.
      2. CONTACT INFO: Ensure Email, Phone, and Name are clearly extracted.
      3. PROFESSIONAL SUMMARY: Rewrite to be keyword-rich and focused on impact.
      4. ACTION VERBS: Every single bullet point MUST begin with a strong, action verb.
      5. QUANTIFIABLE METRICS: Include metrics (%, \$, or numbers) where possible.
      6. SKILLS CLARITY: Categorize skills clearly (e.g., Technical, Soft Skills).
      7. FORMATTING & DATES: Use clean text and "Month Year - Month Year" or "Month Year - Present" format.
      
      CRITICAL INSTRUCTIONS:
      - PRESERVE FACTUAL DATA: Keep all names, companies, and schools exactly as provided.
      - INCORPORATE USER NOTES: If mandatory fixes or additional notes are provided above, you MUST prioritize fixing those specific issues.
      - CUSTOM SECTIONS: Identify additional sections in the original CV (like Projects, Volunteering, etc.) and include them in "customSections". Each section must have a title and a list of items with title, subtitle, date, and description.
      - BULLET POINTS: Use ONLY the '-' character for bullet points. Separate them with newline characters (\\n).
      
      Return ONLY valid JSON matching this exact structure:
      {
        "personalInfo": {
          "firstName": "...",
          "lastName": "...",
          "email": "...",
          "phone": "...",
          "address": "...",
          "linkedin": "...",
          "website": "..."
        },
        "summary": "Impactful summary in $targetLanguage.",
        "experience": [
          {
            "jobTitle": "...",
            "company": "...",
            "startDate": "...",
            "endDate": "...",
            "description": "- Action Verb + Task + Impact\\n- Action Verb + Task + Metric"
          }
        ],
        "education": [
          {
            "degree": "...",
            "school": "...",
            "startDate": "...",
            "endDate": "...",
            "description": "..."
          }
        ],
        "certificates": [
          {
            "name": "...",
            "issuer": "...",
            "date": "...",
            "description": "..."
          }
        ],
        "skills": ["Skill 1", "Skill 2"],
        "languages": ["Language 1"],
        "customSections": [
          {
            "title": "Section Title (e.g. Projects)",
            "items": [
              {
                "title": "Item Title",
                "subtitle": "Subtitle/Context",
                "date": "Date Range",
                "description": "- Action Verb + Impact"
              }
            ]
          }
        ]
      }
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
      You are an expert CV writer. Your task is to TAILOR the existing CV content to match a specific Job Description and achieve an ATS score > 95%.
      
      TARGET LANGUAGE: $targetLanguage
      
      JOB DESCRIPTION:
      $jobDescription
      
      ORIGINAL CV CONTENT:
      $cvContent
      
      MANDATORY ATS COMPATIBILITY RULES (AI EVALUATION CRITERIA):
      Your output will be graded against the following 7 categories. Each MUST be perfected:
      1. SECTION HEADERS: Use professional headers like "Work Experience", "Education", "Skills", "Professional Summary", "Certificates", "Languages", and descriptive titles for any additional sections.
      2. CONTACT INFO: Ensure all personal details are kept accurately.
      3. PROFESSIONAL SUMMARY: Tailor to include top job-specific keywords.
      4. ACTION VERBS: Start every bullet point with a strong, job-relevant action verb.
      5. QUANTIFIABLE IMPACT: Include metrics (%, \$, or numbers) where possible.
      6. SKILLS CLARITY: Prioritize skills mentioned in the job description and categorize them.
      7. FORMATTING & DATES: Use clean text and "Month Year - Month Year" format.
      
      CRITICAL INSTRUCTIONS:
      - KEYWORD MAPPING: Identify the top 10 keywords in the job description and weave them naturally into the summary and experience.
      - CUSTOM SECTIONS: Identify additional sections in the original CV (like Projects, Volunteering, etc.) and include them/tailor them in "customSections". Each section must have a title and a list of items with title, subtitle, date, and description.
      - BULLET POINTS: Use ONLY '-' character, separated by \\n.
      
      Return ONLY valid JSON matching this exact structure:
      {
        "personalInfo": {
          "firstName": "...",
          "lastName": "...",
          "email": "...",
          "phone": "...",
          "address": "...",
          "linkedin": "...",
          "website": "..."
        },
        "summary": "Tailored summary in $targetLanguage.",
        "experience": [
          {
            "jobTitle": "...",
            "company": "...",
            "startDate": "...",
            "endDate": "...",
            "description": "- Action Verb + Keyword + Result\\n- Action Verb + Task + Metric"
          }
        ],
        "education": [
          {
            "degree": "...",
            "school": "...",
            "startDate": "...",
            "endDate": "...",
            "description": "..."
          }
        ],
        "certificates": [
          {
            "name": "...",
            "issuer": "...",
            "date": "...",
            "description": "..."
          }
        ],
        "skills": ["JD Keywords", "Hard Skills", "Soft Skills"],
        "languages": ["Language 1"],
        "customSections": [
          {
            "title": "Section Title (e.g. Projects)",
            "items": [
              {
                "title": "Item Title",
                "subtitle": "Subtitle/Context",
                "date": "Date Range",
                "description": "- Action Verb + Keyword + Result"
              }
            ]
          }
        ]
      }
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
    - Projects/Volunteer/Other → Add to customSections
    '''
        : '';

    return '''
    You are an expert CV writer specializing in ATS (Applicant Tracking System) optimization. 
    Generate a professional CV for the candidate targeting the role of $jobTitle.
    The goal is to achieve an ATS score above 95%.
    
    TARGET LANGUAGE: $targetLanguage
    
    CANDIDATE DETAILS:
    Name: ${profile['first_name']} ${profile['last_name']}
    Email: ${profile['email']}
    Phone: ${profile['phone']}
    Address: ${profile['address']}
    
    TARGET JOB: $jobTitle$customNotesSection
    
    MANDATORY ATS COMPATIBILITY RULES (AI EVALUATION CRITERIA):
    Your output will be graded against the following 7 categories. Each MUST be perfected:
    1. SECTION HEADERS: Use professional headers like "Work Experience", "Education", "Skills", "Professional Summary", "Certificates", "Languages", and descriptive titles for any additional sections.
    2. CONTACT INFO: Include all provided candidate details.
    3. PROFESSIONAL SUMMARY: Tailored to $jobTitle, highlighting value and impact.
    4. ACTION VERBS: Every bullet point MUST begin with a strong action verb.
    5. QUANTIFIABLE IMPACT: Include metrics (%, \$, or numbers) where possible.
    6. SKILLS CLARITY: Categorized list of technical and soft skills.
    7. FORMATTING & DATES: Clean "-" bullets and "Month Year - Month Year" format.
    
    Return ONLY valid JSON matching this exact structure:
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
      "summary": "Impactful professional summary in $targetLanguage.",
      "experience": [
        {
          "jobTitle": "Job Title",
          "company": "Company Name",
          "startDate": "Month Year",
          "endDate": "Month Year or Present",
          "description": "- Action Verb + Achievement + Metric\\n- Action Verb + Responsibility + Quantifiable Result"
        }
      ],
      "education": [
        {
          "degree": "Degree",
          "school": "University",
          "startDate": "Month Year",
          "endDate": "Month Year",
          "description": ""
        }
      ],
      "certificates": [
        {
          "name": "Cert Name",
          "issuer": "Issuer",
          "date": "Date",
          "description": ""
        }
      ],
      "skills": ["Skill 1", "Skill 2"],
      "languages": ["Language Name"],
      "customSections": [
        {
          "title": "Section Title",
          "items": [
            {
              "title": "Item Title",
              "subtitle": "Subtitle",
              "date": "Date",
              "description": ""
            }
          ]
        }
      ]
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
