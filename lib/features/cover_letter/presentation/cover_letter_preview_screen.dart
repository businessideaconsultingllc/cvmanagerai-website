import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/languages.dart';
import '../domain/cover_letter_model.dart';
import '../data/cover_letter_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CoverLetterPreviewScreen extends ConsumerStatefulWidget {
  final CoverLetterModel coverLetter;

  const CoverLetterPreviewScreen({super.key, required this.coverLetter});

  @override
  ConsumerState<CoverLetterPreviewScreen> createState() =>
      _CoverLetterPreviewScreenState();
}

class _CoverLetterPreviewScreenState
    extends ConsumerState<CoverLetterPreviewScreen> {
  late FocusNode _focusNode;
  final ScrollController _scrollController = ScrollController();

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
    final coverLettersAsync = ref.watch(userCoverLettersProvider);
    final latestCoverLetter =
        coverLettersAsync.valueOrNull?.cast<CoverLetterModel?>().firstWhere(
                  (c) => c?.id == widget.coverLetter.id,
                  orElse: () => null,
                ) ??
            widget.coverLetter;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.coverLetterPreview),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () {
              context.push('/edit-cover-letter', extra: widget.coverLetter);
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: AppLocalizations.of(context)!.downloadPDF,
            onPressed: () => _printDoc(context, latestCoverLetter),
          ),
        ],
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
        child: _CoverLetterPreviewContent(
          coverLetter: latestCoverLetter,
          scrollController: _scrollController,
        ),
      ),
    );
  }

  Future<void> _printDoc(
      BuildContext context, CoverLetterModel coverLetter) async {
    try {
      final doc = pw.Document();

      // Determine the language and load appropriate fonts
      final language = coverLetter.language.toLowerCase();
      final isRtl = AppLanguages.isRtl(coverLetter.language);
      final isChinese =
          language.startsWith('zh'); // Chinese (zh-CN, zh-TW, etc.)
      final isJapanese = language == 'ja'; // Japanese

      // Load fonts based on language
      pw.Font regularFontToUse;
      pw.Font boldFontToUse;

      if (isChinese) {
        // Use Noto Sans SC for Chinese
        regularFontToUse = await PdfGoogleFonts.notoSansSCRegular();
        boldFontToUse = await PdfGoogleFonts.notoSansSCBold();
      } else if (isJapanese) {
        // Use Noto Sans JP for Japanese
        regularFontToUse = await PdfGoogleFonts.notoSansJPRegular();
        boldFontToUse = await PdfGoogleFonts.notoSansJPBold();
      } else if (isRtl) {
        // Use Amiri for Arabic and other RTL languages
        regularFontToUse = await PdfGoogleFonts.amiriRegular();
        boldFontToUse = await PdfGoogleFonts.amiriBold();
      } else {
        // Use Inter for Latin languages (default)
        regularFontToUse = await PdfGoogleFonts.interRegular();
        boldFontToUse = await PdfGoogleFonts.interBold();
      }

      final textDirection = isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
      final textAlign = isRtl ? pw.TextAlign.right : pw.TextAlign.left;

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: textDirection,
          build: (pw.Context context) {
            // Split content into paragraphs first
            final normalizedContent =
                coverLetter.content.replaceAll(RegExp(r'\r\n?'), '\n');
            final paragraphs = normalizedContent.split('\n');

            final contentWidgets = <pw.Widget>[
              pw.Text(
                coverLetter.title,
                style: pw.TextStyle(font: boldFontToUse, fontSize: 18),
                textAlign: textAlign,
              ),
              pw.SizedBox(height: 20),
            ];

            for (final paragraph in paragraphs) {
              if (paragraph.trim().isEmpty) {
                contentWidgets.add(pw.SizedBox(height: 10));
                continue;
              }

              // Use Wrap to allow spanning across pages if a single paragraph is too long.
              // Note: pw.Text does not span pages, but pw.Wrap (SpanningWidget) does.
              // We split by spaces to let Wrap handle the layout.
              final words = paragraph.split(' ');

              contentWidgets.add(pw.Wrap(
                alignment:
                    isRtl ? pw.WrapAlignment.end : pw.WrapAlignment.start,
                spacing: 2, // Space between words
                runSpacing: 2, // Line spacing (approximate)
                children: words.map((word) {
                  return pw.Text(word,
                      style:
                          pw.TextStyle(font: regularFontToUse, fontSize: 12));
                }).toList(),
              ));

              contentWidgets.add(pw.SizedBox(height: 10));
            }

            return contentWidgets;
          },
        ),
      );

      final filename = 'Cover letter for ${coverLetter.title}';

      if (kIsWeb) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => doc.save(),
          name: filename,
        );
      } else {
        await Printing.sharePdf(
          bytes: await doc.save(),
          filename: '$filename.pdf',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error generating PDF: $e\n$stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _CoverLetterPreviewContent extends StatelessWidget {
  final CoverLetterModel coverLetter;
  final ScrollController scrollController;

  const _CoverLetterPreviewContent({
    required this.coverLetter,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = AppLanguages.isRtl(coverLetter.language);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              coverLetter.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              coverLetter.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
