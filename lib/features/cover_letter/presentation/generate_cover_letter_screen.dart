import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/languages.dart';
import '../../../core/theme/app_theme.dart';
import '../../cv/domain/cv_model.dart';
import '../../cv/presentation/widgets/categorized_cv_selector.dart';
import 'cover_letter_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  String _selectedLanguage = 'en';
  CVModel? _selectedCV;
  String? _selectedCVContent;

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyNameController.dispose();
    _jobDescriptionController.dispose();
    super.dispose();
  }

  void _generate() {
    if (_formKey.currentState!.validate()) {
      ref.read(coverLetterControllerProvider.notifier).generateCoverLetter(
            jobTitle: _jobTitleController.text,
            companyName: _companyNameController.text,
            jobDescription: _jobDescriptionController.text.isNotEmpty
                ? _jobDescriptionController.text
                : null,
            cvContent: _selectedCVContent,
            targetLanguage: _selectedLanguage,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coverLetterControllerProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(coverLetterControllerProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        context.push('/cover-letter-preview', extra: next.value);
      } else if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: ${next.error}'),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.generateCoverLetter)),
      body: state.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    l10n.generatingCoverLetter,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    l10n.craftingCoverLetter,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.coverLetterDescription,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 24),

                    // Categorized CV Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.selectCVOptional,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CategorizedCVSelector(
                          selectedCV: _selectedCV,
                          onCVSelected: (cv) {
                            setState(() {
                              _selectedCV = cv;
                              if (cv != null) {
                                _selectedCVContent =
                                    jsonEncode(cv.data.toMap());
                              } else {
                                _selectedCVContent = null;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ).animate().fadeIn(delay: 100.ms),

                    TextFormField(
                      controller: _jobTitleController,
                      decoration: InputDecoration(
                        labelText: l10n.jobTitle,
                        prefixIcon: const Icon(Icons.work_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? l10n.pleaseEnterJobTitle : null,
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _companyNameController,
                      decoration: InputDecoration(
                        labelText: l10n.companyName,
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? l10n.pleaseEnterCompanyName : null,
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _jobDescriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.jobDescriptionOptional,
                        hintText: l10n.jobDescriptionHint,
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 5,
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: InputDecoration(
                        labelText: l10n.targetLanguage,
                        prefixIcon: const Icon(Icons.language),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 32),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _generate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              l10n.generateCoverLetterButton,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms).scale(),
                  ],
                ),
              ),
            ),
    );
  }
}
