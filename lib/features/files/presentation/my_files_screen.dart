import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../cv/data/cv_repository.dart';
import '../../cv/domain/cv_model.dart';
import '../../cover_letter/data/cover_letter_repository.dart';
import '../../cover_letter/domain/cover_letter_model.dart';
import '../../../core/widgets/app_navigation_bar.dart';
import '../../../core/theme/app_theme.dart';

class MyFilesScreen extends ConsumerStatefulWidget {
  const MyFilesScreen({super.key});

  @override
  ConsumerState<MyFilesScreen> createState() => _MyFilesScreenState();
}

class _MyFilesScreenState extends ConsumerState<MyFilesScreen> {
  late FocusNode _focusNode;
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedCVIds = {};
  final Set<String> _selectedCLIds = {};
  bool _isSelectionMode = false;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode
            ? '${_selectedCVIds.length + _selectedCLIds.length} Selected'
            : l10n.myFiles),
        elevation: 0,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedCVIds.clear();
                    _selectedCLIds.clear();
                  });
                },
              )
            : null,
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: AppTheme.errorRed),
              onPressed: _deleteSelectedItems,
            ),
          if (!_isSelectionMode)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'select') {
                  setState(() {
                    _isSelectionMode = true;
                  });
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'select',
                  child: Row(
                    children: [
                      Icon(Icons.check_box_outlined, size: 20),
                      SizedBox(width: 12),
                      Text('Select Items'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      drawer: const AppNavigationBar(currentRoute: '/my-files'),
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
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(generatedCVsProvider);
            ref.invalidate(optimizedCVsProvider);
            ref.invalidate(tailoredCVsProvider);
            ref.invalidate(userCoverLettersProvider);
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.organizeYourDocuments,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 24),

                // Generated CVs Section
                _CategorySection(
                  title: l10n.generatedCVs,
                  icon: Icons.add_circle_outline,
                  color: theme.colorScheme.primary,
                  provider: generatedCVsProvider,
                  emptyMessage: l10n.noGeneratedCVs,
                  isSelectionMode: _isSelectionMode,
                  selectedIds: _selectedCVIds,
                  onSelectionChanged: (id, selected) {
                    setState(() {
                      if (selected) {
                        _selectedCVIds.add(id);
                      } else {
                        _selectedCVIds.remove(id);
                      }
                    });
                  },
                  onDeleteAll: () => _deleteAllItems('cv_generated'),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 20),

                // Optimized CVs Section
                _CategorySection(
                  title: l10n.optimizedCVs,
                  icon: Icons.auto_fix_high_outlined,
                  color: Colors.purple,
                  provider: optimizedCVsProvider,
                  emptyMessage: l10n.noOptimizedCVs,
                  isSelectionMode: _isSelectionMode,
                  selectedIds: _selectedCVIds,
                  onSelectionChanged: (id, selected) {
                    setState(() {
                      if (selected) {
                        _selectedCVIds.add(id);
                      } else {
                        _selectedCVIds.remove(id);
                      }
                    });
                  },
                  onDeleteAll: () => _deleteAllItems('cv_optimized'),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 20),

                // Tailored CVs Section
                _CategorySection(
                  title: l10n.tailoredCVs,
                  icon: Icons.tune,
                  color: Colors.orange,
                  provider: tailoredCVsProvider,
                  emptyMessage: l10n.noTailoredCVs,
                  isSelectionMode: _isSelectionMode,
                  selectedIds: _selectedCVIds,
                  onSelectionChanged: (id, selected) {
                    setState(() {
                      if (selected) {
                        _selectedCVIds.add(id);
                      } else {
                        _selectedCVIds.remove(id);
                      }
                    });
                  },
                  onDeleteAll: () => _deleteAllItems('cv_tailored'),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 20),

                // Cover Letters Section
                _CoverLetterSection(
                  isSelectionMode: _isSelectionMode,
                  selectedIds: _selectedCLIds,
                  onSelectionChanged: (id, selected) {
                    setState(() {
                      if (selected) {
                        _selectedCLIds.add(id);
                      } else {
                        _selectedCLIds.remove(id);
                      }
                    });
                  },
                  onDeleteAll: () => _deleteAllItems('cover_letter'),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAllItems(String type) async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(
            'Are you sure you want to delete ALL items in this category? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) return;

        if (type.startsWith('cv')) {
          CVType? cvType;
          if (type == 'cv_generated') cvType = CVType.generated;
          if (type == 'cv_optimized') cvType = CVType.optimized;
          if (type == 'cv_tailored') cvType = CVType.tailored;

          if (cvType != null) {
            final repo = ref.read(cvRepositoryProvider);
            final cvs = await repo.getCVsByType(user.id, cvType);
            if (cvs.isNotEmpty) {
              await repo.deleteCVs(cvs.map((e) => e.id).toList());
            }
          }
        } else {
          final repo = ref.read(coverLetterRepositoryProvider);
          final letters = await repo.getUserCoverLetters(user.id);
          if (letters.isNotEmpty) {
            await repo.deleteCoverLetters(letters.map((e) => e.id).toList());
          }
        }

        ref.invalidate(generatedCVsProvider);
        ref.invalidate(optimizedCVsProvider);
        ref.invalidate(tailoredCVsProvider);
        ref.invalidate(userCVsProvider);
        ref.invalidate(userCoverLettersProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category cleared successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.error}: $e'),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteSelectedItems() async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final totalCount = _selectedCVIds.length + _selectedCLIds.length;

    if (totalCount == 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(
            'Are you sure you want to delete $totalCount selected items? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        if (_selectedCVIds.isNotEmpty) {
          await ref
              .read(cvRepositoryProvider)
              .deleteCVs(_selectedCVIds.toList());
        }
        if (_selectedCLIds.isNotEmpty) {
          await ref
              .read(coverLetterRepositoryProvider)
              .deleteCoverLetters(_selectedCLIds.toList());
        }

        setState(() {
          _isSelectionMode = false;
          _selectedCVIds.clear();
          _selectedCLIds.clear();
        });

        ref.invalidate(generatedCVsProvider);
        ref.invalidate(optimizedCVsProvider);
        ref.invalidate(tailoredCVsProvider);
        ref.invalidate(userCVsProvider);
        ref.invalidate(userCoverLettersProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$totalCount items deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.error}: $e'),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

class _CategorySection extends ConsumerStatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final AutoDisposeFutureProvider<List<CVModel>> provider;
  final String emptyMessage;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final Function(String, bool) onSelectionChanged;
  final Function() onDeleteAll;

  const _CategorySection({
    required this.title,
    required this.icon,
    required this.color,
    required this.provider,
    required this.emptyMessage,
    required this.isSelectionMode,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onDeleteAll,
  });

  @override
  ConsumerState<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends ConsumerState<_CategorySection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cvsAsync = ref.watch(widget.provider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
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
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        cvsAsync.when(
                          data: (cvs) => Text(
                            '${cvs.length} ${cvs.length == 1 ? l10n.item : l10n.items}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          loading: () => const SizedBox(height: 16),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  if (!widget.isSelectionMode)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_horiz,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      onSelected: (value) {
                        if (value == 'delete_all') {
                          widget.onDeleteAll();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete_all',
                          child: Row(
                            children: [
                              Icon(Icons.delete_sweep,
                                  size: 20, color: theme.colorScheme.error),
                              const SizedBox(width: 12),
                              Text(
                                'Delete All',
                                style:
                                    TextStyle(color: theme.colorScheme.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            cvsAsync.when(
              data: (cvs) {
                if (cvs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.emptyMessage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    const Divider(height: 1),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cvs.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final cv = cvs[index];
                        return _CVListItem(
                          cv: cv,
                          color: widget.color,
                          isSelectionMode: widget.isSelectionMode,
                          isSelected: widget.selectedIds.contains(cv.id),
                          onSelectionChanged: (selected) =>
                              widget.onSelectionChanged(cv.id, selected),
                        );
                      },
                    ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  '${l10n.error}: $error',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CVListItem extends ConsumerWidget {
  final CVModel cv;
  final Color color;
  final bool isSelectionMode;
  final bool isSelected;
  final Function(bool) onSelectionChanged;

  const _CVListItem({
    required this.cv,
    required this.color,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: isSelectionMode
          ? Checkbox(
              value: isSelected,
              onChanged: (value) => onSelectionChanged(value ?? false),
              activeColor: color,
            )
          : Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.description,
                color: color,
                size: 20,
              ),
            ),
      title: Text(
        cv.title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '${l10n.created}: ${cv.createdAt.toString().split(' ')[0]}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (cv.language != 'en')
            Text(
              '${l10n.language}: ${cv.language.toUpperCase()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
      trailing: isSelectionMode
          ? null
          : PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              onSelected: (value) async {
                if (value == 'view') {
                  context.push('/cv-preview', extra: cv);
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.confirmDelete),
                      content: Text(l10n.areYouSureDeleteCV),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                          child: Text(l10n.delete),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      await ref.read(cvRepositoryProvider).deleteCV(cv.id);
                      ref.invalidate(generatedCVsProvider);
                      ref.invalidate(optimizedCVsProvider);
                      ref.invalidate(tailoredCVsProvider);
                      ref.invalidate(userCVsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.cvDeletedSuccessfully),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${l10n.error}: $e'),
                            backgroundColor: theme.colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      const Icon(Icons.visibility, size: 20),
                      const SizedBox(width: 12),
                      Text(l10n.view),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete,
                          size: 20, color: theme.colorScheme.error),
                      const SizedBox(width: 12),
                      Text(
                        l10n.delete,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      onTap: () {
        if (isSelectionMode) {
          onSelectionChanged(!isSelected);
        } else {
          context.push('/cv-preview', extra: cv);
        }
      },
    );
  }
}

class _CoverLetterSection extends ConsumerStatefulWidget {
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final Function(String, bool) onSelectionChanged;
  final Function() onDeleteAll;

  const _CoverLetterSection({
    required this.isSelectionMode,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onDeleteAll,
  });

  @override
  ConsumerState<_CoverLetterSection> createState() =>
      _CoverLetterSectionState();
}

class _CoverLetterSectionState extends ConsumerState<_CoverLetterSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final coverLettersAsync = ref.watch(userCoverLettersProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
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
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.mail_outline,
                      color: Colors.teal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.coverLetters,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        coverLettersAsync.when(
                          data: (letters) => Text(
                            '${letters.length} ${letters.length == 1 ? l10n.item : l10n.items}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          loading: () => const SizedBox(height: 16),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  if (!widget.isSelectionMode)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_horiz,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      onSelected: (value) {
                        if (value == 'delete_all') {
                          widget.onDeleteAll();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete_all',
                          child: Row(
                            children: [
                              Icon(Icons.delete_sweep,
                                  size: 20, color: theme.colorScheme.error),
                              const SizedBox(width: 12),
                              const Text(
                                'Delete All',
                                style: TextStyle(color: AppTheme.errorRed),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            coverLettersAsync.when(
              data: (letters) {
                if (letters.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.mail_outline,
                          size: 48,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noCoverLetters,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    const Divider(height: 1),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: letters.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final letter = letters[index];
                        return _CoverLetterListItem(
                          letter: letter,
                          isSelectionMode: widget.isSelectionMode,
                          isSelected: widget.selectedIds.contains(letter.id),
                          onSelectionChanged: (selected) =>
                              widget.onSelectionChanged(letter.id, selected),
                        );
                      },
                    ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  '${l10n.error}: $error',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoverLetterListItem extends ConsumerWidget {
  final CoverLetterModel letter;
  final bool isSelectionMode;
  final bool isSelected;
  final Function(bool) onSelectionChanged;

  const _CoverLetterListItem({
    required this.letter,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: isSelectionMode
          ? Checkbox(
              value: isSelected,
              onChanged: (value) => onSelectionChanged(value ?? false),
              activeColor: Colors.teal,
            )
          : Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.mail,
                color: Colors.teal,
                size: 20,
              ),
            ),
      title: Text(
        letter.title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '${l10n.created}: ${letter.createdAt.toString().split(' ')[0]}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (letter.language != 'en')
            Text(
              '${l10n.language}: ${letter.language.toUpperCase()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
      trailing: isSelectionMode
          ? null
          : PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              onSelected: (value) async {
                if (value == 'view') {
                  context.push('/cover-letter-preview', extra: letter);
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.confirmDelete),
                      content: Text(l10n.areYouSureDeleteCoverLetter),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                          child: Text(l10n.delete),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      await ref
                          .read(coverLetterRepositoryProvider)
                          .deleteCoverLetter(letter.id);
                      ref.invalidate(userCoverLettersProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.coverLetterDeletedSuccessfully),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${l10n.error}: $e'),
                            backgroundColor: theme.colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      const Icon(Icons.visibility, size: 20),
                      const SizedBox(width: 12),
                      Text(l10n.view),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete,
                          size: 20, color: theme.colorScheme.error),
                      const SizedBox(width: 12),
                      Text(
                        l10n.delete,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      onTap: () {
        if (isSelectionMode) {
          onSelectionChanged(!isSelected);
        } else {
          context.push('/cover-letter-preview', extra: letter);
        }
      },
    );
  }
}
