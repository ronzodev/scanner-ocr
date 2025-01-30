import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scanner/data/menu_button.dart';
import 'package:scanner/data/rating.dart';
import '../controllers/ocr_controller.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/util.dart';
import '../widget/color.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class HomeScreen extends StatelessWidget {
  final OcrController controller = Get.put(OcrController());

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a TextEditingController for editing the extracted text
    final TextEditingController textEditingController = TextEditingController();

    // Update the text controller whenever the extracted text changes
    controller.extractedText.listen((value) {
      // Preserve the cursor position before updating the text
      final cursorPosition = textEditingController.selection;

      textEditingController
        ..text = value
        ..selection = cursorPosition.copyWith(
          baseOffset: min(cursorPosition.baseOffset, value.length),
          extentOffset: min(cursorPosition.extentOffset, value.length),
        );
    });

    return Scaffold(
      backgroundColor: ColourDesign().appbg,
      appBar: AppBar(
        leading: MenuButton(),
        actions: [
          IconButton(
            onPressed: () {
              Rating.showRatingPopup(context);
            },
            icon: const Icon(
              IconsaxPlusBold.star,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(
            width: 10,
          )
        ],
        backgroundColor: ColourDesign().appbg,
        title: Text(
          'Smart OCR',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXTRACT TEXT FROM AN IMAGE ',
                          style: GoogleFonts.poppins(

                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            
                          ),
                        ),
                       const  SizedBox(
                          height: 6,
                        ),
                       Text(
                          'Turn images into usable text. \nSave time and effort with accurate OCR',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    )),
                const SizedBox(
                  height: 30,
                ),
                if (controller.imagePath.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(controller.imagePath.value),
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 300,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 21, 19, 180), // First color
                          Color.fromARGB(255, 84, 96, 165), // Second color
                        ],
                        begin: Alignment.topLeft, // Start of the gradient
                        end: Alignment.bottomRight, // End of the gradient
                      ), // Fallback color
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(8.0), // Padding for the image
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/image.png',
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 4), // Padding for the inner text
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .end, // Places text at the bottom
                                children: [
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text('No image selected',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                        borderRadius:
                            BorderRadius.circular(16), // Rounded corners
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
                            onPressed: () => controller
                                .pickAndProcessImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.white), // Adjust icon color
                            label: Text('Camera',
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
                        borderRadius:
                            BorderRadius.circular(16), // Rounded corners
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
                            onPressed: () => controller
                                .pickAndProcessImage(ImageSource.gallery),
                            icon: const Icon(Icons.image,
                                color: Colors.white), // Adjust icon color
                            label: Text(
                              'Gallary',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ), // Adjust text color
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (controller.isProcessing.value)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                if (controller.extractedText.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Extracted Text (Editable):',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: textEditingController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Edit your extracted text here...',
                            ),
                            onChanged: (value) {
                              // Update the controller's extractedText only on change
                              controller.extractedText.value = value;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Share.share(controller.extractedText.value);
                                },
                                icon: const Icon(Icons.share),
                                tooltip: 'Share',
                              ),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                    text: controller.extractedText.value,
                                  ));
                                  Get.snackbar(
                                    'Success',
                                    'Text copied to clipboard',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copy to Clipboard',
                              ),
                              IconButton(
                                onPressed: () async {
                                  final pdfUtils = PdfUtils();

                                  // Create PDF with just the extracted text (no image)
                                  final pdfFile = await pdfUtils.createPdf(
                                      controller.extractedText.value);

                                  // Open the PDF preview screen
                                  pdfUtils.openPdf(context, pdfFile);
                                },
                                icon: const Icon(Icons.picture_as_pdf),
                                tooltip: 'Convert to PDF',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Obx(
        () => controller.extractedText.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(right: 250),
                child: FloatingActionButton(
                  mini: true,
                  onPressed: controller.clearData,
                  backgroundColor: Colors.red,
                  tooltip: 'Clear Data',
                  child: const Icon(Icons.clear),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
