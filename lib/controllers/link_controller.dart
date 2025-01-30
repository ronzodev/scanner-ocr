
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkController extends GetxController {
  static LinkController instance = Get.put(LinkController());

  // open play store
  void shareApp() {
    Share.share(
        'https://play.google.com/store/apps/details?id=com.ronzodev.wallpaper');
  }

  void shareAppLink({String? shareLink}) {
    Share.share(shareLink!);
  }

  // update app
  void openPlayStore() {
    _launch(
        'https://play.google.com/store/apps/details?id=com.ronzodev.snapscan');
  }

  void openPlayStoreLink({String? playstoreLink}) {
    _launch(playstoreLink!);
  }

  void privacyPolicy() {
    _launch('https://sites.google.com/view/snapacan/home');
  }

  void moreApps() {
    _launch('https://play.google.com/store/apps/details?id=com.ronzodev.spaceshoot');
  }

  // contact developer
  void email() {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'ronzodev@gmail.com',
    );
    _launch(emailLaunchUri.toString());
  }

  Future<void> _launch(String url) async {
    // ignore: deprecated_member_use
    if (!await launch(
      url,
    )) {
      throw 'Could not launch $url';
    }
  }




  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }
}