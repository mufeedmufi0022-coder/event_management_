import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

class StorageService {
  Future<String?> uploadImage(String folder, File imageFile) async {
    try {
      // Read file bytes
      List<int> imageBytes = await imageFile.readAsBytes();
      // Convert to base64 string
      String base64Image = base64Encode(imageBytes);
      // Get extension to include in data URI if needed, or just return the base64
      String extension = path.extension(imageFile.path).replaceFirst('.', '');
      if (extension == 'jpg') extension = 'jpeg';
      
      // Returning as a Data URI so it can be easily recognized as an image
      return 'data:image/$extension;base64,$base64Image';
    } catch (e) {
      print('Base64 Conversion Error: $e');
      return null;
    }
  }

  Future<void> deleteFile(String url) async {
    // No-op for base64 storage since it's just a string in the database
    try {
      print('Note: Base64 string deletion is handled by removing the string from the database.');
    } catch (e) {
      print('Storage Delete Error: $e');
    }
  }
}
