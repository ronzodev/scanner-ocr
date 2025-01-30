import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../controllers/pdf_signature_controller.dart';

class SignatureView extends StatelessWidget {
  final controller = Get.put(PdfSignatureController());
  final signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  SignatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
            final double screenWidth = MediaQuery.of(context).size.width;
                final double screenHeight = MediaQuery.of(context).size.height;

                final double pdfPageWidth = controller.pdfPageWidth.value;
                final double pdfPageHeight = controller.pdfPageHeight.value;

                if (pdfPageWidth == 0 || pdfPageHeight == 0) {
                  Get.snackbar('Error', 'PDF dimensions not available');
                  return;
                }

                final double scaleX = pdfPageWidth / screenWidth;
                final double scaleY = pdfPageHeight / screenHeight;

                final double adjustedX = controller.signatureX.value * scaleX;
                final double adjustedY = controller.signatureY.value * scaleY;
                final double adjustedWidth = 150 * scaleX;
                final double adjustedHeight = 50 * scaleY;

                controller.signPDF(
                  rotation: controller.signatureRotation.value,
                  signatureImagePath: controller.signatureImagePath.value,
                  x: adjustedX,
                  y: adjustedY,
                  width: adjustedWidth,
                  height: adjustedHeight,
                );
              
              
            }
          ),
        ],
      ),
      body: Stack(
        children: [
          // PDF Viewer
          Obx(() {
            final pdfPath = controller.selectedPdfPath.value;
            if (pdfPath.isEmpty) {
              return Center(
                child: ElevatedButton(
                  onPressed: controller.pickPDF,
                  child: const Text('Select PDF'),
                ),
              );
            }
            return PDFView(
              onRender: (pages) {
                controller.pdfPageWidth.value =
                    MediaQuery.of(context).size.width; // Approximation
                controller.pdfPageHeight.value =
                    MediaQuery.of(context).size.height; // Approximation
              },
              filePath: pdfPath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageSnap: true,
              fitPolicy: FitPolicy.BOTH,
            );
          }),

          // Sliding panel for drawing the signature
          SlidingUpPanel(
            minHeight: 50,
            maxHeight: MediaQuery.of(context).size.height / 2,
            panel: Column(
              children: [
                const Icon(Icons.drag_handle),
                const Text('Draw Signature'),
                Expanded(
                  child: Signature(
                    controller: signatureController,
                    backgroundColor: Colors.grey[200]!,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (signatureController.isNotEmpty) {
                          final Uint8List? signatureBytes =
                              await signatureController.toPngBytes();

                          if (signatureBytes != null) {
                            await controller.saveSignature(signatureBytes);
                            controller.setSignature(
                                controller.savedSignatures.last);
                            Get.snackbar('Success', 'Signature saved');
                          } else {
                            Get.snackbar('Error', 'Failed to convert signature');
                          }
                        } else {
                          Get.snackbar('Error', 'No signature to save');
                        }
                      },
                      child: const Text('Save Signature'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        signatureController.clear();
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Display draggable signature
          Obx(() {
            if (controller.signatureImagePath.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Positioned(
              left: controller.signatureX.value,
              top: controller.signatureY.value,
              child: GestureDetector(
                onPanUpdate: (details) {
                  controller.signatureX.value += details.delta.dx;
                  controller.signatureY.value += details.delta.dy;
                },
                child: Transform.rotate(
                  angle: controller.signatureRotation.value * 3.14159265359 / 180,
                  child: SizedBox(
                    width: controller.signatureWidth.value,
                    height: controller.signatureHeight.value,
                    child: Image.file(File(controller.signatureImagePath.value)),
                  ),
                ),
              ),
            );
          }),

          // Signature manipulation buttons
          Row(
            children: [
               IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => controller.removePDF()
          ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => controller.signatureWidth.value += 10,
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => controller.signatureWidth.value -= 10,
              ),
              IconButton(
                icon: const Icon(Icons.rotate_right),
                onPressed: () => controller.signatureRotation.value += 10,
              ),
              IconButton(
                icon: const Icon(Icons.rotate_left),
                onPressed: () => controller.signatureRotation.value -= 10,
              ),
              IconButton(
                icon: const Icon(Icons.cancel_sharp),
                onPressed: () async {
                  final deleted = await controller.deleteSignature();
                  if (deleted) {
                    Get.snackbar('Success', 'Signature deleted');
                  } else {
                    Get.snackbar('Error', 'No signature to delete');
                  }
                },
              ),
            ],
          ),

          // Save Button
          
        ],
      ),
    );
  }
}
