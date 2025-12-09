import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/constants/languages.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/beautiful_components.dart';
import '../../profile/presentation/profile_controller.dart';
import 'cv_controller.dart';
import 'widgets/personal_info_fields.dart';

class GenerateCVScreen extends ConsumerStatefulWidget {
  const GenerateCVScreen({super.key});

  @override
  ConsumerState<GenerateCVScreen> createState() => _GenerateCVScreenState();
}

class _GenerateCVScreenState extends ConsumerState<GenerateCVScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _customNotesController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-fill personal info from profile
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
    _customNotesController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cvState = ref.watch(cvControllerProvider);
    final theme = Theme.of(context);

    ref.listen(cvControllerProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        // Navigate to preview
        context.push('/cv-preview', extra: next.value);
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
        title: Text(l10n.generateCV),
        elevation: 0,
      ),
      body: cvState.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.heroGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Crafting your perfect CV...',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI is analyzing your profile',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ).animate().fadeIn().scale(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section with Gradient
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: AppTheme.heroGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppTheme.primaryIndigo.withValues(alpha: 0.3),
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
                              Icons.rocket_launch_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.createYourCV,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.generateCVDescription,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2),

                    const SizedBox(height: 32),

                    // Section 1: Personal Information
                    _buildSection(
                      context,
                      title: '1. Personal Information',
                      subtitle: 'Your contact details',
                      icon: Icons.person_outline_rounded,
                      color: AppTheme.primaryIndigo,
                      child: PersonalInfoFields(
                        fullNameController: _fullNameController,
                        emailController: _emailController,
                        addressController: _phoneController,
                        phoneController: _phoneController,
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),

                    const SizedBox(height: 24),

                    // Section 2: Job Target
                    _buildSection(
                      context,
                      title: '2. Job Target',
                      subtitle: 'What position are you aiming for?',
                      icon: Icons.work_outline_rounded,
                      color: AppTheme.primaryViolet,
                      child: TextFormField(
                        controller: _jobTitleController,
                        decoration: InputDecoration(
                          labelText: l10n.targetJobTitle,
                          hintText: l10n.jobTitleHint,
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? l10n.required : null,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),

                    const SizedBox(height: 24),

                    // Section 3: Additional Information (Optional)
                    _buildSection(
                      context,
                      title: '3. Additional Information',
                      subtitle: 'Optional extra details the AI should know',
                      icon: Icons.lightbulb_outline_rounded,
                      color: AppTheme.accentCyan,
                      isOptional: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _customNotesController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Additional Details',
                              hintText:
                                  'e.g., I have 2 years at XYZ Company, I speak French at intermediate level...',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 60),
                                child: Icon(Icons.edit_note_rounded),
                              ),
                              helperText:
                                  'AI will intelligently add this to relevant sections',
                              helperMaxLines: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.accentCyan.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    AppTheme.accentCyan.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppTheme.accentCyan,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'AI will automatically place each detail in the appropriate CV section',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.accentCyan,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),

                    const SizedBox(height: 24),

                    // Section 4: Language
                    _buildSection(
                      context,
                      title: '4. Target Language',
                      subtitle: 'Language for your CV',
                      icon: Icons.language_rounded,
                      color: AppTheme.accentEmerald,
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
                      text: l10n.generateCVButton,
                      icon: Icons.auto_awesome_rounded,
                      onPressed: _generateCV,
                      isFullWidth: true,
                      backgroundColor: AppTheme.primaryIndigo,
                    ).animate().fadeIn(delay: 500.ms).scale(),

                    const SizedBox(height: 16),

                    // Info text
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
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
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
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
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isOptional) ...[
                          const SizedBox(width: 8),
                          BeautifulBadge(
                            text: 'Optional',
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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

  void _generateCV() async {
    if (_formKey.currentState!.validate()) {
      final l10n = AppLocalizations.of(context)!;
      final theme = Theme.of(context);

      // Show beautiful confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.heroGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.confirmGeneration,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.confirmGenerationMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AnimatedButton(
                        text: l10n.generateCV,
                        icon: Icons.check_rounded,
                        onPressed: () => Navigator.of(context).pop(true),
                        backgroundColor: AppTheme.primaryIndigo,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      // If confirmed, proceed with generation
      if (confirmed == true && mounted) {
        ref.read(cvControllerProvider.notifier).generateCV(
              jobTitle: _jobTitleController.text.trim(),
              targetLanguage: _selectedLanguage,
              fullName: _fullNameController.text.trim(),
              email: _emailController.text.trim(),
              address: _addressController.text.trim(),
              phone: _phoneController.text.trim(),
              customNotes: _customNotesController.text.trim().isNotEmpty
                  ? _customNotesController.text.trim()
                  : null,
            );
      }
    }
  }
}
