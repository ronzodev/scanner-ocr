import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scanner/widget/color.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class QrCodeGenerator extends StatefulWidget {
  const QrCodeGenerator({super.key});

  @override
  State<QrCodeGenerator> createState() => _QrCodeGeneratorState();
}

class _QrCodeGeneratorState extends State<QrCodeGenerator> {
  final TextEditingController _textEditingController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  String qrData = '';
  String selectedType = 'text';
  final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'phone': TextEditingController(),
    'email': TextEditingController(),
    'url': TextEditingController()
  };

  String _generateQrData() {
    switch (selectedType) {
      case 'contact':
        return ''' BEGIN: VCARD
          VERSION 3.0
          FN:${_controllers['name']?.text}
          TL:${_controllers['phone']?.text}
          EMAIL:${_controllers['email']?.text}
          END :VCARD ''';

      case 'url':
        String url = _controllers['url']?.text ?? '';

        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          url = 'https://$url';
        }
        return url;

      default:
        return _textEditingController.text;
    }
  }

  Future<void> _shareCodeQr() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/qr_code.png';
    final capture = await _screenshotController.capture();

    if (capture == null) return;

    File imageFile = File(imagePath);
    await imageFile.writeAsBytes(capture);
    await Share.shareXFiles([XFile(imagePath)], text: 'Share QR code');
  }

  // saving the imagae to gallary

  Future<void> _saveImageToGallery(
      ScreenshotController screenshotController) async {
    try {
      // Capture the screenshot
      final Uint8List? capture = await screenshotController.capture();

      if (capture == null) return;

      // Save the image to the gallery using ImageGallerySaver
      final result = await ImageGallerySaver.saveImage(
        capture,
        quality: 60, // Adjust the quality
        name:
            "qr_code_${DateTime.now().millisecondsSinceEpoch}", // Unique name for the image
      );

      if (result['isSuccess']) {
        Get.snackbar('success.', 'successfully saved',
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            icon: const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ));
      } else {
        Get.snackbar('Fialed', 'Failed to save the image',
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            icon: const Icon(
              Icons.warning,
              color: Colors.white,
            ));
      }
    } catch (e) {
      debugPrint('Error saving image: $e');
    }
  }

  Widget _buildTextFiled(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        onChanged: (_) {
          setState(() {
            qrData = _generateQrData();
          });
        },
      ),
    );
  }

  Widget _buildInputField() {
    switch (selectedType) {
      case 'contact':
        return Column(
          children: [
            _buildTextFiled(_controllers['name']!, 'Name'),
            _buildTextFiled(_controllers['phone']!, 'Phone'),
            _buildTextFiled(_controllers['email']!, 'Email')
          ],
        );
      case 'url':
        return _buildTextFiled(_controllers['url']!, 'URL');

      default:
        return TextField(
          controller: _textEditingController,
          decoration: InputDecoration(
              labelText: 'Enter text',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          onChanged: (value) {
            setState(() {
              qrData = value;
            });
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColourDesign().appbg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColourDesign().appbg,
        foregroundColor: Colors.white,
        title: Text(
          'QR code',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: [
                      SegmentedButton<String>(
                        selected: {selectedType},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            selectedType = selection.first;
                            qrData = '';
                          });
                        },
                        segments: const [
                          ButtonSegment(
                              value: 'text',
                              label: Text('text'),
                              icon: Icon(Icons.text_fields)),
                          ButtonSegment(
                              value: 'url',
                              label: Text('URL'),
                              icon: Icon(Icons.link)),
                          ButtonSegment(
                              value: 'contact',
                              label: Text('Contact'),
                              icon: Icon(Icons.contact_page))
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      _buildInputField()
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              if (qrData.isNotEmpty)
                Column(
                  children: [
                    Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Screenshot(
                              controller: _screenshotController,
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(16),
                                child: QrImageView(
                                  data: qrData,
                                  version: QrVersions.auto,
                                  size: 200,
                                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {
                              _saveImageToGallery(_screenshotController);
                            },
                            icon: const Icon(
                              Icons.save,
                              color: Colors.white,
                              size: 50,
                            )),
                        const SizedBox(
                          width: 10,
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
                          // ,
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
                                onPressed: _shareCodeQr,
                                icon: const Icon(Icons.share,
                                    color: Colors.white), // Adjust icon color
                                label: Text('Share QR code',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ) // Adjust text color
                                    ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
