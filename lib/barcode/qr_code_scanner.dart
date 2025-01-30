import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scanner/widget/color.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_barcode.dart';

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({super.key});

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  bool hasPermission = false;
  bool isFlashOn = false;

  late MobileScannerController scannerController;

  @override
  void initState() {
    super.initState();

    scannerController = MobileScannerController();
    _checkPermission();
  }

  

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      hasPermission = status.isGranted;
    });
  }

  Future<void> _processScanner(String? data) async {
    if (data == null) return;
    scannerController.stop();
    String type = 'Text';

    if (data.startsWith('BEGIN:VCARD')) {
      type = 'contact';
    } else if (data.startsWith('http://') || data.startsWith('http://')) {
      type = 'url';
    }

     showModalBottomSheet(
      
        
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => GestureDetector(
          onTap: () {
            Get.off( const HomeBarcode());
          },
          child: DraggableScrollableSheet(
            
                initialChildSize: 0.6,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                builder: (context, controller) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      Text(
                        'Scanner Result: ',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        'Type: ${type.toUpperCase()}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.indigo),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                        controller: controller,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              data,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            if (type == 'url')
                              ElevatedButton.icon(
                                onPressed: () {
                                   _launchURL(data);
                                },
                                label: const Text('Open Url'),
                                icon: const Icon(Icons.open_in_new),
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50)),
                              ),
                            if (type == 'contact')
                              ElevatedButton.icon(
                                onPressed: () {
                                   _saveContact(data);
                                },
                                label: const Text('save contact'),
                                icon: const Icon(Icons.open_in_new),
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50)),
                              )
                          ],
                        ),
                      )),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: OutlinedButton.icon(
                            onPressed: () {
                              Share.share(data);
                            },
                            label: const Text('Share'),
                            icon: const Icon(Icons.share),
                          )),
                          const SizedBox(
                            height: 16,
                          ),
                          Expanded(
                              child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              scannerController.start();
                            },
                            label: const Text('Scan Again'),
                            icon: const Icon(Icons.qr_code_scanner),
                          )),
                        ],
                      )
                    ],
                  ),
                ),
              ),
        ));

            
    
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _saveContact(String vcardData) async {
    final lines = vcardData.split('\n');
    String name = '';
    String phone = '';
    String email = '';

    for (var line in lines) {
      if (line.startsWith('FN:')) name = line.substring(3);
      if (line.startsWith('TEL:')) phone = line.substring(4);
      if (line.startsWith('EMAIL:')) email = line.substring(5);
    }

    final contact = contacts.Contact()
      ..name.first = name ?? ''
      ..phones = [contacts.Phone(phone ?? '')]
      ..emails = [contacts.Email(email ?? '')];

    try {
      await contact.insert();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('contact saved')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('failed!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasPermission) {
      return Scaffold(
        backgroundColor: Colors.indigo,
        appBar: AppBar(
          title: const Text('Scanner'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                height: 350,
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                       const Icon(
                          Icons.camera_alt_rounded,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                       const Text('camera permision is Required,', ),
                       const SizedBox(
                          height: 16,
                        ),
                        ElevatedButton(
                          onPressed: _checkPermission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                          ),
                          child: const Text('Grant Permission',style: TextStyle(color: Colors.white),),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: ColourDesign().appbg,
        appBar: AppBar(
          title:  Text(
            'Scan QR Code ',

            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold

            ),
          ),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    isFlashOn = !isFlashOn;
                    scannerController.toggleTorch();
                  });
                },
                icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off))
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: scannerController,
              onDetect: (capture) {
                final barcode = capture.barcodes.first;
                if (barcode.rawValue != null) {
                  final String code = barcode.rawValue!;
                  _processScanner(code);
                }
              },
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text('Align QR code within the fram', style: TextStyle(color: Colors.white,
                backgroundColor: Colors.black.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w300),
                
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
