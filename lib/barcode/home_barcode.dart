import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scanner/widget/color.dart';

import 'qr_code_genrator.dart';
import 'qr_code_scanner.dart';

class HomeBarcode extends StatelessWidget {
  const HomeBarcode({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColourDesign().appbg,
      body: SafeArea(
          child: Column(
        children: [
          const SizedBox(
            height: 15.0,
          ),
           Padding(
            padding: const EdgeInsets.all(23.0),
            child: Text('QR Code', style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(23),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5)
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildFeatureButton(
                      context,
                      "Generate QR CODE",
                      Icons.qr_code,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QrCodeGenerator())))

                            , const  SizedBox(height: 20,),

                            _buildFeatureButton(
                      context,
                      "Scan QR CODE",
                      Icons.qr_code_scanner,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QrCodeScanner())))
                ],
              ),
            ),
          )
        ],
      )),
    );
  }

  Widget _buildFeatureButton(BuildContext context, String title, IconData icon,
      VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(15),
        height: 200,
        width: 250,
        decoration: BoxDecoration(
            color: Colors.indigo, borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              icon,
              size: 90,
              color: Colors.white,
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
