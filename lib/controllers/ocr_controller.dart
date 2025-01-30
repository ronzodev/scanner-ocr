import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrController extends GetxController {
  final _imagePicker = ImagePicker();
  final _textRecognizer = TextRecognizer();
  
  final Rx<String> extractedText = ''.obs;
  final RxBool isProcessing = false.obs;
  final RxString imagePath = ''.obs;

  Future<void> pickAndProcessImage(ImageSource source) async {
    try {
      isProcessing.value = true;
      final XFile? image = await _imagePicker.pickImage(source: source);
      
      if (image != null) {
        imagePath.value = image.path;
        final inputImage = InputImage.fromFilePath(image.path);
        final recognizedText = await _textRecognizer.processImage(inputImage);
        extractedText.value = recognizedText.text;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to process image: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  void clearData() {
    extractedText.value = '';
    imagePath.value = '';
  }

  @override
  void onClose() {
    _textRecognizer.close();
    super.onClose();
  }
} 