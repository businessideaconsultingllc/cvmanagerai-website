import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/constants/languages.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/beautiful_components.dart';
import '../../../core/utils/responsive.dart';
import '../../cv/domain/cv_model.dart';
import 'cv_controller.dart';
import 'widgets/categorized_cv_selector.dart';

class OptimizeCVScreen extends ConsumerStatefulWidget {
  const OptimizeCVScreen({super.key});

  @override
  ConsumerState<OptimizeCVScreen> createState() => _OptimizeCVScreenState();
}

class _OptimizeCVScreenState extends ConsumerState<OptimizeCVScreen> {
  String? _fileName;
  String _selectedLanguage = 'en';
  CVModel? _selectedCV;
  bool _isExtracting = false;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _fileName = file.name;
          _isExtracting = true;
        });

        String content = '';
        if (file.extension == 'txt' && file.bytes != null) {
          content = String.fromCharCodes(file.bytes!);
        }

        if (content.isNotEmpty && mounted) {
          // Immediately optimize the uploaded file
          setState(() => _isExtracting = false);
          ref.read(cvControllerProvider.notifier).optimizeCV(
                content,
                targetLanguage: _selectedLanguage,
              );
        } else {
          if (mounted) {
            setState(() => _isExtracting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error reading file content'),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExtracting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _optimize() {
    if (_selectedCV == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a CV to optimize'),
          backgroundColor: AppTheme.warningOrange,
        ),
      );
      return;
    }

    final cvContent = jsonEncode(_selectedCV!.data.toMap());
    ref.read(cvControllerProvider.notifier).optimizeCV(
          cvContent,
          targetLanguage: _selectedLanguage,
        );
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
        title: Text(l10n.optimizeCV),
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
                          AppTheme.primaryViolet,
                          AppTheme.primaryPink,
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
                    'Optimizing your CV...',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI is enhancing your content',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ).animate().fadeIn().scale(),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryViolet,
                          AppTheme.primaryPink,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryViolet.withValues(alpha: 0.3),
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
                            Icons.auto_fix_high_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.optimizeCV,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.optimizeCVDescription,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 32),

                  // Section 1: CV Source
                  _buildSection(
                    context,
                    title: '1. Choose CV Source',
                    subtitle: 'Select existing CV to optimize',
                    icon: Icons.file_upload_outlined,
                    color: AppTheme.primaryViolet,
                    child: CategorizedCVSelector(
                      selectedCV: _selectedCV,
                      onCVSelected: (cv) {
                        setState(() {
                          _selectedCV = cv;
                        });
                      },
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),

                  const SizedBox(height: 24),

                  // OR Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // Section 2: Upload File
                  _buildSection(
                    context,
                    title: '2. Upload CV File',
                    subtitle: 'Upload TXT file (optimizes immediately)',
                    icon: Icons.cloud_upload_outlined,
                    color: AppTheme.accentCyan,
                    isOptional: true,
                    child: OutlinedButton.icon(
                      onPressed: _isExtracting ? null : _pickFile,
                      icon: _isExtracting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_file_rounded),
                      label: Text(
                        _fileName ?? 'Upload TXT file',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        side: BorderSide(color: AppTheme.accentCyan, width: 2),
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),

                  const SizedBox(height: 24),

                  // Section 3: Language
                  _buildSection(
                    context,
                    title: '3. Target Language',
                    subtitle: 'Output language for optimized CV',
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

                  // Optimize Button
                  AnimatedButton(
                    text: l10n.optimizeCV,
                    icon: Icons.auto_fix_high_rounded,
                    onPressed: _optimize,
                    isFullWidth: true,
                    backgroundColor: AppTheme.primaryViolet,
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
}
