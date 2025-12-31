import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'dart:io';

class AIService {
  final ImagePicker _picker = ImagePicker();
  final ImageLabeler _labeler;

  AIService() : _labeler = ImageLabeler(options: ImageLabelerOptions());


  Future<File?> pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      print("Image path: ${file.path}");
      return file;
    }
    return null;
  }

  Future<List<String>> labelImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);

    try {
      final List<ImageLabel> labels = await _labeler.processImage(inputImage);

      return labels
          .where((label) => label.confidence > 0.7)
          .map((label) => label.label)
          .take(5)
          .toList();
    } catch (e) {
      throw Exception("Image labeling failed: $e");
    } finally {
      _labeler.close();
    }
  }

  void dispose() {
    _labeler.close();
  }
}