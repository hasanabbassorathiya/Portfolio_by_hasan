/// Image upload widget
/// Handles image selection and upload to Supabase Storage
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:portfolio/core/services/storage_service.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';

class ImageUploadWidget extends StatefulWidget {
  final String? initialImageUrl;
  final String bucket;
  final String? path;
  final Function(String url) onImageUploaded;
  final String label;

  const ImageUploadWidget({
    super.key,
    this.initialImageUrl,
    required this.bucket,
    this.path,
    required this.onImageUploaded,
    this.label = 'Image',
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  String? _imageUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isUploading = true;
          _uploadProgress = 0.0;
        });

        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        // Upload image
        final url = await StorageService.uploadImage(
          file: file,
          bucket: widget.bucket,
          path: widget.path,
          fileName: fileName,
        );

        setState(() {
          _imageUrl = url;
          _isUploading = false;
          _uploadProgress = 1.0;
        });

        widget.onImageUploaded(url);
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppStyles.body(fontWeight: FontWeight.bold)),
        AppUtils().vSpace(size: 8),
        GestureDetector(
          onTap: _isUploading ? null : _pickAndUploadImage,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child:
                _isUploading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          AppUtils().vSpace(size: 16),
                          Text(
                            'Uploading... ${(_uploadProgress * 100).toInt()}%',
                            style: AppStyles.body(),
                          ),
                        ],
                      ),
                    )
                    : _imageUrl != null && _imageUrl!.isNotEmpty
                    ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _imageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 64),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: _pickAndUploadImage,
                            ),
                          ),
                        ),
                      ],
                    )
                    : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          AppUtils().vSpace(size: 8),
                          Text(
                            'Tap to upload image',
                            style: AppStyles.body(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
          ),
        ),
        if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
          AppUtils().vSpace(size: 8),
          Text(
            _imageUrl!,
            style: AppStyles.body(fontSize: 12, color: Colors.grey.shade600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
