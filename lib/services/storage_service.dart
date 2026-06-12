import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class StorageService {
  // Convert image to Base64 — works on both web and mobile
  Future<String> convertXFileToBase64(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      String base64String = base64Encode(bytes);
      return base64String;
    } catch (e) {
      return '';
    }
  }

  // Keep this for mobile file support
  Future<String> convertImageToBase64(File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64String = base64Encode(imageBytes);
      return base64String;
    } catch (e) {
      return '';
    }
  }
}
