import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cross_file/cross_file.dart';

class StorageService {
  StorageService._();

  static Future<void> initialize() async {}

  static Future<String> uploadImageWeb({
    required Uint8List file,
    String? fileName,
    String? bucket = 'portfolio_images',
    String? path,
    String? contentType,
  }) async {
    try {
      final base64String = base64Encode(file);
      final mimeType = contentType ?? 'image/jpeg';
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      debugPrint('StorageService: Upload failed: $e');
      throw Exception('Upload failed: $e');
    }
  }

  static Future<String> uploadImage({
    required dynamic file,
    String? fileName,
    String? bucket = 'portfolio_images',
    String? path,
  }) async {
    try {
      Uint8List bytes;
      if (file is XFile) {
        bytes = await file.readAsBytes();
      } else {
        // Fallback if file is dart:io File but we use dynamic to avoid import issues
        bytes = await file.readAsBytes();
      }
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  static Future<bool> deleteImage(
    String imageUrl, {
    String? bucket = 'portfolio_images',
  }) async {
    return true; // No-op since it's stored in the database
  }

  static Future<String> uploadFile({
    required dynamic file,
    required String fileName,
    String? bucket = 'contact_attachments',
    String? path,
    String? contentType,
  }) async {
    return uploadImage(file: file, fileName: fileName, bucket: bucket, path: path);
  }

  static Future<String> uploadFileWeb({
    required Uint8List file,
    required String fileName,
    String? bucket = 'contact_attachments',
    String? path,
    String? contentType,
  }) async {
    return uploadImageWeb(file: file, fileName: fileName, bucket: bucket, path: path, contentType: contentType);
  }
}
