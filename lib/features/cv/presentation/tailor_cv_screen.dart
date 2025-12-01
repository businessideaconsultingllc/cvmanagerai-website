import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/constants/languages.dart';
import '../../../core/utils/pdf_text_extractor.dart';
import '../../../core/theme/app_theme.dart';
import '../../cv/domain/cv_model.dart';
import 'cv_controller.dart';
import 'widgets/categorized_cv_selector.dart';

class TailorCVScreen extends ConsumerStatefulWidget {
  const TailorCVScreen({super.key});

  @override
  ConsumerState<TailorCVScreen> createState() => _TailorCVScreenState();
}

class _TailorCVScreenState extends ConsumerState<TailorCVScreen> {
  final _cvContentController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  String? _fileName;
  String? _fileContent;
  String _selectedLanguage = 'en';
  bool _isExtracting = false;
  CVModel? _selectedCV;
  String? _selectedCVContent;

  @override
  void dispose() {
    _cvContentController.dispose();
    _jobDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _fileContent = null;
        _isExtracting = true;
        // Clear other inputs
        _selectedCV = null;
        _selectedCVContent = null;
      });

      try {
        // Extract text from the file
        final extension = result.files.single.extension ?? '';
        final text = await CVFileExtractor.extractText(
          fileExtension: extension,
          filePath: result.files.single.path,
          bytes: result.files.single.bytes,
        );

        setState(() {
          _fileContent = text;
          _isExtracting = false;
        });

        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.successfullyExtractedText(_fileName ?? '')),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isExtracting = false;
          _fileName = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _tailor() {
    // Determine source of CV content
    String? cvContent;
    if (_cvContentController.text.isNotEmpty) {
      cvContent = _cvContentController.text;
    } else if (_fileContent != null) {
      cvContent = _fileContent;
    } else if (_selectedCVContent != null) {
      cvContent = _selectedCVContent;
    }

    final jobDescription = _jobDescriptionController.text;

    if (cvContent == null || cvContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .provideCVContentUploadPasteOrSelect),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (jobDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.provideJobDescription),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(cvControllerProvider.notifier).tailorCV(
          cvContent: cvContent,
          jobDescription: jobDescription,
          targetLanguage: _selectedLanguage,
        );
  }

  @override
  Widget build(BuildContext context) {
    final cvState = ref.watch(cvControllerProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(cvControllerProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        context.push('/cv-preview', extra: next.value);
      } else if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tailorCV)),
      body: cvState.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    l10n.tailoringYourCV,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    l10n.matchingSkillsToJobDesc,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.tailorCVDescription,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ).animate().fadeIn(),
                  const SizedBox(height: 24),

                  // Categorized CV Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.selectFromLibrary,
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
                              _selectedCVContent = jsonEncode(cv.data.toMap());
                              // Clear other inputs
                              _fileName = null;
                              _fileContent = null;
                              _cvContentController.clear();
                            } else {
                              _selectedCVContent = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: theme.dividerColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              l10n.or,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: theme.dividerColor)),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ).animate().fadeIn(delay: 50.ms),

                  // File Upload Section
                  _buildUploadSection(theme, l10n)
                      .animate()
                      .fadeIn(delay: 100.ms),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Divider(color: theme.dividerColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.orPasteCVContent,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: theme.dividerColor)),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 24),

                  TextField(
                    controller: _cvContentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: l10n.pasteCVContentHere,
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          _selectedCV = null;
                          _selectedCVContent = null;
                          _fileName = null;
                          _fileContent = null;
                        });
                      }
                    },
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 32),
                  Text(
                    l10n.jobDescription,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _jobDescriptionController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: l10n.pasteJobDescriptionHere,
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: InputDecoration(
                      labelText: l10n.targetLanguage,
                      prefixIcon: Icon(Icons.language),
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
                      onPressed: _tailor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.tune, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            l10n.tailorMyCVButton,
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
    );
  }

  Widget _buildUploadSection(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: _fileContent != null
              ? Colors.green.withValues(alpha: 0.5)
              : theme.dividerColor,
          width: _fileContent != null ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_isExtracting)
            Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  l10n.extractingTextFromFile,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _fileContent != null
                    ? Colors.green.withValues(alpha: 0.1)
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _fileContent != null
                    ? Icons.check_circle_outline
                    : Icons.cloud_upload_outlined,
                size: 40,
                color: _fileContent != null
                    ? Colors.green
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _fileName ?? l10n.selectPDForTXT,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _fileContent != null ? Colors.green : null,
              ),
              textAlign: TextAlign.center,
            ),
            if (_fileContent != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.textExtractedSuccessfully,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _pickFile,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _fileContent != null
                      ? Colors.green
                      : theme.colorScheme.primary,
                ),
                foregroundColor: _fileContent != null
                    ? Colors.green
                    : theme.colorScheme.primary,
              ),
              child: Text(
                  _fileContent != null ? l10n.changeFile : l10n.browseFiles),
            ),
          ],
        ],
      ),
    );
  }
}
