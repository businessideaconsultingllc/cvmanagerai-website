import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/languages.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/beautiful_components.dart';
import '../../../core/utils/responsive.dart';
import 'cv_controller.dart';
import 'widgets/cv_input_selector.dart';
import '../../../core/widgets/credit_deduction_dialog.dart';
import '../../activities/data/activity_repository.dart';

class OptimizeCVScreen extends ConsumerStatefulWidget {
  final String? initialNotes;
  const OptimizeCVScreen({super.key, this.initialNotes});

  @override
  ConsumerState<OptimizeCVScreen> createState() => _OptimizeCVScreenState();
}

class _OptimizeCVScreenState extends ConsumerState<OptimizeCVScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customNotesController = TextEditingController(); // NEW
  late FocusNode _focusNode;
  final ScrollController _scrollController = ScrollController();
  String _selectedLanguage = 'en';
  String? _cvContent;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    if (widget.initialNotes != null) {
      _customNotesController.text = widget.initialNotes!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _customNotesController.dispose(); // NEW
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onCVSelected(String content) {
    setState(() {
      _cvContent = content;
    });
  }

  void _optimize() {
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

      final l10n = AppLocalizations.of(context)!;
      showDialog<bool>(
        context: context,
        builder: (context) => CreditDeductionDialog(
          title: l10n.optimizeCV,
          message: l10n.confirmOptimizeCVCost,
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
        ),
      ).then((confirmed) {
        if (confirmed == true && mounted) {
          ref.read(cvControllerProvider.notifier).optimizeCV(
                _cvContent!,
                targetLanguage: _selectedLanguage,
                customNotes:
                    _customNotesController.text.trim().isNotEmpty // NEW
                        ? _customNotesController.text.trim()
                        : null,
              );
        }
      });
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
        // Log activity
        ref.read(activityRepositoryProvider).logActivity(
          activityType: 'optimize_cv',
          details: {
            'language': _selectedLanguage,
            'has_custom_notes': _customNotesController.text.isNotEmpty,
          },
        );

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent || event is KeyRepeatEvent) {
            final double scrollAmount = 100.0;
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.offset + scrollAmount,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                );
                return KeyEventResult.handled;
              }
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.offset - scrollAmount,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                );
                return KeyEventResult.handled;
              }
            }
          }
          return KeyEventResult.ignored;
        },
        child: cvState.isLoading
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
                controller: _scrollController,
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
                              AppTheme.primaryViolet,
                              AppTheme.primaryPink,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.primaryViolet.withValues(alpha: 0.3),
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

                      // Section 1: Provide Your CV
                      _buildSection(
                        context,
                        title: '1. Provide Your CV',
                        subtitle: 'Choose how you want to provide your CV',
                        icon: Icons.assignment_outlined,
                        color: AppTheme.primaryViolet,
                        child: CVInputSelector(
                          onCVSelected: _onCVSelected,
                          showSelectOption: true,
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

                      const SizedBox(height: 24),

                      // Section 2: Additional Information (Optional)
                      _buildSection(
                        context,
                        title: '2. Additional Information',
                        subtitle:
                            'Optional extra details needed for optimization',
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
                                    'e.g., Change start date of last job to Jan 2022, Add Project Management to skills...',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 60),
                                  child: Icon(Icons.edit_note_rounded),
                                ),
                                helperText:
                                    'AI will follow these instructions while optimizing',
                                helperMaxLines: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.accentCyan.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.accentCyan
                                      .withValues(alpha: 0.3),
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
                                      'AI will incorporate these notes into your optimized CV',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
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
                      ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.2),

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
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),

                      const SizedBox(height: 40),

                      // Optimize Button
                      AnimatedButton(
                        text: l10n.optimizeCV,
                        icon: Icons.auto_fix_high_rounded,
                        onPressed: _optimize,
                        isFullWidth: true,
                        backgroundColor: AppTheme.primaryViolet,
                      ).animate().fadeIn(delay: 300.ms).scale(),

                      const SizedBox(height: 16),

                      Center(
                        child: Text(
                          'This will use 2 credits',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 40),
                    ],
                  ),
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
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 2,
        ),
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
                          style: theme.textTheme.titleMedium?.copyWith(
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
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Optional',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
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
