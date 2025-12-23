import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:portfolio/core/repositories/profile_repository.dart';
import 'package:portfolio/core/services/resume_parser_api_service.dart';
import 'package:portfolio/core/services/resume_parser_service.dart';
import 'package:portfolio/core/services/storage_service.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditableExperience {
  EditableExperience({
    required this.company,
    required this.position,
    this.description,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.enabled = true,
  });

  TextEditingController company;
  TextEditingController position;
  TextEditingController? description;
  TextEditingController? startDate;
  TextEditingController? endDate;
  bool isCurrent;
  bool enabled;
}

class EditableProject {
  EditableProject({
    required this.name,
    this.description,
    this.url,
    this.technologies = const [],
    this.enabled = true,
  });

  TextEditingController name;
  TextEditingController? description;
  TextEditingController? url;
  List<String> technologies;
  bool enabled;
}

class EditableSkill {
  EditableSkill({required this.value, this.enabled = true});
  TextEditingController value;
  bool enabled;
}

class EditableSocialLink {
  EditableSocialLink({
    required this.platform,
    required this.url,
    this.enabled = true,
  });

  TextEditingController platform;
  TextEditingController url;
  bool enabled;
}

class AdminResumeIntakeScreen extends StatefulWidget {
  const AdminResumeIntakeScreen({super.key});

  @override
  State<AdminResumeIntakeScreen> createState() =>
      _AdminResumeIntakeScreenState();
}

class _AdminResumeIntakeScreenState extends State<AdminResumeIntakeScreen> {
  bool _isParsing = false;
  bool _isApplying = false;
  String? _errorMessage;
  ParsedResumeData? _parsedData;
  String? _uploadedResumeUrl;

  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _resumeUrlController = TextEditingController();

  final List<EditableExperience> _experiences = [];
  final List<EditableProject> _projects = [];
  final List<EditableSkill> _skills = [];
  final List<EditableSocialLink> _socialLinks = [];

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _resumeUrlController.dispose();
    for (final exp in _experiences) {
      exp.company.dispose();
      exp.position.dispose();
      exp.description?.dispose();
      exp.startDate?.dispose();
      exp.endDate?.dispose();
    }
    for (final proj in _projects) {
      proj.name.dispose();
      proj.description?.dispose();
      proj.url?.dispose();
    }
    for (final skill in _skills) {
      skill.value.dispose();
    }
    for (final link in _socialLinks) {
      link.platform.dispose();
      link.url.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resume Intake',
                style: AppStyles.heading(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (_parsedData != null)
                    TextButton(
                      onPressed:
                          _isApplying
                              ? null
                              : () {
                                setState(() {
                                  _parsedData = null;
                                  _errorMessage = null;
                                  _experiences.clear();
                                  _projects.clear();
                                  _skills.clear();
                                  _socialLinks.clear();
                                });
                              },
                      child: const Text('Discard'),
                    ),
                  AppUtils().hSpace(size: 12),
                  ElevatedButton.icon(
                    onPressed:
                        _parsedData == null || _isApplying ? null : _applyAll,
                    icon:
                        _isApplying
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.save),
                    label: Text(_isApplying ? 'Applying...' : 'Apply All'),
                  ),
                ],
              ),
            ],
          ),
          AppUtils().vSpace(size: 16),
          if (_errorMessage != null) _buildErrorBanner(_errorMessage!),
          _parsedData == null ? _buildUploadCard() : _buildConfirmationView(),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          AppUtils().hSpace(size: 12),
          Expanded(
            child: Text(
              message,
              style: AppStyles.body(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
            color: AppColors.primaryColor.withOpacity(0.05),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.upload_file, size: 64, color: AppColors.primaryColor),
              AppUtils().vSpace(size: 16),
              Text(
                'Upload your resume (PDF)',
                style: AppStyles.heading(fontSize: 20),
              ),
              AppUtils().vSpace(size: 8),
              Text(
                'We will parse your resume, let you confirm the data, re-order items, and apply everything automatically.',
                textAlign: TextAlign.center,
                style: AppStyles.body(color: AppColors.textSecondary),
              ),
              AppUtils().vSpace(size: 16),
              ElevatedButton.icon(
                onPressed: _isParsing ? null : _pickAndParse,
                icon:
                    _isParsing
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.picture_as_pdf),
                label: Text(_isParsing ? 'Parsing...' : 'Select PDF Resume'),
              ),
            ],
          ),
        ),
        AppUtils().vSpace(size: 12),
        Text(
          'Parsed sections: profile info, experiences (with ordering), projects, skills, socials, resume URL.',
          textAlign: TextAlign.center,
          style: AppStyles.body(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildConfirmationView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Profile Info'),
        _buildProfileInfoCard(),
        AppUtils().vSpace(size: 16),
        _buildSectionTitle('Work Experience'),
        _buildExperienceList(),
        AppUtils().vSpace(size: 16),
        _buildSectionTitle('Projects / Works'),
        _buildProjectList(),
        AppUtils().vSpace(size: 16),
        _buildSectionTitle('Skills'),
        _buildSkillsList(),
        AppUtils().vSpace(size: 16),
        _buildSectionTitle('Social Links'),
        _buildSocialLinksList(),
        AppUtils().vSpace(size: 16),
        if (_uploadedResumeUrl != null)
          Text(
            'Uploaded resume: $_uploadedResumeUrl',
            style: AppStyles.body(color: AppColors.textSecondary),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppStyles.heading(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildProfileInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(_nameController, 'Full Name'),
            AppUtils().vSpace(size: 12),
            _buildTextField(_titleController, 'Title / Position'),
            AppUtils().vSpace(size: 12),
            _buildTextField(_bioController, 'Bio / Summary', maxLines: 3),
            AppUtils().vSpace(size: 12),
            _buildTextField(_emailController, 'Email'),
            AppUtils().vSpace(size: 12),
            _buildTextField(_phoneController, 'Phone'),
            AppUtils().vSpace(size: 12),
            _buildTextField(_locationController, 'Location'),
            AppUtils().vSpace(size: 12),
            _buildTextField(_resumeUrlController, 'Resume URL'),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildExperienceList() {
    if (_experiences.isEmpty) {
      return _buildEmptyState('No experiences parsed from resume.');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _experiences.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final item = _experiences.removeAt(oldIndex);
              _experiences.insert(newIndex, item);
            });
          },
          itemBuilder: (context, index) {
            final exp = _experiences[index];
            return Card(
              key: ValueKey('exp_$index'),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Experience ${index + 1}',
                          style: AppStyles.heading(fontSize: 14),
                        ),
                        Switch(
                          value: exp.enabled,
                          onChanged: (v) => setState(() => exp.enabled = v),
                        ),
                      ],
                    ),
                    _buildTextField(exp.position, 'Position'),
                    AppUtils().vSpace(size: 8),
                    _buildTextField(exp.company, 'Company'),
                    if (exp.description != null) ...[
                      AppUtils().vSpace(size: 8),
                      _buildTextField(
                        exp.description!,
                        'Description',
                        maxLines: 3,
                      ),
                    ],
                    AppUtils().vSpace(size: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            exp.startDate ?? TextEditingController(),
                            'Start Date (text)',
                          ),
                        ),
                        AppUtils().hSpace(size: 8),
                        Expanded(
                          child: _buildTextField(
                            exp.endDate ?? TextEditingController(),
                            'End Date (text)',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: exp.isCurrent,
                          onChanged:
                              (v) => setState(() => exp.isCurrent = v ?? false),
                        ),
                        const Text('Current role'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProjectList() {
    if (_projects.isEmpty) {
      return _buildEmptyState('No projects parsed from resume.');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _projects.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final item = _projects.removeAt(oldIndex);
              _projects.insert(newIndex, item);
            });
          },
          itemBuilder: (context, index) {
            final proj = _projects[index];
            return Card(
              key: ValueKey('proj_$index'),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Project ${index + 1}',
                          style: AppStyles.heading(fontSize: 14),
                        ),
                        Switch(
                          value: proj.enabled,
                          onChanged: (v) => setState(() => proj.enabled = v),
                        ),
                      ],
                    ),
                    _buildTextField(proj.name, 'Title'),
                    if (proj.description != null) ...[
                      AppUtils().vSpace(size: 8),
                      _buildTextField(
                        proj.description!,
                        'Description',
                        maxLines: 3,
                      ),
                    ],
                    AppUtils().vSpace(size: 8),
                    _buildTextField(
                      proj.url ??= TextEditingController(),
                      'Project URL',
                    ),
                    if (proj.technologies.isNotEmpty) ...[
                      AppUtils().vSpace(size: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            proj.technologies
                                .map(
                                  (t) => Chip(
                                    label: Text(t),
                                    backgroundColor: AppColors.primaryColor
                                        .withOpacity(0.1),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkillsList() {
    if (_skills.isEmpty) {
      return _buildEmptyState('No skills parsed from resume.');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _skills.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final item = _skills.removeAt(oldIndex);
              _skills.insert(newIndex, item);
            });
          },
          itemBuilder: (context, index) {
            final skill = _skills[index];
            return ListTile(
              key: ValueKey('skill_$index'),
              leading: Switch(
                value: skill.enabled,
                onChanged: (v) => setState(() => skill.enabled = v),
              ),
              title: TextField(
                controller: skill.value,
                decoration: const InputDecoration(
                  labelText: 'Skill',
                  border: OutlineInputBorder(),
                ),
              ),
              trailing: const Icon(Icons.drag_handle),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSocialLinksList() {
    if (_socialLinks.isEmpty) {
      return _buildEmptyState('No social links parsed from resume.');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _socialLinks.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final item = _socialLinks.removeAt(oldIndex);
              _socialLinks.insert(newIndex, item);
            });
          },
          itemBuilder: (context, index) {
            final link = _socialLinks[index];
            return Card(
              key: ValueKey('social_$index'),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Social ${index + 1}',
                          style: AppStyles.heading(fontSize: 14),
                        ),
                        Switch(
                          value: link.enabled,
                          onChanged: (v) => setState(() => link.enabled = v),
                        ),
                      ],
                    ),
                    _buildTextField(link.platform, 'Platform'),
                    AppUtils().vSpace(size: 8),
                    _buildTextField(link.url, 'URL'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, style: AppStyles.body(color: AppColors.textSecondary)),
    );
  }

  Future<void> _pickAndParse() async {
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
        setState(() => _isParsing = false);
        return;
      }

      final file = result.files.single;
      String uploadedFileUrl;

      if (kIsWeb && file.bytes != null) {
        final storage = SupabaseService.storage!;
        final fileName = 'resume_${DateTime.now().millisecondsSinceEpoch}.pdf';
        await storage
            .from('resumes')
            .uploadBinary(
              fileName,
              file.bytes!,
              fileOptions: const FileOptions(
                upsert: true,
                contentType: 'application/pdf',
              ),
            );
        uploadedFileUrl = storage.from('resumes').getPublicUrl(fileName);
      } else if (!kIsWeb && file.path != null) {
        uploadedFileUrl = await StorageService.uploadFile(
          file: File(file.path!),
          bucket: 'resumes',
          fileName: 'resume_${DateTime.now().millisecondsSinceEpoch}.pdf',
          contentType: 'application/pdf',
        );
      } else {
        throw Exception('Unable to process the selected file.');
      }

      _uploadedResumeUrl = uploadedFileUrl;

      final parsed = await ResumeParserApiService.parseResumeViaAPI(
        fileUrl: uploadedFileUrl,
        bucket: 'resumes',
        fileName: uploadedFileUrl.split('/').last,
      );

      _hydrateState(parsed);

      setState(() {
        _parsedData = parsed;
        _isParsing = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Resume Intake: error parsing resume $e');
      debugPrint('Resume Intake: $stackTrace');
      setState(() {
        _isParsing = false;
        _errorMessage = 'Failed to parse resume: $e';
      });
    }
  }

  void _hydrateState(ParsedResumeData parsed) {
    _nameController.text = parsed.name ?? '';
    _titleController.text = parsed.title ?? '';
    _bioController.text = parsed.bio ?? '';
    _emailController.text = parsed.email ?? '';
    _phoneController.text = parsed.phone ?? '';
    _locationController.text = parsed.location ?? '';
    if (_uploadedResumeUrl != null) {
      _resumeUrlController.text = _uploadedResumeUrl!;
    }

    _experiences
      ..clear()
      ..addAll(
        parsed.experiences.map(
          (e) => EditableExperience(
            company: TextEditingController(text: e.company),
            position: TextEditingController(text: e.position),
            description:
                e.description != null
                    ? TextEditingController(text: e.description)
                    : null,
            startDate:
                e.startDate != null
                    ? TextEditingController(
                      text: e.startDate!.toIso8601String(),
                    )
                    : TextEditingController(),
            endDate:
                e.endDate != null
                    ? TextEditingController(text: e.endDate!.toIso8601String())
                    : TextEditingController(),
            isCurrent: e.isCurrent,
          ),
        ),
      );

    _projects
      ..clear()
      ..addAll(
        parsed.projects.map(
          (p) => EditableProject(
            name: TextEditingController(text: p.name),
            description:
                p.description != null
                    ? TextEditingController(text: p.description)
                    : null,
            url: p.url != null ? TextEditingController(text: p.url) : null,
            technologies: p.technologies,
          ),
        ),
      );

    _skills
      ..clear()
      ..addAll(
        parsed.skills.map(
          (s) => EditableSkill(value: TextEditingController(text: s)),
        ),
      );

    _socialLinks
      ..clear()
      ..addAll(
        parsed.socialLinks.entries.map(
          (e) => EditableSocialLink(
            platform: TextEditingController(text: e.key),
            url: TextEditingController(text: e.value),
          ),
        ),
      );
  }

  Future<void> _applyAll() async {
    if (_parsedData == null) return;

    setState(() {
      _isApplying = true;
      _errorMessage = null;
    });

    try {
      final client = SupabaseService.requiredClient;
      final profileRepo = ProfileRepository();
      final profile = await profileRepo.getProfile();

      if (profile != null) {
        final profileData = <String, dynamic>{};
        if (_nameController.text.isNotEmpty) {
          profileData['name'] = _nameController.text.trim();
        }
        if (_titleController.text.isNotEmpty) {
          profileData['title'] = _titleController.text.trim();
        }
        if (_bioController.text.isNotEmpty) {
          profileData['bio'] = _bioController.text.trim();
        }
        if (_emailController.text.isNotEmpty) {
          profileData['email'] = _emailController.text.trim();
        }
        profileData['phone'] =
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim();
        profileData['location'] =
            _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim();
        profileData['resume_url'] =
            _resumeUrlController.text.trim().isEmpty
                ? null
                : _resumeUrlController.text.trim();

        if (profileData.isNotEmpty) {
          await client
              .from('profiles')
              .update(profileData)
              .eq('id', profile.id);
        }
      }

      // Replace experiences
      await client.from('experiences').delete();
      final enabledExperiences = _experiences.where((e) => e.enabled).toList();
      for (int i = 0; i < enabledExperiences.length; i++) {
        final exp = enabledExperiences[i];
        await client.from('experiences').insert({
          'company': exp.company.text.trim(),
          'position': exp.position.text.trim(),
          'description':
              exp.description?.text.trim().isEmpty ?? true
                  ? null
                  : exp.description!.text.trim(),
          'start_date':
              exp.startDate?.text.isEmpty ?? true
                  ? null
                  : exp.startDate!.text.trim(),
          'end_date':
              exp.endDate?.text.isEmpty ?? true
                  ? null
                  : exp.endDate!.text.trim(),
          'is_current': exp.isCurrent,
          'order_index': i,
        });
      }

      // Replace projects as works
      await client.from('works').delete();
      final enabledProjects = _projects.where((p) => p.enabled).toList();
      for (int i = 0; i < enabledProjects.length; i++) {
        final proj = enabledProjects[i];
        final placeholder =
            'https://via.placeholder.com/800x600?text=${Uri.encodeComponent(proj.name.text)}';
        await client.from('works').insert({
          'title': proj.name.text.trim(),
          'category': 'Portfolio Project',
          'description':
              proj.description?.text.trim().isEmpty ?? true
                  ? 'Project parsed from resume'
                  : proj.description!.text.trim(),
          'image_url': placeholder,
          'project_url':
              proj.url?.text.trim().isEmpty ?? true
                  ? null
                  : proj.url!.text.trim(),
          'technologies': proj.technologies,
          'tags': <String>[],
          'images': <String>[],
          'order_index': i,
          'is_active': true,
          'is_featured': false,
        });
      }

      // Replace social links
      await client.from('social_links').delete();
      final enabledSocials = _socialLinks.where((s) => s.enabled).toList();
      for (int i = 0; i < enabledSocials.length; i++) {
        final link = enabledSocials[i];
        await client.from('social_links').insert({
          'platform': link.platform.text.trim(),
          'url': link.url.text.trim(),
          'order_index': i,
        });
      }

      // Upsert skills to settings
      final enabledSkills =
          _skills
              .where((s) => s.enabled)
              .map((s) => s.value.text.trim())
              .where((s) => s.isNotEmpty)
              .toList();
      if (enabledSkills.isNotEmpty) {
        await client.from('settings').upsert({
          'key': 'skills',
          'value': enabledSkills,
          'description': 'Skills parsed from resume',
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume data applied successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Resume Intake: apply failed $e');
      debugPrint('Resume Intake: $stackTrace');
      setState(() {
        _errorMessage = 'Failed to apply resume data: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }
}
