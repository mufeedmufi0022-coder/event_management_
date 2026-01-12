import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

class ImageHelper {
  static final _picker = ImagePicker();
  static final _storageService = StorageService();

  static Future<String?> pickAndUploadImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 25,
        maxWidth: 500,
        maxHeight: 500,
      );
      if (image == null) return null;

      final file = File(image.path);
      // Using Base64 encoding via StorageService to avoid Firebase Storage configuration issues (404s)
      return await _storageService.uploadImage('profiles', file);
    } catch (e) {
      print('Error picking/uploading image: $e');
      return null;
    }
  }
  static Widget displayImage(String? imageSource, {BoxFit fit = BoxFit.cover, double? width, double? height}) {
    if (imageSource == null || imageSource.isEmpty) {
      return Container(
        color: Colors.grey[200],
        width: width,
        height: height,
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }

    if (imageSource.startsWith('data:image')) {
      try {
        final base64String = imageSource.split(',').last;
        final Uint8List bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
        );
      } catch (e) {
        print('Error decoding base64 image: $e');
        return const Icon(Icons.broken_image);
      }
    } else {
      return Image.network(
        imageSource,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
      );
    }
  }

  static ImageProvider? getImageProvider(String? imageSource) {
    if (imageSource == null || imageSource.isEmpty) return null;

    if (imageSource.startsWith('data:image')) {
      try {
        final base64String = imageSource.split(',').last;
        final Uint8List bytes = base64Decode(base64String);
        return MemoryImage(bytes);
      } catch (e) {
        print('Error decoding base64 image provider: $e');
        return null;
      }
    } else {
      return NetworkImage(imageSource);
    }
  }
}
