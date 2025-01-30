import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Rating {

   static Future<void> showRatingPopup(BuildContext context) async {
    int rating = 4; // Default initial rating
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: Image.asset('assets/images/profile.png'),
              ),
              const Text(
                'We’re constantly improving! Your rating can help us grow🙂. ',
                style: TextStyle(fontSize: 22),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: RatingBar.builder(
                  initialRating: 4,
                  minRating: 1,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (value) {
                    rating = value.toInt();
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style:
                        OutlinedButton.styleFrom(backgroundColor: Colors.white),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 92, 221, 96)),
                    onPressed: () {
                      Get.back();
                      if (rating >= 3) {
                        // Handle high ratings (redirect to Play Store)
                        _redirectToPlayStore();
                      } else {
                        // Show feedback dialog for low ratings
                        _showLowRatingDialog(context);
                      }
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _showLowRatingDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '😔',
                style: TextStyle(fontSize: 50), // Sad emoji
              ),
              const SizedBox(height: 12),
              const Text(
                'We’re sorry to hear that!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'What can we do to improve your experience?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style:
                        OutlinedButton.styleFrom(backgroundColor: Colors.white),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 92, 221, 96)),
                    onPressed: () async {
                      Get.back();
                      const url =
                          'https://forms.gle/JD5dLkAXy15vgy2S7'; // Replace with your Google Form link
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open feedback form'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Proceed',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _redirectToPlayStore() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.ronzodev.wallpaper'; // Replace with your app's package name
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // Handle error if Play Store link cannot be opened
      print('Could not open Play Store');
    }
  }
  
}