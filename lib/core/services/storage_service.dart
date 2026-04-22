/// Storage service
/// Handles file uploads to Supabase Storage
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;
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
    debugPrint('StorageService.uploadImage: Starting upload...');
    debugPrint('StorageService.uploadImage: Bucket: $bucket');
    debugPrint('StorageService.uploadImage: Path: ${path ?? "root"}');
    debugPrint('StorageService.uploadImage: File: ${file.path}');
    
    if (!SupabaseService.isInitialized) {
      debugPrint('StorageService.uploadImage: ERROR - Supabase not initialized');
      throw Exception('Supabase not initialized. Cannot upload images.');
    }
    
    try {
      final storage = SupabaseService.storage!;
      debugPrint('StorageService.uploadImage: Storage instance obtained');

      // Generate unique filename if not provided
      final uniqueFileName =
          fileName ??
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      debugPrint('StorageService.uploadImage: Unique filename: $uniqueFileName');

      // Construct full path
      final fullPath = path != null ? '$path/$uniqueFileName' : uniqueFileName;
      debugPrint('StorageService.uploadImage: Full path: $fullPath');

      // Check if bucket exists
      debugPrint('StorageService.uploadImage: Checking bucket access...');
      try {
        await storage.from(bucket).list();
        debugPrint('StorageService.uploadImage: Bucket access confirmed');
      } catch (bucketError) {
        debugPrint('StorageService.uploadImage: ERROR - Bucket check failed');
        debugPrint('StorageService.uploadImage: Bucket error: $bucketError');
        throw Exception('Bucket "$bucket" not found or not accessible. Please create the bucket in Supabase Storage first. Error: $bucketError');
      }

      // Upload file (Supabase accepts File directly)
      debugPrint('StorageService.uploadImage: Starting file upload...');
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
      debugPrint('StorageService.uploadImage: File upload completed');

      // Get public URL
      final publicUrl = storage.from(bucket).getPublicUrl(fullPath);
      debugPrint('StorageService.uploadImage: Public URL: $publicUrl');

      return publicUrl;
    } catch (e, stackTrace) {
      debugPrint('StorageService.uploadImage: ERROR occurred');
      debugPrint('StorageService.uploadImage: Error type: ${e.runtimeType}');
      debugPrint('StorageService.uploadImage: Error message: $e');
      debugPrint('StorageService.uploadImage: Stack trace: $stackTrace');
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
    debugPrint('StorageService.uploadImageWeb: Starting web upload...');
    debugPrint('StorageService.uploadImageWeb: Bucket: $bucket');
    debugPrint('StorageService.uploadImageWeb: Path: ${path ?? "root"}');
    debugPrint('StorageService.uploadImageWeb: File type: ${file.runtimeType}');
    
    if (!SupabaseService.isInitialized) {
      debugPrint('StorageService.uploadImageWeb: ERROR - Supabase not initialized');
      throw Exception('Supabase not initialized. Cannot upload images.');
    }
    
    // Check authentication
    final session = SupabaseService.auth?.currentSession;
    if (session == null) {
      debugPrint('StorageService.uploadImageWeb: ERROR - User not authenticated');
      debugPrint('StorageService.uploadImageWeb: RLS policies require authentication');
      throw Exception('You must be logged in to upload files. Please log in first.');
    }
    debugPrint('StorageService.uploadImageWeb: User authenticated - ${session.user.email}');
    debugPrint('StorageService.uploadImageWeb: User ID - ${session.user.id}');
    
    try {
      final storage = SupabaseService.storage!;
      debugPrint('StorageService.uploadImageWeb: Storage instance obtained');

      // Generate unique filename
      final uniqueFileName =
          fileName ?? '${DateTime.now().millisecondsSinceEpoch}_image.jpg';
      debugPrint('StorageService.uploadImageWeb: Unique filename: $uniqueFileName');

      // Construct full path
      final fullPath = path != null ? '$path/$uniqueFileName' : uniqueFileName;
      debugPrint('StorageService.uploadImageWeb: Full path: $fullPath');

      // Check if bucket exists - for contact_attachments, we allow public uploads
      debugPrint('StorageService.uploadImageWeb: Checking bucket access...');
      try {
        await storage.from(bucket).list();
        debugPrint('StorageService.uploadImageWeb: Bucket access confirmed');
      } catch (bucketError) {
        debugPrint('StorageService.uploadImageWeb: ERROR - Bucket check failed');
        debugPrint('StorageService.uploadImageWeb: Bucket error: $bucketError');
        // For contact_attachments bucket, try to continue anyway as it might be a permissions issue
        if (bucket == 'contact_attachments') {
          debugPrint('StorageService.uploadImageWeb: Continuing with contact_attachments upload despite bucket check failure');
        } else {
          throw Exception('Bucket "$bucket" not found or not accessible. Please create the bucket in Supabase Storage first. Error: $bucketError');
        }
      }

      // For web, we need to handle File or Uint8List
      if (file is File) {
        debugPrint('StorageService.uploadImageWeb: Uploading as File object...');
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
        debugPrint('StorageService.uploadImageWeb: File upload completed');
      } else if (file is Uint8List) {
        debugPrint('StorageService.uploadImageWeb: Uploading as Uint8List (${file.length} bytes)...');
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
        debugPrint('StorageService.uploadImageWeb: Binary upload completed');
      } else {
        debugPrint('StorageService.uploadImageWeb: ERROR - Unsupported file type: ${file.runtimeType}');
        throw Exception('Unsupported file type: ${file.runtimeType}');
      }

      // Get public URL
      final publicUrl = storage.from(bucket).getPublicUrl(fullPath);
      debugPrint('StorageService.uploadImageWeb: Public URL: $publicUrl');

      return publicUrl;
    } catch (e, stackTrace) {
      debugPrint('StorageService.uploadImageWeb: ERROR occurred');
      debugPrint('StorageService.uploadImageWeb: Error type: ${e.runtimeType}');
      debugPrint('StorageService.uploadImageWeb: Error message: $e');
      debugPrint('StorageService.uploadImageWeb: Stack trace: $stackTrace');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload any file type to Supabase Storage
  /// Returns the public URL of the uploaded file
  static Future<String> uploadFile({
    required File file,
    required String bucket,
    String? path,
    String? fileName,
    String? contentType,
  }) async {
    if (!SupabaseService.isInitialized) {
      throw Exception('Supabase not initialized. Cannot upload files.');
    }
    
    try {
      final storage = SupabaseService.storage!;

      // Generate unique filename if not provided
      final uniqueFileName =
          fileName ??
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      // Construct full path
      final fullPath = path != null ? '$path/$uniqueFileName' : uniqueFileName;

      // Detect content type if not provided
      final detectedContentType = contentType ?? _detectContentType(file.path);

      // Upload file
      await storage
          .from(bucket)
          .upload(
            fullPath,
            file,
            fileOptions: FileOptions(
              upsert: true,
              contentType: detectedContentType,
            ),
          );

      // Get public URL
      final publicUrl = storage.from(bucket).getPublicUrl(fullPath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Detect content type from file extension
  static String _detectContentType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'zip':
        return 'application/zip';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  /// Delete file from storage
  static Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    if (!SupabaseService.isInitialized) {
      throw Exception('Supabase not initialized. Cannot delete files.');
    }
    
    try {
      await SupabaseService.storage!.from(bucket).remove([path]);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// List files in a bucket
  static Future<List<FileObject>> listFiles({
    required String bucket,
    String? path,
  }) async {
    if (!SupabaseService.isInitialized) {
      throw Exception('Supabase not initialized. Cannot list files.');
    }
    
    try {
      final response = await SupabaseService.storage!
          .from(bucket)
          .list(path: path);
      return response;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  /// Get public URL for a file
  static String getPublicUrl({required String bucket, required String path}) {
    if (!SupabaseService.isInitialized) {
      throw Exception('Supabase not initialized. Cannot get public URL.');
    }
    return SupabaseService.storage!.from(bucket).getPublicUrl(path);
  }

  /// Get signed URL for private file
  static Future<String> getSignedUrl({
    required String bucket,
    required String path,
    int expiresIn = 3600, // 1 hour default
  }) async {
    if (!SupabaseService.isInitialized) {
      throw Exception('Supabase not initialized. Cannot get signed URL.');
    }
    
    try {
      final response = await SupabaseService.storage!
          .from(bucket)
          .createSignedUrl(path, expiresIn);
      return response;
    } catch (e) {
      throw Exception('Failed to get signed URL: $e');
    }
  }
}
