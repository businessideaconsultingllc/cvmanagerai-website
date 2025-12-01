import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/constants/languages.dart';
import '../domain/cover_letter_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CoverLetterPreviewScreen extends ConsumerWidget {
  final CoverLetterModel coverLetter;

  const CoverLetterPreviewScreen({super.key, required this.coverLetter});

  Future<void> _printDoc() async {
    final doc = pw.Document();

    // Load fonts
    final font = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    // Load Arabic font if needed
    final isRtl = AppLanguages.isRtl(coverLetter.language);
    final arabicFont = await PdfGoogleFonts.amiriRegular();
    final arabicBoldFont = await PdfGoogleFonts.amiriBold();

    final regularFontToUse = isRtl ? arabicFont : font;
    final boldFontToUse = isRtl ? arabicBoldFont : boldFont;
    final textDirection = isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final alignment =
        isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: textDirection,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: textDirection,
            child: pw.Column(
              crossAxisAlignment: alignment,
              children: [
                pw.Text(
                  coverLetter.title,
                  style: pw.TextStyle(font: boldFontToUse, fontSize: 18),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  coverLetter.content,
                  style: pw.TextStyle(font: regularFontToUse, fontSize: 12),
                  textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = AppLanguages.isRtl(coverLetter.language);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.coverLetterPreview),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: l10n.downloadPDF,
            onPressed: _printDoc,
          ),
        ],
      ),
      body: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
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
      ),
    );
  }
}
