import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(String folder, File imageFile) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      Reference ref = _storage.ref().child(folder).child(fileName);
      
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Storage Upload Error: $e');
      return null;
    }
  }

  Future<void> deleteFile(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      print('Storage Delete Error: $e');
    }
  }
}
