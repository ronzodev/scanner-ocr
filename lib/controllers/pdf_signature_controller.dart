import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';

class PdfSignatureController extends GetxController {
  final RxString selectedPdfPath = ''.obs;
  final RxString signatureImagePath = ''.obs;
  final RxBool isProcessing = false.obs;
  final RxList<String> savedSignatures = <String>[].obs;

  // Reactive properties for dragging, resizing, and rotating
  final RxDouble signatureX = 50.0.obs;
  final RxDouble signatureY = 50.0.obs;
  final RxDouble signatureWidth = 150.0.obs; // Default width
  final RxDouble signatureHeight = 50.0.obs; // Default height
  final RxDouble signatureRotation = 0.0.obs; // Rotation in degrees

  final RxDouble pdfPageWidth = 0.0.obs;
  final RxDouble pdfPageHeight = 0.0.obs;

  Future<void> pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        selectedPdfPath.value = result.files.single.path!;
        await setPdfPageDimensions(); // Set actual PDF dimensions
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick PDF: $e');
    }
  }
  // deleting saved signature

  Future<bool> deleteSignature() async {
    if (signatureImagePath.value.isEmpty) {
      return false; // No signature to delete
    }

    try {
      final file = File(signatureImagePath.value);
      if (await file.exists()) {
        await file.delete(); // Delete the file from the storage
        savedSignatures
            .remove(signatureImagePath.value); // Remove from the saved list
        signatureImagePath.value = ''; // Clear the saved signature path
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting signature: $e');
      return false;
    }
  }

  // Method to remove the selected PDF
  void removePDF() {
    selectedPdfPath.value = ''; // Clear the PDF path
    // Optionally, perform any cleanup here if needed (like resetting related state)
  }

  Future<void> saveSignature(Uint8List signatureBytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final signaturePath = '${directory.path}/signature_$timestamp.png';

      await File(signaturePath).writeAsBytes(signatureBytes);
      savedSignatures.add(signaturePath);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save signature: $e');
    }
  }

  Future<void> signPDF({
    required String signatureImagePath,
    required double x,
    required double y,
    required double width,
    required double height,
    required double rotation,
    int pageNumber = 1,
  }) async {
    try {
      isProcessing.value = true;

      if (selectedPdfPath.value.isEmpty) throw 'No PDF selected';

      final File pdfFile = File(selectedPdfPath.value);
      final PdfDocument document =
          PdfDocument(inputBytes: await pdfFile.readAsBytes());
      final PdfBitmap signatureBitmap =
          PdfBitmap(await File(signatureImagePath).readAsBytes());
      final PdfPage page = document.pages[pageNumber - 1];

      final double pageWidth = page.getClientSize().width;
      final double pageHeight = page.getClientSize().height;

      final double adjustedX = x / pdfPageWidth.value * pageWidth;
      final double adjustedY = y / pdfPageHeight.value * pageHeight;
      final double adjustedWidth = width * (pageWidth / pdfPageWidth.value);
      final double adjustedHeight = height * (pageHeight / pdfPageHeight.value);

      page.graphics.drawImage(
        signatureBitmap,
        Rect.fromLTWH(adjustedX, adjustedY, adjustedWidth, adjustedHeight),
      );

      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${directory.path}/signed_$timestamp.pdf';
      await File(outputPath).writeAsBytes(await document.save());
      document.dispose();

      Get.snackbar('Success', 'Signed PDF saved to Downloads');
      selectedPdfPath.value = outputPath;
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign PDF: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> setPdfPageDimensions() async {
    if (selectedPdfPath.value.isEmpty) return;

    final File pdfFile = File(selectedPdfPath.value);
    final PdfDocument document =
        PdfDocument(inputBytes: await pdfFile.readAsBytes());
    final PdfPage page = document.pages[0];

    pdfPageWidth.value = page.getClientSize().width;
    pdfPageHeight.value = page.getClientSize().height;

    document.dispose();
  }

  void setSignature(String path) {
    signatureImagePath.value = path;
    signatureX.value = 50.0;
    signatureY.value = 50.0;
    signatureWidth.value = 150.0;
    signatureHeight.value = 50.0;
    signatureRotation.value = 0.0;
  }
}
