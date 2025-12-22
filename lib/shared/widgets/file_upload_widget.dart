/// Enhanced file upload widget
/// Supports both local file upload and direct URL input
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:portfolio/core/services/storage_service.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';

class FileUploadWidget extends StatefulWidget {
  final String? initialUrl;
  final String bucket;
  final String? path;
  final Function(String url) onFileUploaded;
  final String label;
  final FileType fileType;
  final bool allowUrlInput;
  final String? hintText;

  const FileUploadWidget({
    super.key,
    this.initialUrl,
    required this.bucket,
    this.path,
    required this.onFileUploaded,
    this.label = 'File',
    this.fileType = FileType.image,
    this.allowUrlInput = true,
    this.hintText,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  String? _fileUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  final _urlController = TextEditingController();
  bool _isUrlMode = false;

  @override
  void initState() {
    super.initState();
    _fileUrl = widget.initialUrl;
    _urlController.text = widget.initialUrl ?? '';
    _isUrlMode = widget.initialUrl != null && 
                 (widget.initialUrl!.startsWith('http://') || 
                  widget.initialUrl!.startsWith('https://'));
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile() async {
    try {
      debugPrint('FileUploadWidget: Starting file picker...');
      final result = await FilePicker.platform.pickFiles(
        type: widget.fileType,
        allowMultiple: false,
      );

      if (result != null && result.files.single.size > 0) {
        final fileInfo = result.files.single;
        debugPrint('FileUploadWidget: File selected - Name: ${fileInfo.name}, Size: ${fileInfo.size} bytes');
        debugPrint('FileUploadWidget: Platform: ${kIsWeb ? "Web" : "Mobile/Desktop"}');
        debugPrint('FileUploadWidget: Target bucket: ${widget.bucket}, Path: ${widget.path ?? "root"}');
        
        setState(() {
          _isUploading = true;
          _uploadProgress = 0.0;
        });

        try {
          if (kIsWeb) {
            // Web: Use bytes (path is not available on web)
            debugPrint('FileUploadWidget: Web platform - reading bytes...');
            final bytes = fileInfo.bytes;
            if (bytes == null) {
              throw Exception('Failed to read file bytes. Please try again.');
            }
            
            debugPrint('FileUploadWidget: Bytes read successfully (${bytes.length} bytes)');
            debugPrint('FileUploadWidget: Calling StorageService.uploadImageWeb...');
            
            final url = await StorageService.uploadImageWeb(
              file: bytes,
              bucket: widget.bucket,
              path: widget.path,
              fileName: fileInfo.name,
            );
            
            debugPrint('FileUploadWidget: Upload successful! URL: $url');
            
            setState(() {
              _fileUrl = url;
              _isUploading = false;
              _uploadProgress = 1.0;
            });
            widget.onFileUploaded(url);
          } else {
            // Mobile/Desktop: Use File path
            debugPrint('FileUploadWidget: Mobile/Desktop platform - using file path...');
            final filePath = fileInfo.path;
            if (filePath == null) {
              throw Exception('File path is not available');
            }
            
            debugPrint('FileUploadWidget: File path: $filePath');
            final file = File(filePath);
            final fileName = fileInfo.name;

            String url;
            if (widget.fileType == FileType.image) {
              debugPrint('FileUploadWidget: Uploading as image...');
              url = await StorageService.uploadImage(
                file: file,
                bucket: widget.bucket,
                path: widget.path,
                fileName: fileName,
              );
            } else {
              debugPrint('FileUploadWidget: Uploading as generic file...');
              // For other file types, use generic upload
              url = await StorageService.uploadFile(
                file: file,
                bucket: widget.bucket,
                path: widget.path,
                fileName: fileName,
              );
            }

            debugPrint('FileUploadWidget: Upload successful! URL: $url');
            
            setState(() {
              _fileUrl = url;
              _isUploading = false;
              _uploadProgress = 1.0;
            });
            widget.onFileUploaded(url);
          }
        } catch (uploadError, stackTrace) {
          debugPrint('FileUploadWidget: Upload error occurred!');
          debugPrint('FileUploadWidget: Error type: ${uploadError.runtimeType}');
          debugPrint('FileUploadWidget: Error message: $uploadError');
          debugPrint('FileUploadWidget: Stack trace: $stackTrace');
          // Re-throw with better error message
          throw Exception('Upload failed: $uploadError');
        }
      } else {
        debugPrint('FileUploadWidget: No file selected or file is empty');
        throw Exception('No file selected or file is empty');
      }
    } catch (e, stackTrace) {
      debugPrint('FileUploadWidget: Exception caught in _pickAndUploadFile');
      debugPrint('FileUploadWidget: Error type: ${e.runtimeType}');
      debugPrint('FileUploadWidget: Error message: $e');
      debugPrint('FileUploadWidget: Stack trace: $stackTrace');
      
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading file: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _handleUrlSubmit() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty && 
        (url.startsWith('http://') || url.startsWith('https://'))) {
      setState(() {
        _fileUrl = url;
        _isUrlMode = true;
      });
      widget.onFileUploaded(url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid URL (http:// or https://)'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: AppStyles.body(fontWeight: FontWeight.bold),
            ),
            if (widget.allowUrlInput)
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isUrlMode = !_isUrlMode;
                        if (!_isUrlMode) {
                          _urlController.clear();
                        }
                      });
                    },
                    icon: Icon(
                      _isUrlMode ? Icons.upload_file : Icons.link,
                      size: 16,
                    ),
                    label: Text(
                      _isUrlMode ? 'Upload File' : 'Enter URL',
                      style: AppStyles.body(fontSize: 12),
                    ),
                  ),
                ],
              ),
          ],
        ),
        AppUtils().vSpace(size: 8),
        if (_isUrlMode && widget.allowUrlInput)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'File URL',
                  hintText: widget.hintText ?? 'https://example.com/image.jpg',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _handleUrlSubmit,
                  ),
                ),
                keyboardType: TextInputType.url,
                onFieldSubmitted: (_) => _handleUrlSubmit(),
              ),
              if (_fileUrl != null && _fileUrl!.isNotEmpty) ...[
                AppUtils().vSpace(size: 8),
                _buildPreview(),
              ],
            ],
          )
        else
          GestureDetector(
            onTap: _isUploading ? null : _pickAndUploadFile,
            child: Container(
              height: widget.fileType == FileType.image ? 200 : 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: _isUploading
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
                  : _fileUrl != null && _fileUrl!.isNotEmpty
                      ? _buildPreview()
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.fileType == FileType.image
                                    ? Icons.cloud_upload_outlined
                                    : Icons.upload_file,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              AppUtils().vSpace(size: 8),
                              Text(
                                'Tap to ${widget.fileType == FileType.image ? "upload image" : "upload file"}',
                                style: AppStyles.body(color: Colors.grey.shade600),
                              ),
                              if (widget.allowUrlInput) ...[
                                AppUtils().vSpace(size: 4),
                                Text(
                                  'or enter URL',
                                  style: AppStyles.body(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
            ),
          ),
        if (_fileUrl != null && _fileUrl!.isNotEmpty && !_isUrlMode) ...[
          AppUtils().vSpace(size: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _fileUrl!,
                  style: AppStyles.body(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () {
                  setState(() {
                    _isUrlMode = true;
                    _urlController.text = _fileUrl ?? '';
                  });
                },
                tooltip: 'Edit URL',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _fileUrl = null;
                    _urlController.clear();
                  });
                  widget.onFileUploaded('');
                },
                tooltip: 'Remove',
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPreview() {
    if (widget.fileType == FileType.image) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _fileUrl!,
              width: double.infinity,
              height: widget.fileType == FileType.image ? 200 : 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 64),
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
                onPressed: _isUrlMode
                    ? () {
                        setState(() {
                          _isUrlMode = false;
                        });
                      }
                    : _pickAndUploadFile,
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file, size: 48),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'File URL',
                    style: AppStyles.body(fontWeight: FontWeight.bold),
                  ),
                  AppUtils().vSpace(size: 4),
                  Text(
                    _fileUrl!,
                    style: AppStyles.body(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _isUrlMode
                  ? () {
                      setState(() {
                        _isUrlMode = false;
                      });
                    }
                  : _pickAndUploadFile,
            ),
          ],
        ),
      );
    }
  }
}

