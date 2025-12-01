import 'dart:io';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class CVFileExtractor {
  /// Extracts text from a PDF file
  ///
  /// Returns the extracted text or throws an exception if extraction fails
  static Future<String> extractFromPdf({
    String? filePath,
    Uint8List? bytes,
  }) async {
    try {
      PdfDocument document;

      if (bytes != null) {
        // Load from bytes (used on web or when file picker provides bytes)
        document = PdfDocument(inputBytes: bytes);
      } else if (filePath != null) {
        // Load from file path (used on mobile/desktop)
        final file = File(filePath);
        final fileBytes = await file.readAsBytes();
        document = PdfDocument(inputBytes: fileBytes);
      } else {
        throw Exception('Either filePath or bytes must be provided');
      }

      // Extract text from all pages using Syncfusion's PdfTextExtractor
      final textExtractor = PdfTextExtractor(document);
      final String text = textExtractor.extractText();

      // Close the document
      document.dispose();

      if (text.trim().isEmpty) {
        throw Exception(
          'No text could be extracted from the PDF. '
          'This might be a scanned document or image-based PDF. '
          'Please paste your CV content manually instead.',
        );
      }

      return text;
    } catch (e) {
      if (e.toString().contains('No text could be extracted')) {
        rethrow;
      }
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  /// Extracts text from a TXT file
  static Future<String> extractFromTxt({
    String? filePath,
    Uint8List? bytes,
  }) async {
    try {
      String text;

      if (bytes != null) {
        // Read from bytes
        text = String.fromCharCodes(bytes);
      } else if (filePath != null) {
        // Read from file path
        final file = File(filePath);
        text = await file.readAsString();
      } else {
        throw Exception('Either filePath or bytes must be provided');
      }

      if (text.trim().isEmpty) {
        throw Exception('The text file is empty');
      }

      return text;
    } catch (e) {
      throw Exception('Failed to read text file: $e');
    }
  }

  /// Extract text from either PDF or TXT based on file extension
  static Future<String> extractText({
    required String fileExtension,
    String? filePath,
    Uint8List? bytes,
  }) async {
    final extension = fileExtension.toLowerCase();

    switch (extension) {
      case 'pdf':
        return await extractFromPdf(filePath: filePath, bytes: bytes);
      case 'txt':
        return await extractFromTxt(filePath: filePath, bytes: bytes);
      default:
        throw Exception('Unsupported file type: $extension');
    }
  }
}
