import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/languages.dart';
import '../domain/cv_model.dart';
import 'cv_controller.dart';
import 'pdf_translations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CVPreviewScreen extends ConsumerStatefulWidget {
  final CVModel cvModel;

  const CVPreviewScreen({super.key, required this.cvModel});

  @override
  ConsumerState<CVPreviewScreen> createState() => _CVPreviewScreenState();
}

class _CVPreviewScreenState extends ConsumerState<CVPreviewScreen> {
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
    final cvState = ref.watch(cvControllerProvider);
    final currentCV = cvState.valueOrNull ?? widget.cvModel;
    final l10n = AppLocalizations.of(context)!;

    final isRtl = AppLanguages.isRtl(currentCV.language);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentCV.title),
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
            icon: const Icon(Icons.edit),
            tooltip: l10n.editCV,
            onPressed: () => context.push('/edit-cv', extra: currentCV),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: l10n.downloadPDF,
            onPressed: () => _printDoc(currentCV),
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
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: SingleChildScrollView(
            controller: _scrollController,
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
                if (currentCV.data.customSections.isNotEmpty) ...[
                  const Divider(height: 32),
                  _buildCustomSections(context, currentCV),
                ],
              ],
            ),
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
          children: cv.data.skills
              .map((skill) => Chip(
                    label: Text(
                      skill,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ))
              .toList(),
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
          children: cv.data.languages
              .map((lang) => Chip(
                    label: Text(
                      lang,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCustomSections(BuildContext context, CVModel cv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cv.data.customSections.map((section) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...section.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${item.subtitle} | ${item.date}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 4),
                        Text(item.description),
                      ],
                    ),
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _printDoc(CVModel cv) async {
    final doc = pw.Document();

    // Determine the language and load appropriate fonts
    final language = cv.language.toLowerCase();
    final isRtl = AppLanguages.isRtl(cv.language);
    final isChinese = language.startsWith('zh'); // Chinese (zh-CN, zh-TW, etc.)
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
              style:
                  pw.TextStyle(font: regularFontToUse, color: secondaryColor),
            ),
            pw.Text(
              cv.data.personalInfo.address,
              style:
                  pw.TextStyle(font: regularFontToUse, color: secondaryColor),
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
              style: pw.TextStyle(font: regularFontToUse, color: blackColor),
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
                                font: regularFontToUse, color: blackColor)),
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
                  pw.SizedBox(
                      height:
                          15), // Increased spacing between experiences slightly for clarity, but layout handle will prevent giant gaps
                ],
              );
            }),
            // Removed extra SizedBox here as we have spacing in the loop

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
                style:
                    pw.TextStyle(font: regularFontToUse, color: secondaryColor),
              )
            else
              ...cv.data.skills.map((skill) => pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ',
                          style: pw.TextStyle(
                              font: regularFontToUse, color: blackColor)),
                      pw.Expanded(
                        child: pw.Text(
                          skill,
                          style: pw.TextStyle(
                              font: regularFontToUse, color: blackColor),
                        ),
                      ),
                    ],
                  )),
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
                style:
                    pw.TextStyle(font: regularFontToUse, color: secondaryColor),
              )
            else
              ...cv.data.languages.map((lang) => pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ',
                          style: pw.TextStyle(
                              font: regularFontToUse, color: blackColor)),
                      pw.Expanded(
                        child: pw.Text(
                          lang,
                          style: pw.TextStyle(
                              font: regularFontToUse, color: blackColor),
                        ),
                      ),
                    ],
                  )),
            pw.SizedBox(height: 15),

            // Custom Sections
            ...cv.data.customSections.map((section) {
              return pw.Column(
                crossAxisAlignment: alignment,
                children: [
                  pw.Text(
                    section.title,
                    style: pw.TextStyle(
                      font: boldFontToUse,
                      fontSize: 18,
                      color: blackColor,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  ...section.items.map((item) {
                    final descriptionLines = item.description.split('\n');
                    return pw.Column(
                      crossAxisAlignment: alignment,
                      children: [
                        pw.Text(
                          item.title,
                          style: pw.TextStyle(
                            font: boldFontToUse,
                            fontSize: 14,
                            color: blackColor,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          '${item.subtitle} | ${item.date}',
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
                          // Clean the line
                          String cleanedLine = line.trim();
                          if (cleanedLine.startsWith('•')) {
                            cleanedLine = cleanedLine.substring(1).trim();
                          } else if (cleanedLine.startsWith('-')) {
                            cleanedLine = cleanedLine.substring(1).trim();
                          }

                          return pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (cleanedLine.isNotEmpty) ...[
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
                              ]
                            ],
                          );
                        }),
                        pw.SizedBox(height: 15),
                      ],
                    );
                  }),
                  pw.SizedBox(height: 5),
                ],
              );
            }),
          ];
        },
      ),
    );

    String filename = cv.title;
    if (cv.cvType == CVType.optimized) {
      filename += ' Optimized';
    } else if (cv.cvType == CVType.tailored) {
      filename += ' Tailored';
    }
    filename += ' CV';

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
  }
}
