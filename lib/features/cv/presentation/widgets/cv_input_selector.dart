import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/pdf_text_extractor.dart';
import '../../domain/cv_model.dart';
import 'categorized_cv_selector.dart';

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
          if (file.bytes != null) {
            content = await CVFileExtractor.extractText(
              fileExtension: file.extension ?? '',
              bytes: file.bytes,
            );
          } else {
            throw Exception('File bytes not available');
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

    final tabs = <Widget>[];
    if (widget.showSelectOption) {
      tabs.add(
        Tab(
          icon: const Icon(Icons.folder_outlined),
          text: 'Select CV',
        ),
      );
    }
    tabs.addAll([
      const Tab(
        icon: Icon(Icons.upload_file),
        text: 'Upload File',
      ),
      const Tab(
        icon: Icon(Icons.edit_note),
        text: 'Paste Content',
      ),
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryIndigo,
                  AppTheme.primaryViolet,
                ],
              ),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[700],
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: tabs,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: _buildTabViews(l10n),
          ),
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.primaryIndigo, size: 20),
              const SizedBox(width: 8),
              Text(
                'Select from your saved CVs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.accentCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'Upload PDF or TXT file',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_uploadedContent != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green[700], size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'File Uploaded Successfully',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _uploadedFileName ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _uploadedContent = null;
                                _uploadedFileName = null;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Upload Different File'),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 64,
                            color: AppTheme.accentCyan,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Click to upload your CV',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Supports PDF and TXT files',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _isUploading ? null : _pickFile,
                            icon: _isUploading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.upload_file),
                            label: Text(
                                _isUploading ? 'Uploading...' : 'Choose File'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentCyan,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasteTab(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.accentEmerald, size: 20),
              const SizedBox(width: 8),
              Text(
                'Paste your CV content',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TextField(
              controller: _pasteController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText:
                    'Paste your CV content here...\n\nInclude your personal information, work experience, education, skills, etc.',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppTheme.accentEmerald, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (_) => _onPasteChanged(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tip: You can copy your CV from any document and paste it here',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
