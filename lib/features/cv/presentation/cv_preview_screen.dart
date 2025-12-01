import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/constants/languages.dart';
import '../domain/cv_model.dart';
import 'cv_controller.dart';
import 'pdf_translations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CVPreviewScreen extends ConsumerWidget {
  final CVModel cvModel;

  const CVPreviewScreen({super.key, required this.cvModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cvState = ref.watch(cvControllerProvider);
    final currentCV = cvState.valueOrNull ?? cvModel;
    final l10n = AppLocalizations.of(context)!;

    final isRtl = AppLanguages.isRtl(currentCV.language);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentCV.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.editCV,
            onPressed: () => context.push('/edit-cv', extra: currentCV),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: l10n.downloadPDF,
            onPressed: () => _printDoc(currentCV),
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
              _buildHeader(context, currentCV),
              const Divider(height: 32),
              _buildSummary(context, currentCV),
              const Divider(height: 32),
              _buildExperience(context, currentCV),
              const Divider(height: 32),
              _buildEducation(context, currentCV),
              const Divider(height: 32),
              _buildCertificates(context, currentCV),
              const Divider(height: 32),
              _buildSkills(context, currentCV),
              const Divider(height: 32),
              _buildLanguages(context, currentCV),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CVModel cv) {
    final personal = cv.data.personalInfo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${personal.firstName} ${personal.lastName}',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(personal.email),
        Text(personal.phone),
        Text(personal.address),
        if (personal.linkedin != null && personal.linkedin!.isNotEmpty)
          Text(personal.linkedin!),
      ],
    );
  }

  Widget _buildSummary(BuildContext context, CVModel cv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PdfTranslations.get(cv.language, 'summary'),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(cv.data.summary),
      ],
    );
  }

  Widget _buildExperience(BuildContext context, CVModel cv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PdfTranslations.get(cv.language, 'experience'),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...cv.data.experience.map((exp) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp.jobTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${exp.company} | ${exp.startDate} - ${exp.endDate}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 4),
                  Text(exp.description),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildEducation(BuildContext context, CVModel cv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PdfTranslations.get(cv.language, 'education'),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...cv.data.education.map((edu) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    edu.degree,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${edu.school} | ${edu.startDate} - ${edu.endDate}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  if (edu.description != null) ...[
                    const SizedBox(height: 4),
                    Text(edu.description!),
                  ],
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildCertificates(BuildContext context, CVModel cv) {
    if (cv.data.certificates.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PdfTranslations.get(cv.language, 'certificates'),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...cv.data.certificates.map((cert) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cert.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${cert.issuer} | ${cert.date}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  if (cert.description != null &&
                      cert.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(cert.description!),
                  ],
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildSkills(BuildContext context, CVModel cv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PdfTranslations.get(cv.language, 'skills'),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              cv.data.skills.map((skill) => Chip(label: Text(skill))).toList(),
        ),
      ],
    );
  }

  Widget _buildLanguages(BuildContext context, CVModel cv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PdfTranslations.get(cv.language, 'languages'),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              cv.data.languages.map((lang) => Chip(label: Text(lang))).toList(),
        ),
      ],
    );
  }

  Future<void> _printDoc(CVModel cv) async {
    final doc = pw.Document();

    // Load fonts
    final font = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    // Load Arabic font if needed
    final isRtl = AppLanguages.isRtl(cv.language);
    final arabicFont = await PdfGoogleFonts.amiriRegular();
    final arabicBoldFont = await PdfGoogleFonts.amiriBold();

    final regularFontToUse = isRtl ? arabicFont : font;
    final boldFontToUse = isRtl ? arabicBoldFont : boldFont;
    final textDirection = isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final alignment = pw.CrossAxisAlignment.start;

    // Define Colors
    final primaryColor = PdfColor.fromInt(0xFF2563EB); // Royal Blue
    final secondaryColor = PdfColor.fromInt(0xFF64748B); // Slate 500
    final blackColor = PdfColor.fromInt(0xFF1E293B); // Slate 800

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: textDirection,
        build: (pw.Context context) {
          return [
            pw.Directionality(
              textDirection: textDirection,
              child: pw.Column(
                crossAxisAlignment: alignment,
                children: [
                  // Header
                  pw.Text(
                    '${cv.data.personalInfo.firstName} ${cv.data.personalInfo.lastName}',
                    style: pw.TextStyle(
                      font: boldFontToUse,
                      fontSize: 24,
                      color: primaryColor,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    '${cv.data.personalInfo.email} | ${cv.data.personalInfo.phone}',
                    style: pw.TextStyle(
                        font: regularFontToUse, color: secondaryColor),
                  ),
                  pw.Text(
                    cv.data.personalInfo.address,
                    style: pw.TextStyle(
                        font: regularFontToUse, color: secondaryColor),
                  ),
                  pw.Divider(color: PdfColor.fromInt(0xFFE2E8F0)),
                  pw.SizedBox(height: 10),

                  // Summary
                  pw.Text(
                    PdfTranslations.get(cv.language, 'summary'),
                    style: pw.TextStyle(
                      font: boldFontToUse,
                      fontSize: 18,
                      color: blackColor,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    cv.data.summary,
                    style:
                        pw.TextStyle(font: regularFontToUse, color: blackColor),
                  ),
                  pw.SizedBox(height: 15),

                  // Experience
                  pw.Text(
                    PdfTranslations.get(cv.language, 'experience'),
                    style: pw.TextStyle(
                      font: boldFontToUse,
                      fontSize: 18,
                      color: blackColor,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  ...cv.data.experience.map((exp) {
                    final descriptionLines = exp.description.split('\n');
                    return pw.Column(
                      crossAxisAlignment: alignment,
                      children: [
                        pw.Text(
                          exp.jobTitle,
                          style: pw.TextStyle(
                            font: boldFontToUse,
                            fontSize: 14,
                            color: blackColor,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          '${exp.company} | ${exp.startDate} - ${exp.endDate}',
                          style: pw.TextStyle(
                            font: regularFontToUse,
                            fontStyle: pw.FontStyle.italic,
                            color: secondaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        ...descriptionLines.map((line) {
                          if (line.trim().isEmpty) {
                            return pw.SizedBox(height: 2);
                          }
                          // Clean the line: remove leading bullets, hyphens, and whitespace
                          String cleanedLine = line.trim();
                          if (cleanedLine.startsWith('•')) {
                            cleanedLine = cleanedLine.substring(1).trim();
                          } else if (cleanedLine.startsWith('-')) {
                            cleanedLine = cleanedLine.substring(1).trim();
                          }

                          return pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('• ',
                                  style: pw.TextStyle(
                                      font: regularFontToUse,
                                      color: blackColor)),
                              pw.Expanded(
                                child: pw.Text(
                                  cleanedLine,
                                  style: pw.TextStyle(
                                    font: regularFontToUse,
                                    color: blackColor,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        pw.SizedBox(height: 15),
                      ],
                    );
                  }),
                  pw.SizedBox(height: 5),

                  // Education
                  pw.Text(
                    PdfTranslations.get(cv.language, 'education'),
                    style: pw.TextStyle(
                      font: boldFontToUse,
                      fontSize: 18,
                      color: blackColor,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  ...cv.data.education.map((edu) => pw.Column(
                        crossAxisAlignment: alignment,
                        children: [
                          pw.Text(
                            edu.degree,
                            style: pw.TextStyle(
                              font: boldFontToUse,
                              fontSize: 14,
                              color: blackColor,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '${edu.school} | ${edu.startDate} - ${edu.endDate}',
                            style: pw.TextStyle(
                              font: regularFontToUse,
                              fontStyle: pw.FontStyle.italic,
                              color: secondaryColor,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                        ],
                      )),
                  pw.SizedBox(height: 15),

                  // Certificates
                  if (cv.data.certificates.isNotEmpty) ...[
                    pw.Text(
                      PdfTranslations.get(cv.language, 'certificates'),
                      style: pw.TextStyle(
                        font: boldFontToUse,
                        fontSize: 18,
                        color: blackColor,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    ...cv.data.certificates.map((cert) => pw.Column(
                          crossAxisAlignment: alignment,
                          children: [
                            pw.Text(
                              cert.name,
                              style: pw.TextStyle(
                                font: boldFontToUse,
                                fontSize: 14,
                                color: blackColor,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              '${cert.issuer} | ${cert.date}',
                              style: pw.TextStyle(
                                font: regularFontToUse,
                                fontStyle: pw.FontStyle.italic,
                                color: secondaryColor,
                              ),
                            ),
                            if (cert.description != null &&
                                cert.description!.isNotEmpty) ...[
                              pw.SizedBox(height: 2),
                              pw.Text(
                                cert.description!,
                                style: pw.TextStyle(
                                    font: regularFontToUse, color: blackColor),
                              ),
                            ],
                            pw.SizedBox(height: 10),
                          ],
                        )),
                    pw.SizedBox(height: 5),
                  ],

                  // Skills
                  pw.Text(
                    PdfTranslations.get(cv.language, 'skills'),
                    style: pw.TextStyle(
                      font: boldFontToUse,
                      fontSize: 18,
                      color: blackColor,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  if (cv.data.skills.isEmpty)
                    pw.Text(
                      PdfTranslations.get(cv.language, 'no_skills'),
                      style: pw.TextStyle(
                          font: regularFontToUse, color: secondaryColor),
                    )
                  else
                    pw.Text(
                      cv.data.skills.join(', '),
                      style: pw.TextStyle(
                          font: regularFontToUse, color: blackColor),
                    ),
                  pw.SizedBox(height: 15),

                  // Languages
                  pw.Text(
                    PdfTranslations.get(cv.language, 'languages'),
                    style: pw.TextStyle(
                      font: boldFontToUse,
                      fontSize: 18,
                      color: blackColor,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  if (cv.data.languages.isEmpty)
                    pw.Text(
                      PdfTranslations.get(cv.language, 'no_languages'),
                      style: pw.TextStyle(
                          font: regularFontToUse, color: secondaryColor),
                    )
                  else
                    pw.Text(
                      cv.data.languages.join(', '),
                      style: pw.TextStyle(
                          font: regularFontToUse, color: blackColor),
                    ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }
}
