import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/constants/languages.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/beautiful_components.dart';
import '../../../core/utils/responsive.dart';
import '../../cv/presentation/widgets/cv_input_selector.dart';
import '../../cv/presentation/widgets/personal_info_fields.dart';
import '../../profile/presentation/profile_controller.dart';
import 'cover_letter_controller.dart';

class GenerateCoverLetterScreen extends ConsumerStatefulWidget {
  const GenerateCoverLetterScreen({super.key});

  @override
  ConsumerState<GenerateCoverLetterScreen> createState() =>
      _GenerateCoverLetterScreenState();
}

class _GenerateCoverLetterScreenState
    extends ConsumerState<GenerateCoverLetterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedLanguage = 'en';
  String? _cvContent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileAsync = ref.read(profileProvider);
      profileAsync.whenData((profile) {
        if (profile != null) {
          setState(() {
            _fullNameController.text =
                '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'
                    .trim();
            _emailController.text = profile['email'] ?? '';
            _addressController.text = profile['address'] ?? '';
            _phoneController.text = profile['phone'] ?? '';
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyNameController.dispose();
    _jobDescriptionController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onCVSelected(String content) {
    setState(() {
      _cvContent = content;
    });
  }

  void _generate() {
    if (_formKey.currentState!.validate()) {
      ref.read(coverLetterControllerProvider.notifier).generateCoverLetter(
            jobTitle: _jobTitleController.text.trim(),
            companyName: _companyNameController.text.trim(),
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            address: _addressController.text.trim(),
            phone: _phoneController.text.trim(),
            jobDescription: _jobDescriptionController.text.trim(),
            cvContent: _cvContent,
            targetLanguage: _selectedLanguage,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final coverLetterState = ref.watch(coverLetterControllerProvider);
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);

    ref.listen(coverLetterControllerProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        context.push('/cover-letter-preview', extra: next.value);
      } else if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.coverLetter),
        elevation: 0,
      ),
      body: coverLetterState.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentEmerald,
                          AppTheme.accentCyan,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Crafting your cover letter...',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI is writing a compelling letter',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ).animate().fadeIn().scale(),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentEmerald,
                            AppTheme.accentCyan,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppTheme.accentEmerald.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.mail_outline_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.coverLetter,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.coverLetterDescription,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2),

                    const SizedBox(height: 32),

                    // Section 1: Personal Info
                    _buildSection(
                      context,
                      title: '1. Personal Information',
                      subtitle: 'Your contact details',
                      icon: Icons.person_outline_rounded,
                      color: AppTheme.accentEmerald,
                      child: PersonalInfoFields(
                        fullNameController: _fullNameController,
                        emailController: _emailController,
                        addressController: _addressController,
                        phoneController: _phoneController,
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),

                    const SizedBox(height: 24),

                    // Section 2: Job Details
                    _buildSection(
                      context,
                      title: '2. Job Details',
                      subtitle: 'Target position information',
                      icon: Icons.work_outline_rounded,
                      color: AppTheme.primaryViolet,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _jobTitleController,
                            decoration: InputDecoration(
                              labelText: l10n.targetJobTitle,
                              hintText: 'e.g. Senior Software Engineer',
                              prefixIcon: const Icon(Icons.badge_outlined),
                            ),
                            validator: (value) =>
                                value?.isEmpty ?? true ? l10n.required : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _companyNameController,
                            decoration: InputDecoration(
                              labelText: l10n.companyName,
                              hintText: 'e.g. Google Inc.',
                              prefixIcon: const Icon(Icons.business_outlined),
                            ),
                            validator: (value) =>
                                value?.isEmpty ?? true ? l10n.required : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _jobDescriptionController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: l10n.jobDescription,
                              hintText: 'Paste the job description here...',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 80),
                                child: Icon(Icons.description_outlined),
                              ),
                            ),
                            validator: (value) =>
                                value?.isEmpty ?? true ? l10n.required : null,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),

                    const SizedBox(height: 24),

                    // Section 3: Provide Your CV (Optional)
                    _buildSection(
                      context,
                      title: '3. Provide Your CV',
                      subtitle: 'Optional: Use CV for context (recommended)',
                      icon: Icons.assignment_outlined,
                      color: AppTheme.accentCyan,
                      isOptional: true,
                      child: CVInputSelector(
                        onCVSelected: _onCVSelected,
                        showSelectOption: true,
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                    const SizedBox(height: 24),

                    // Section 4: Language
                    _buildSection(
                      context,
                      title: '4. Target Language',
                      subtitle: 'Language for your cover letter',
                      icon: Icons.language_rounded,
                      color: AppTheme.primaryIndigo,
                      child: DropdownButtonFormField<String>(
                        value: _selectedLanguage,
                        decoration: InputDecoration(
                          labelText: l10n.targetLanguage,
                          prefixIcon: const Icon(Icons.translate_rounded),
                        ),
                        items: AppLanguages.supportedLanguages.entries
                            .map((entry) => DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value!;
                          });
                        },
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),

                    const SizedBox(height: 40),

                    // Generate Button
                    AnimatedButton(
                      text: 'Generate Cover Letter',
                      icon: Icons.auto_awesome_rounded,
                      onPressed: _generate,
                      isFullWidth: true,
                      backgroundColor: AppTheme.accentEmerald,
                    ).animate().fadeIn(delay: 500.ms).scale(),

                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        'This will use 1 credit',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget child,
    bool isOptional = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isOptional) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Optional',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
