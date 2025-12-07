import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class CVFileExtractor {
  /// Extracts text from a PDF file
  ///
  /// Returns the extracted text or throws an exception if extraction fails
  static Future<String> extractFromPdf({
    Uint8List? bytes,
  }) async {
    try {
      if (bytes == null) {
        throw Exception('PDF bytes must be provided');
      }

      // Load from bytes (works on all platforms including web)
      final document = PdfDocument(inputBytes: bytes);

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
    Uint8List? bytes,
  }) async {
    try {
      if (bytes == null) {
        throw Exception('TXT bytes must be provided');
      }

      // Read from bytes
      final text = String.fromCharCodes(bytes);

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
    Uint8List? bytes,
  }) async {
    final extension = fileExtension.toLowerCase();

    switch (extension) {
      case 'pdf':
        return await extractFromPdf(bytes: bytes);
      case 'txt':
        return await extractFromTxt(bytes: bytes);
      default:
        throw Exception('Unsupported file type: $extension');
    }
  }
}
