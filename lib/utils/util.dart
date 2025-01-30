import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../screens/PdfPreviewScreen.dart';

class PdfUtils {
  final pw.Document pdf = pw.Document();

  Future<File> createPdf(String text) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/extracted_text.pdf');

    // Add content to the PDF (only text, no image)
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 20),
              pw.Text(
                text,
                style: pw.TextStyle(fontSize: 14),
              ),
            ],
          );
        },
      ),
    );

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> openPdf(BuildContext context, File pdfFile) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(pdfFile: pdfFile),
      ),
    );
  }
}
