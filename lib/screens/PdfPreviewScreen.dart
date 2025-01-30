// ignore: file_names
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scanner/widget/color.dart';

class PdfPreviewScreen extends StatelessWidget {
  final File pdfFile;

  PdfPreviewScreen({Key? key, required this.pdfFile}) : super(key: key);

  Future<void> savePdf(BuildContext context) async {
    if (await Permission.storage.request().isGranted) {
      try {
        // Use path_provider to get the external storage directory
        final directory = await getExternalStorageDirectory();

        // Construct the path to the Downloads folder
        final downloadsDirectory = Directory(
            '${directory!.parent.parent.parent.parent.path}/Download');

        // Ensure the Downloads directory exists
        if (!await downloadsDirectory.exists()) {
          await downloadsDirectory.create(recursive: true);
        }

        // Generate a unique file name using a timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueFileName = 'saved_text_$timestamp.pdf';

        // Define the file path in the Downloads folder
        final savedFile = File('${downloadsDirectory.path}/$uniqueFileName');

        // Copy the file to the Downloads folder
        await pdfFile.copy(savedFile.path);

        // Notify the user with the file path
        Get.snackbar(
          'Success',
          'PDF saved as $uniqueFileName in the Downloads folder!',
          snackPosition: SnackPosition.BOTTOM,
        );
        Navigator.pop(context);
      } catch (e) {
        // Handle errors
        Get.snackbar(
          'Error',
          'Failed to save PDF: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      // Permission denied
      Get.snackbar(
        'Permission Denied',
        'Please allow storage permissions to save the PDF.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColourDesign().appbg,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: ColourDesign().appbg,
        title: Text(
          'Preview PDF',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PDFView(
              filePath: pdfFile.path,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: true,
              pageFling: true,
              onRender: (pages) {
                debugPrint('PDF Rendered with $pages pages');
              },
              onError: (error) {
                Get.snackbar(
                  'Error',
                  'Failed to load PDF: $error',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              onPageError: (page, error) {
                Get.snackbar(
                  'Error',
                  'Error on page $page: $error',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // onPressed: () async {
                //     await savePdf(context);
                //   },
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(
                            0.2), // First color (transparent white)
                        Colors.blue.withOpacity(
                            0.2), // Second color (transparent blue)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                    border: Border.all(
                      color: Colors.white
                          .withOpacity(0.3), // Border with transparency
                      width: 1.0,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 10.0,
                          sigmaY: 10.0), // Frosted glass blur effect
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .transparent, // Set background to transparent
                          shadowColor: Colors
                              .transparent, // Remove shadow for a clean look
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                16), // Match container radius
                          ),
                        ),
                        onPressed: () async {
                          await savePdf(context);
                        },
                        icon: const Icon(Icons.save_sharp,
                            color: Colors.white), // Adjust icon color
                        label: Text('Save',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ) // Adjust text color
                            ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(
                            0.2), // First color (transparent white)
                        Colors.blue.withOpacity(
                            0.2), // Second color (transparent blue)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                    border: Border.all(
                      color: Colors.white
                          .withOpacity(0.3), // Border with transparency
                      width: 1.0,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 10.0,
                          sigmaY: 10.0), // Frosted glass blur effect
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .transparent, // Set background to transparent
                          shadowColor: Colors
                              .transparent, // Remove shadow for a clean look
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                16), // Match container radius
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white), // Adjust icon color
                        label: Text('Go back',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ) // Adjust text color
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
