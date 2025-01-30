import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/link_controller.dart';

class MenuButton extends StatelessWidget {
  
  LinkController linkController = Get.put(LinkController());

 

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
       color: Colors.white,
       iconColor: Colors.white,
      onSelected: (String value) {
        switch (value) {
          case 'Share':
            linkController.shareApp();
            break;
          case 'Privacy Policy':
            linkController.privacyPolicy();
            break;
          case 'More Apps':
            linkController.moreApps();
            break;  
          default:
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return {'Share', 'Privacy Policy','More Apps'}.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
    );
  }
}