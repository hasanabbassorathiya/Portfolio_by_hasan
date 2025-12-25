/// Admin profile management screen
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:portfolio/core/repositories/profile_repository.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/models/profile/profile_model.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/widgets/file_upload_widget.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final ProfileRepository _profileRepository = ProfileRepository();
  final _formKey = GlobalKey<FormState>();
  ProfileModel? _profile;
  bool _isLoading = true;
  bool _isSaving = false;

  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _resumeUrlController = TextEditingController();
  final _quoteController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _resumeUrlController.dispose();
    _quoteController.dispose();
    _yearsOfExperienceController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() => _isLoading = true);
      final profile = await _profileRepository.getProfile();
      if (profile != null) {
        setState(() {
          _profile = profile;
          _nameController.text = profile.name;
          _titleController.text = profile.title;
          _bioController.text = profile.bio ?? '';
          _emailController.text = profile.email;
          _phoneController.text = profile.phone ?? '';
          _locationController.text = profile.location ?? '';
          _resumeUrlController.text = profile.resumeUrl ?? '';
          _quoteController.text = profile.quote ?? '';
          _yearsOfExperienceController.text = profile.yearsOfExperience?.toString() ?? '';
          _avatarUrl = profile.avatarUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final profileData = {
        'name': _nameController.text.trim(),
        'title': _titleController.text.trim(),
        'bio':
            _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
        'email': _emailController.text.trim(),
        'phone':
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        'location':
            _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
        'avatar_url': _avatarUrl,
        'resume_url':
            _resumeUrlController.text.trim().isEmpty
                ? null
                : _resumeUrlController.text.trim(),
        'quote':
            _quoteController.text.trim().isEmpty
                ? null
                : _quoteController.text.trim(),
        'years_of_experience':
            _yearsOfExperienceController.text.trim().isEmpty
                ? null
                : int.tryParse(_yearsOfExperienceController.text.trim()),
      };

      if (_profile != null) {
        await SupabaseService.requiredClient
            .from('profiles')
            .update(profileData)
            .eq('id', _profile!.id);
      } else {
        await SupabaseService.requiredClient
            .from('profiles')
            .insert(profileData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadProfile();
        // Show a message that the image will update on other pages
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profile image updated! Navigate to Home/About pages to see the change.',
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Manage Profile',
                            style: AppStyles.heading(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveProfile,
                            icon:
                                _isSaving
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.save),
                            label: Text(
                              _isSaving ? 'Saving...' : 'Save Profile',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      AppUtils().vSpace(size: 32),
                      FileUploadWidget(
                        initialUrl: _avatarUrl,
                        bucket: 'avatars',
                        label: 'Profile Avatar',
                        fileType: FileType.image,
                        allowUrlInput: true,
                        onFileUploaded: (url) {
                          setState(() {
                            _avatarUrl = url;
                          });
                        },
                      ),
                      AppUtils().vSpace(size: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title/Position *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                      ),
                      AppUtils().vSpace(size: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                          AppUtils().hSpace(size: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _resumeUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Resume URL',
                          border: OutlineInputBorder(),
                          helperText: 'Link to your resume/CV',
                        ),
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _quoteController,
                        decoration: const InputDecoration(
                          labelText: 'Quote',
                          border: OutlineInputBorder(),
                          helperText: 'Personal quote displayed in the about section',
                        ),
                        maxLines: 3,
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _yearsOfExperienceController,
                        decoration: const InputDecoration(
                          labelText: 'Years of Experience',
                          border: OutlineInputBorder(),
                          helperText: 'Number of years of experience (e.g., 6)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
