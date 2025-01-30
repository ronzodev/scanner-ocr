import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:scanner/widget/color.dart';

import '../barcode/home_barcode.dart';
import '../controllers/navigator_controller.dart';
import 'home_screen.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  final NavigationController navigationController = Get.put(NavigationController());
  // final AdController adController = Get.put(AdController());

  final List<Widget> pages = [
    HomeScreen(),
    const HomeBarcode(),

  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: navigationController.selectedIndex.value,
          children: pages,
        ),
        bottomNavigationBar: CurvedNavigationBar(
          
          backgroundColor: Colors.transparent, // Make background transparent
          color: ColourDesign().navbar, // Background color of the navigation bar
          buttonBackgroundColor: const Color.fromARGB(255, 55, 55, 65),
           // Color of the floating button
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          height: 60.0,
          items: const <Widget>[
            Icon(Icons.document_scanner_outlined,size: 40, color: Colors.white,),
            Icon(Icons.qr_code_2,size: 40, color: Colors.white ,)
            
           
          ],
          onTap: navigationController.changeIndex,
        ),
       
      );
    });
  }
}