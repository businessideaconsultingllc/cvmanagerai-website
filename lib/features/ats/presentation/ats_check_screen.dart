import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/beautiful_components.dart';
import '../../../core/utils/responsive.dart';
import '../../cv/presentation/widgets/cv_input_selector.dart';
import 'ats_check_controller.dart';
import '../../../core/widgets/credit_deduction_dialog.dart';
import '../domain/ats_score_model.dart';

class ATSCheckScreen extends ConsumerStatefulWidget {
  const ATSCheckScreen({super.key});

  @override
  ConsumerState<ATSCheckScreen> createState() => _ATSCheckScreenState();
}

class _ATSCheckScreenState extends ConsumerState<ATSCheckScreen> {
  final _scrollController = ScrollController();
  late FocusNode _focusNode;
  String? _cvContent;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onCVSelected(String content) {
    setState(() {
      _cvContent = content;
    });
  }

  void _checkATS() {
    if (_cvContent == null || _cvContent!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.uploadOrPasteCV),
          backgroundColor: AppTheme.warningOrange,
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    showDialog<bool>(
      context: context,
      builder: (context) => CreditDeductionDialog(
        title: l10n.checkATSScore,
        message: l10n.confirmATSCheckCost,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        ref
            .read(atsCheckControllerProvider.notifier)
            .checkATSScore(_cvContent!, targetLanguage: l10n.localeName);
        setState(() {
          _showResults = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final atsState = ref.watch(atsCheckControllerProvider);
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);

    ref.listen(atsCheckControllerProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.atsCheckSuccess),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else if (next.hasError) {
        if (!context.mounted) return;

        final error = next.error;
        String errorMessage;

        if (error is InsufficientCreditsException) {
          errorMessage = l10n.insufficientCreditsATS;
        } else {
          errorMessage = error.toString().replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    });

    // Reset results view if not loading and no value
    if (!atsState.isLoading && !atsState.hasValue && _showResults) {
      // Might want to handle this better
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.checkATSScore),
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
        child: atsState.isLoading
            ? _buildLoadingState(theme, l10n)
            : SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (atsState.hasValue && atsState.value != null)
                      _buildResultsView(context, theme, l10n, atsState.value!)
                    else
                      _buildInputView(context, theme, l10n, isMobile),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryIndigo, AppTheme.accentCyan],
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
            l10n.checkingATS,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.analyzingContent,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildInputView(BuildContext context, ThemeData theme,
      AppLocalizations l10n, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryIndigo, AppTheme.accentCyan],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryIndigo.withOpacity(0.3),
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
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.checkATSScore,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.checkATSDescription,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.2),

        const SizedBox(height: 32),

        // CV Selection
        _buildSection(
          context,
          title: l10n.uploadOrPasteCV,
          subtitle: l10n.atsAnalysisSubtitle,
          icon: Icons.description_outlined,
          color: AppTheme.primaryIndigo,
          child: CVInputSelector(
            onCVSelected: _onCVSelected,
            showSelectOption: true,
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

        const SizedBox(height: 32),

        AnimatedButton(
          text: l10n.checkATSScore,
          icon: Icons.search_rounded,
          onPressed: _checkATS,
          isFullWidth: true,
          backgroundColor: AppTheme.primaryIndigo,
        ).animate().fadeIn(delay: 200.ms).scale(),

        const SizedBox(height: 16),
        Center(
          child: Text(
            l10n.checkATSUsage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView(BuildContext context, ThemeData theme,
      AppLocalizations l10n, ATSScoreModel results) {
    final scoreColor = results.score >= 80
        ? AppTheme.accentEmerald
        : (results.score >= 60 ? AppTheme.warningOrange : AppTheme.errorRed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Score Header
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scoreColor.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: scoreColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: results.score / 100,
                      strokeWidth: 12,
                      backgroundColor: scoreColor.withOpacity(0.1),
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    '${results.score}%',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l10n.yourATSScore,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (results.score < 70)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppTheme.errorRed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.optimizeAdvise,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.errorRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (results.score >= 80)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.successGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          color: AppTheme.successGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.goodScoreFeedback,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              AnimatedButton(
                text: results.score >= 85
                    ? l10n.furtherOptimize
                    : l10n.optimizeCV,
                icon: Icons.auto_fix_high_rounded,
                onPressed: () {
                  final problems =
                      results.problems.map((p) => '- $p').join('\n');
                  final fixes = results.fixPoints.map((f) => '- $f').join('\n');
                  final notes =
                      l10n.atsFixesRequired(results.score, problems, fixes);
                  context.go('/optimize-cv', extra: notes);
                },
                isFullWidth: true,
                backgroundColor: AppTheme.primaryViolet,
              ),
            ],
          ),
        ).animate().fadeIn().scale(),

        const SizedBox(height: 24),

        // Problems
        _buildResultCard(
          theme,
          l10n,
          title: l10n.problemsFound,
          icon: Icons.error_outline_rounded,
          color: AppTheme.errorRed,
          items: results.problems,
        ),

        const SizedBox(height: 16),

        // Fix Points
        _buildResultCard(
          theme,
          l10n,
          title: l10n.pointsToFix,
          icon: Icons.build_outlined,
          color: AppTheme.warningOrange,
          items: results.fixPoints,
        ),

        const SizedBox(height: 16),

        // How to Optimize
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.tips_and_updates_outlined,
                      color: AppTheme.accentCyan),
                  const SizedBox(width: 12),
                  Text(
                    l10n.howToOptimize,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                results.howToOptimize,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        TextButton.icon(
          onPressed: () {
            ref.read(atsCheckControllerProvider.notifier).reset();
            setState(() {
              _showResults = false;
              _cvContent = null;
            });
          },
          icon: const Icon(Icons.refresh),
          label: Text(l10n.checkAnotherCV),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildResultCard(
    ThemeData theme,
    AppLocalizations l10n, {
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(l10n.noIssuesFound)
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
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
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
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
                    colors: [color, color.withOpacity(0.7)],
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
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
