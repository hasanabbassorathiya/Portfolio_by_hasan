/// Resume Parser Dialog
/// Allows uploading a resume PDF and automatically populating portfolio sections
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:portfolio/core/services/resume_parser_service.dart';
import 'package:portfolio/core/services/resume_parser_api_service.dart';
import 'package:portfolio/core/services/storage_service.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/core/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';

class ResumeParserDialog extends StatefulWidget {
  const ResumeParserDialog({super.key});

  @override
  State<ResumeParserDialog> createState() => _ResumeParserDialogState();
}

class _ResumeParserDialogState extends State<ResumeParserDialog> {
  bool _isUploading = false;
  bool _isParsing = false;
  ParsedResumeData? _parsedData;
  String? _errorMessage;
  String? _uploadedResumeUrl;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upload & Parse Resume',
                  style: AppStyles.heading(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            AppUtils().vSpace(size: 24),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700),
                    AppUtils().hSpace(size: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppStyles.body(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              AppUtils().vSpace(size: 16),
            ],
            if (_parsedData == null) ...[
              _buildUploadSection(),
            ] else ...[
              Expanded(
                child: SingleChildScrollView(
                  child: _buildPreviewSection(),
                ),
              ),
              AppUtils().vSpace(size: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _parsedData = null;
                        _errorMessage = null;
                      });
                    },
                    child: const Text('Upload Different Resume'),
                  ),
                  AppUtils().hSpace(size: 12),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _applyParsedData,
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Apply to Portfolio'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.primaryColor.withOpacity(0.05),
          ),
          child: Column(
            children: [
              Icon(
                Icons.upload_file,
                size: 64,
                color: AppColors.primaryColor,
              ),
              AppUtils().vSpace(size: 16),
              Text(
                'Upload your resume (PDF)',
                style: AppStyles.heading(fontSize: 18),
              ),
              AppUtils().vSpace(size: 8),
              Text(
                'We\'ll extract your information and populate your portfolio sections automatically',
                style: AppStyles.body(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              AppUtils().vSpace(size: 24),
              ElevatedButton.icon(
                onPressed: _isParsing ? null : _pickAndParseResume,
                icon: _isParsing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label: Text(_isParsing ? 'Parsing...' : 'Select PDF Resume'),
              ),
            ],
          ),
        ),
        AppUtils().vSpace(size: 16),
        Text(
          'Note: The parser will extract:\n• Personal information (name, email, phone, location)\n• Work experience\n• Skills\n• Education\n• Social links\n• Projects',
          style: AppStyles.body(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    if (_parsedData == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview Extracted Data',
          style: AppStyles.heading(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        AppUtils().vSpace(size: 16),
        _buildPreviewCard(
          'Personal Information',
          [
            if (_parsedData!.name != null) 'Name: ${_parsedData!.name}',
            if (_parsedData!.email != null) 'Email: ${_parsedData!.email}',
            if (_parsedData!.phone != null) 'Phone: ${_parsedData!.phone}',
            if (_parsedData!.location != null) 'Location: ${_parsedData!.location}',
            if (_parsedData!.title != null) 'Title: ${_parsedData!.title}',
            if (_parsedData!.bio != null) 'Bio: ${_parsedData!.bio}',
          ],
        ),
        if (_parsedData!.experiences.isNotEmpty) ...[
          AppUtils().vSpace(size: 12),
          _buildPreviewCard(
            'Work Experience (${_parsedData!.experiences.length})',
            _parsedData!.experiences.map((e) {
              return '${e.position} at ${e.company}${e.isCurrent ? " (Current)" : ""}';
            }).toList(),
          ),
        ],
        if (_parsedData!.skills.isNotEmpty) ...[
          AppUtils().vSpace(size: 12),
          _buildPreviewCard(
            'Skills (${_parsedData!.skills.length})',
            _parsedData!.skills,
          ),
        ],
        if (_parsedData!.education.isNotEmpty) ...[
          AppUtils().vSpace(size: 12),
          _buildPreviewCard(
            'Education (${_parsedData!.education.length})',
            _parsedData!.education.map((e) {
              return '${e.degree ?? "Degree"} from ${e.institution}';
            }).toList(),
          ),
        ],
        if (_parsedData!.socialLinks.isNotEmpty) ...[
          AppUtils().vSpace(size: 12),
          _buildPreviewCard(
            'Social Links (${_parsedData!.socialLinks.length})',
            _parsedData!.socialLinks.entries.map((e) {
              return '${e.key}: ${e.value}';
            }).toList(),
          ),
        ],
        if (_parsedData!.projects.isNotEmpty) ...[
          AppUtils().vSpace(size: 12),
          _buildPreviewCard(
            'Projects (${_parsedData!.projects.length})',
            _parsedData!.projects.map((e) => e.name).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewCard(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppStyles.heading(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (items.isEmpty) ...[
              AppUtils().vSpace(size: 8),
              Text(
                'No data found',
                style: AppStyles.body(color: AppColors.textSecondary),
              ),
            ] else ...[
              AppUtils().vSpace(size: 12),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $item',
                      style: AppStyles.body(),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndParseResume() async {
    try {
      setState(() {
        _isParsing = true;
        _errorMessage = null;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isParsing = false;
        });
        return;
      }

      final file = result.files.single;
      ParsedResumeData? parsedData;
      String uploadedFileUrl;

      // First, upload the file to storage
      if (kIsWeb && file.bytes != null) {
        // Web: use bytes
        final storage = SupabaseService.storage!;
        final fileName = 'resume_${DateTime.now().millisecondsSinceEpoch}.pdf';
        await storage.from('resumes').uploadBinary(
          fileName,
          file.bytes!,
          fileOptions: FileOptions(
            upsert: true,
            contentType: 'application/pdf',
          ),
        );
        uploadedFileUrl = storage.from('resumes').getPublicUrl(fileName);
        _uploadedResumeUrl = uploadedFileUrl; // Store for later use
      } else if (!kIsWeb && file.path != null) {
        // Mobile/Desktop: use path
        uploadedFileUrl = await StorageService.uploadFile(
          file: File(file.path!),
          bucket: 'resumes',
          fileName: 'resume_${DateTime.now().millisecondsSinceEpoch}.pdf',
          contentType: 'application/pdf',
        );
        _uploadedResumeUrl = uploadedFileUrl; // Store for later use
      } else {
        throw Exception('Failed to process file');
      }

      // Now parse using Edge Function
      parsedData = await ResumeParserApiService.parseResumeViaAPI(
        fileUrl: uploadedFileUrl,
        bucket: 'resumes',
        fileName: uploadedFileUrl.split('/').last,
      );

      // File is already uploaded during parsing, so we can use that URL
      // The uploadedFileUrl from parsing step is stored in _uploadedResumeUrl

      setState(() {
        _parsedData = parsedData;
        _isParsing = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error parsing resume: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Error parsing resume: ${e.toString()}';
        _isParsing = false;
      });
    }
  }

  Future<void> _applyParsedData() async {
    if (_parsedData == null) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      // Update profile
      final profileRepo = ProfileRepository();
      final currentProfile = await profileRepo.getProfile();

      if (currentProfile != null) {
        final profileData = <String, dynamic>{};
        if (_parsedData!.name != null) profileData['name'] = _parsedData!.name;
        if (_parsedData!.email != null) profileData['email'] = _parsedData!.email;
        if (_parsedData!.phone != null) profileData['phone'] = _parsedData!.phone;
        if (_parsedData!.location != null) profileData['location'] = _parsedData!.location;
        if (_parsedData!.title != null) profileData['title'] = _parsedData!.title;
        if (_parsedData!.bio != null) profileData['bio'] = _parsedData!.bio;
        if (_uploadedResumeUrl != null) profileData['resume_url'] = _uploadedResumeUrl;

        if (profileData.isNotEmpty) {
          await SupabaseService.requiredClient
              .from('profiles')
              .update(profileData)
              .eq('id', currentProfile.id);
        }
      }

      // Add experiences
      if (_parsedData!.experiences.isNotEmpty) {
        for (int i = 0; i < _parsedData!.experiences.length; i++) {
          final exp = _parsedData!.experiences[i];
          await SupabaseService.requiredClient.from('experiences').insert({
            'company': exp.company,
            'position': exp.position,
            'description': exp.description,
            'start_date': exp.startDate?.toIso8601String().split('T')[0],
            'end_date': exp.endDate?.toIso8601String().split('T')[0],
            'is_current': exp.isCurrent,
            'order_index': i,
          });
        }
      }

      // Add social links
      if (_parsedData!.socialLinks.isNotEmpty) {
        final currentProfile = await profileRepo.getProfile();
        if (currentProfile != null) {
          int linkIndex = 0;
          for (final entry in _parsedData!.socialLinks.entries) {
            // Check if link already exists
            final existing = await SupabaseService.requiredClient
                .from('social_links')
                .select()
                .eq('profile_id', currentProfile.id)
                .eq('platform', entry.key)
                .maybeSingle();
            
            if (existing == null) {
              await SupabaseService.requiredClient.from('social_links').insert({
                'profile_id': currentProfile.id,
                'platform': entry.key,
                'url': entry.value,
                'order_index': linkIndex++,
              });
            } else {
              // Update existing link
              await SupabaseService.requiredClient
                  .from('social_links')
                  .update({'url': entry.value})
                  .eq('id', existing['id']);
            }
          }
        }
      }

      // Add projects/works
      if (_parsedData!.projects.isNotEmpty) {
        for (int i = 0; i < _parsedData!.projects.length; i++) {
          final project = _parsedData!.projects[i];
          
          // Extract technologies from project
          final technologies = project.technologies.isNotEmpty
              ? project.technologies
              : <String>[];
          
          // Use a placeholder image URL (user can update later)
          final placeholderImage = 'https://via.placeholder.com/800x600?text=${Uri.encodeComponent(project.name)}';
          
          await SupabaseService.requiredClient.from('works').insert({
            'title': project.name,
            'category': 'Portfolio Project',
            'description': project.description ?? 'Project extracted from resume',
            'image_url': placeholderImage,
            'project_url': project.url,
            'technologies': technologies,
            'tags': <String>[],
            'images': <String>[],
            'order_index': i,
            'is_active': true,
            'is_featured': false,
          });
        }
      }

      // Store skills in settings (or you can create a skills table later)
      if (_parsedData!.skills.isNotEmpty) {
        try {
          await SupabaseService.requiredClient.from('settings').upsert({
            'key': 'skills',
            'value': _parsedData!.skills,
            'description': 'Skills extracted from resume',
          });
        } catch (e) {
          debugPrint('Note: Could not save skills to settings: $e');
          // Skills table doesn't exist, that's okay
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume data applied successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e, stackTrace) {
      debugPrint('Error applying parsed data: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Error applying data: ${e.toString()}';
        _isUploading = false;
      });
    }
  }
}

