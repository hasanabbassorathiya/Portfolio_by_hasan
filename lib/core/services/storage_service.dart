/// Storage service
/// Handles file uploads to Supabase Storage
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class StorageService {
  StorageService._();

  /// Upload image to Supabase Storage
  /// Returns the public URL of the uploaded file
  static Future<String> uploadImage({
    required File file,
    required String bucket,
    String? path,
    String? fileName,
  }) async {
    try {
      final storage = SupabaseService.storage;

      // Generate unique filename if not provided
      final uniqueFileName =
          fileName ??
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      // Construct full path
      final fullPath = path != null ? '$path/$uniqueFileName' : uniqueFileName;

      // Upload file (Supabase accepts File directly)
      await storage
          .from(bucket)
          .upload(
            fullPath,
            file,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      // Get public URL
      final publicUrl = storage.from(bucket).getPublicUrl(fullPath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload image from web (File or Uint8List)
  static Future<String> uploadImageWeb({
    required dynamic file, // Can be File or Uint8List
    required String bucket,
    String? path,
    String? fileName,
  }) async {
    try {
      final storage = SupabaseService.storage;

      // Generate unique filename
      final uniqueFileName =
          fileName ?? '${DateTime.now().millisecondsSinceEpoch}_image.jpg';

      // Construct full path
      final fullPath = path != null ? '$path/$uniqueFileName' : uniqueFileName;

      // For web, we need to handle File or Uint8List
      if (file is File) {
        // Upload file directly
        await storage
            .from(bucket)
            .upload(
              fullPath,
              file,
              fileOptions: const FileOptions(
                upsert: true,
                contentType: 'image/jpeg',
              ),
            );
      } else if (file is Uint8List) {
        // For Uint8List, we need to create a temporary file or use bytes
        // Supabase web might need different handling
        await storage
            .from(bucket)
            .uploadBinary(
              fullPath,
              file,
              fileOptions: const FileOptions(
                upsert: true,
                contentType: 'image/jpeg',
              ),
            );
      } else {
        throw Exception('Unsupported file type');
      }

      // Get public URL
      final publicUrl = storage.from(bucket).getPublicUrl(fullPath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete file from storage
  static Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await SupabaseService.storage.from(bucket).remove([path]);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// List files in a bucket
  static Future<List<FileObject>> listFiles({
    required String bucket,
    String? path,
  }) async {
    try {
      final response = await SupabaseService.storage
          .from(bucket)
          .list(path: path);
      return response;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  /// Get public URL for a file
  static String getPublicUrl({required String bucket, required String path}) {
    return SupabaseService.storage.from(bucket).getPublicUrl(path);
  }

  /// Get signed URL for private file
  static Future<String> getSignedUrl({
    required String bucket,
    required String path,
    int expiresIn = 3600, // 1 hour default
  }) async {
    try {
      final response = await SupabaseService.storage
          .from(bucket)
          .createSignedUrl(path, expiresIn);
      return response;
    } catch (e) {
      throw Exception('Failed to get signed URL: $e');
    }
  }
}
