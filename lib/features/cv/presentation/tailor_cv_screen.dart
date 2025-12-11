import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/constants/languages.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/beautiful_components.dart';
import '../../../core/utils/responsive.dart';
import 'cv_controller.dart';
import 'widgets/cv_input_selector.dart';

class TailorCVScreen extends ConsumerStatefulWidget {
  const TailorCVScreen({super.key});

  @override
  ConsumerState<TailorCVScreen> createState() => _TailorCVScreenState();
}

class _TailorCVScreenState extends ConsumerState<TailorCVScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobDescriptionController = TextEditingController();
  final _targetJobTitleController = TextEditingController();
  String _selectedLanguage = 'en';
  String? _cvContent;

  @override
  void dispose() {
    _jobDescriptionController.dispose();
    _targetJobTitleController.dispose();
    super.dispose();
  }

  void _onCVSelected(String content) {
    setState(() {
      _cvContent = content;
    });
  }

  void _tailor() {
    if (_formKey.currentState!.validate()) {
      if (_cvContent == null || _cvContent!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please provide your CV using one of the methods above'),
            backgroundColor: AppTheme.warningOrange,
          ),
        );
        return;
      }

      ref.read(cvControllerProvider.notifier).tailorCV(
            cvContent: _cvContent!,
            jobDescription: _jobDescriptionController.text.trim(),
            targetLanguage: _selectedLanguage,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cvState = ref.watch(cvControllerProvider);
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);

    ref.listen(cvControllerProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
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
        title: Text(l10n.tailorCV),
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
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentCyan,
                          AppTheme.accentEmerald,
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
                    'Tailoring your CV...',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI is customizing for the job',
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
                            AppTheme.accentCyan,
                            AppTheme.accentEmerald,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentCyan.withValues(alpha: 0.3),
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
                              Icons.tune_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.tailorCV,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.tailorCVDescription,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2),

                    const SizedBox(height: 32),

                    // Section 1: Provide Your CV
                    _buildSection(
                      context,
                      title: '1. Provide Your CV',
                      subtitle: 'Choose how you want to provide your CV',
                      icon: Icons.assignment_outlined,
                      color: AppTheme.accentCyan,
                      child: CVInputSelector(
                        onCVSelected: _onCVSelected,
                        showSelectOption: true,
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),

                    const SizedBox(height: 24),

                    // Section 2: Job Description
                    _buildSection(
                      context,
                      title: '2. Job Description',
                      subtitle: 'Paste the job description to tailor your CV',
                      icon: Icons.work_outline_rounded,
                      color: AppTheme.primaryViolet,
                      child: TextFormField(
                        controller: _jobDescriptionController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          labelText: l10n.jobDescription,
                          hintText: 'Paste the full job description here...',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 120),
                            child: Icon(Icons.description_outlined),
                          ),
                          helperText:
                              'Paste the full job description for best results',
                          helperMaxLines: 2,
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? l10n.required : null,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),

                    const SizedBox(height: 24),

                    // Section 3: Language
                    _buildSection(
                      context,
                      title: '3. Target Language',
                      subtitle: 'Output language for tailored CV',
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
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),

                    const SizedBox(height: 40),

                    // Tailor Button
                    AnimatedButton(
                      text: l10n.tailorCV,
                      icon: Icons.tune_rounded,
                      onPressed: _tailor,
                      isFullWidth: true,
                      backgroundColor: AppTheme.accentCyan,
                    ).animate().fadeIn(delay: 400.ms).scale(),

                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        'This will use 2 credits',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms),

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
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
}
