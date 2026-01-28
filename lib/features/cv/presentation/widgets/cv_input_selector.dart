import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'dart:io' show File;
import 'dart:ui'; // For PathMetric
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/pdf_text_extractor.dart';
import '../../domain/cv_model.dart';
import 'categorized_cv_selector.dart';
// For animations if needed

enum CVInputMode { select, upload, paste }

class CVInputSelector extends ConsumerStatefulWidget {
  final Function(String cvContent) onCVSelected;
  final String? initialContent;
  final bool showSelectOption;

  const CVInputSelector({
    super.key,
    required this.onCVSelected,
    this.initialContent,
    this.showSelectOption = true,
  });

  @override
  ConsumerState<CVInputSelector> createState() => _CVInputSelectorState();
}

class _CVInputSelectorState extends ConsumerState<CVInputSelector>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _pasteController = TextEditingController();

  CVModel? _selectedCV;
  String? _uploadedFileName;
  String? _uploadedContent;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final tabCount = widget.showSelectOption ? 3 : 2;
    _tabController = TabController(length: tabCount, vsync: this);
    if (widget.initialContent != null) {
      _pasteController.text = widget.initialContent!;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pasteController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _uploadedFileName = file.name;
          _isUploading = true;
        });

        try {
          String content = '';

          // On web, use bytes. On mobile, use file path
          if (kIsWeb) {
            if (file.bytes != null) {
              content = await CVFileExtractor.extractText(
                fileExtension: file.extension ?? '',
                bytes: file.bytes,
              );
            } else {
              throw Exception('File bytes not available');
            }
          } else {
            if (file.path != null) {
              final fileBytes = await File(file.path!).readAsBytes();
              content = await CVFileExtractor.extractText(
                fileExtension: file.extension ?? '',
                bytes: fileBytes,
              );
            } else {
              throw Exception('File path not available');
            }
          }

          if (mounted) {
            setState(() {
              _uploadedContent = content;
              _isUploading = false;
            });
            widget.onCVSelected(content);
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isUploading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _onCVSelected(CVModel? cv) {
    setState(() => _selectedCV = cv);
    if (cv != null) {
      final cvContent = jsonEncode(cv.data.toMap());
      widget.onCVSelected(cvContent);
    }
  }

  void _onPasteChanged() {
    if (_pasteController.text.trim().isNotEmpty) {
      widget.onCVSelected(_pasteController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Custom Premium Tabs (Segmented Control Style)
    final tabs = <Widget>[];
    if (widget.showSelectOption) {
      tabs.add(_buildPremiumTab(l10n.selectFromLibrary, Icons.folder_rounded));
    }
    tabs.addAll([
      _buildPremiumTab(l10n.browseFiles, Icons.cloud_upload_rounded),
      _buildPremiumTab('Paste', Icons.content_paste_rounded),
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Premium Tab Bar Container
        Container(
          height: 60,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            tabs: tabs,
          ),
        ),

        const SizedBox(height: 24),

        // Content Area with Flexible constraints
        LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive height calculation
            // Mobile needs more flexibility, while web can have a fixed readable height
            // We use limited BoxConstraints to allow scrolling inside if needed
            return Container(
              height: 450,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                boxShadow: AppTheme.softShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: TabBarView(
                controller: _tabController,
                physics:
                    const NeverScrollableScrollPhysics(), // Prevent swipe conflict
                children: _buildTabViews(l10n),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPremiumTab(String label, IconData icon) {
    return Tab(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTabViews(AppLocalizations l10n) {
    final views = <Widget>[];

    if (widget.showSelectOption) {
      views.add(_buildSelectTab(l10n));
    }
    views.addAll([
      _buildUploadTab(l10n),
      _buildPasteTab(l10n),
    ]);

    return views;
  }

  Widget _buildSelectTab(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelperHeader(
            icon: Icons.folder_special_rounded,
            color: AppTheme.primaryIndigo,
            title: 'Select from Library',
            subtitle: 'Choose one of your previously generated or saved CVs.',
          ),
          const SizedBox(height: 20),
          Expanded(
            child: CategorizedCVSelector(
              onCVSelected: _onCVSelected,
              selectedCV: _selectedCV,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadTab(AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHelperHeader(
            icon: Icons.cloud_upload_rounded,
            color: AppTheme.accentCyan,
            title: 'Upload File',
            subtitle: 'Supported formats: PDF, TXT (Max 5MB)',
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isUploading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text('Analyzing document...',
                            style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  )
                : _uploadedContent != null
                    ? _buildSuccessState(theme)
                    : _buildUploadDropZone(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHelperHeader(
      {required IconData icon,
      required Color color,
      required String title,
      required String subtitle}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadDropZone(ThemeData theme) {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface, // Base color
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 2,
            style: BorderStyle
                .none, // We'll simulate dash with shader or just use opacity
          ), // Simplified keeping it solid but styled
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(
              color: theme.colorScheme.primary.withOpacity(0.5)),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.file_upload_outlined,
                      size: 48, color: theme.colorScheme.primary),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(end: 1.1, duration: 1.5.seconds),
                const SizedBox(height: 24),
                Text(
                  'Tap to browse files',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'or drag and drop here',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppTheme.successGreen, size: 56),
          const SizedBox(height: 16),
          Text(
            'Upload Complete!',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.successGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _uploadedFileName ?? 'Document',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _uploadedContent = null;
                _uploadedFileName = null;
              });
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Change File'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.successGreen,
              side: const BorderSide(color: AppTheme.successGreen),
            ),
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildPasteTab(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHelperHeader(
            icon: Icons.edit_note_rounded,
            color: AppTheme.accentEmerald,
            title: 'Paste Text',
            subtitle: 'Directly paste your bio, work history, or full CV text.',
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TextField(
              controller: _pasteController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: l10n.pasteCVContentHere,
                filled: true,
                focusColor: Colors.transparent,
                contentPadding: const EdgeInsets.all(20),
              ),
              onChanged: (_) => _onPasteChanged(),
            ),
          ),
        ],
      ), // No extra scroll needed as TextField handles it
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 8;
    const dashSpace = 8;
    final rrect =
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(20));
    final path = Path()..addRRect(rrect);

    // Simple dash implementation using PathMetric
    final Path dashPath = Path();
    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
