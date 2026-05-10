/// Work form dialog for creating/editing works
import 'package:flutter/material.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/models/work/work_model.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';

class WorkFormDialog extends StatefulWidget {
  final WorkModel? work;

  const WorkFormDialog({super.key, this.work});

  @override
  State<WorkFormDialog> createState() => _WorkFormDialogState();
}

class _WorkFormDialogState extends State<WorkFormDialog> {

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + '_' + 
           (1000 + DateTime.now().microsecond).toString();
  }

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final _clientController = TextEditingController();
  final _yearController = TextEditingController();
  final _roleController = TextEditingController();
  final _challengeController = TextEditingController();
  final _solutionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _technologiesController = TextEditingController();
  final _imagesController = TextEditingController();
  final _playStoreUrlController = TextEditingController();
  final _appStoreUrlController = TextEditingController();
  final _appIconUrlController = TextEditingController();
  bool _isActive = true;
  bool _isFeatured = false;
  int _orderIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.work != null) {
      _titleController.text = widget.work!.title;
      _categoryController.text = widget.work!.category;
      _descriptionController.text = widget.work!.description;
      _imageUrlController.text = widget.work!.imageAsset;
      _projectUrlController.text = widget.work!.projectUrl ?? '';
      _clientController.text = widget.work!.client ?? '';
      _yearController.text = widget.work!.year ?? '';
      _roleController.text = widget.work!.role ?? '';
      _challengeController.text = widget.work!.challenge ?? '';
      _solutionController.text = widget.work!.solution ?? '';
      _tagsController.text = widget.work!.tags.join(', ');
      _technologiesController.text =
          widget.work!.technologies?.join(', ') ?? '';
      _imagesController.text = widget.work!.images?.join(', ') ?? '';
      _playStoreUrlController.text = widget.work!.playStoreUrl ?? '';
      _appStoreUrlController.text = widget.work!.appStoreUrl ?? '';
      _appIconUrlController.text = widget.work!.appIconUrl ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _projectUrlController.dispose();
    _clientController.dispose();
    _yearController.dispose();
    _roleController.dispose();
    _challengeController.dispose();
    _solutionController.dispose();
    _tagsController.dispose();
    _technologiesController.dispose();
    _imagesController.dispose();
    _playStoreUrlController.dispose();
    _appStoreUrlController.dispose();
    _appIconUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tags =
          _tagsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      final technologies =
          _technologiesController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      final images =
          _imagesController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      final data = {
        'title': _titleController.text.trim(),
        'category': _categoryController.text.trim(),
        'description': _descriptionController.text.trim(),
        'image_url': _imageUrlController.text.trim(),
        'project_url':
            _projectUrlController.text.trim().isEmpty
                ? null
                : _projectUrlController.text.trim(),
        'client':
            _clientController.text.trim().isEmpty
                ? null
                : _clientController.text.trim(),
        'year':
            _yearController.text.trim().isEmpty
                ? null
                : _yearController.text.trim(),
        'role':
            _roleController.text.trim().isEmpty
                ? null
                : _roleController.text.trim(),
        'challenge':
            _challengeController.text.trim().isEmpty
                ? null
                : _challengeController.text.trim(),
        'solution':
            _solutionController.text.trim().isEmpty
                ? null
                : _solutionController.text.trim(),
        'tags': tags.join(','),
        'technologies': technologies.isEmpty ? null : technologies.join(','),
        'images': images.isEmpty ? null : images.join(','),
        'play_store_url':
            _playStoreUrlController.text.trim().isEmpty
                ? null
                : _playStoreUrlController.text.trim(),
        'app_store_url':
            _appStoreUrlController.text.trim().isEmpty
                ? null
                : _appStoreUrlController.text.trim(),
        'app_icon_url':
            _appIconUrlController.text.trim().isEmpty
                ? null
                : _appIconUrlController.text.trim(),
        'is_active': _isActive ? 1 : 0,
        'is_featured': _isFeatured ? 1 : 0,
        'order_index': _orderIndex,
      };

      if (widget.work != null) {
        await SupabaseService.requiredClient
            .from('works')
            .update(data)
            .eq('id', widget.work!.id);
      } else {
        data['id'] = _generateId();
        await SupabaseService.requiredClient.from('works').insert(data);
      }

      if (mounted) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully saved'), backgroundColor: Colors.green));
        debugPrint('Successfully saved item');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 800),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(gradient: AppUtils().appGradient),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.work == null ? 'Add New Work' : 'Edit Work',
                      style: AppStyles.heading(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
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
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Category is required';
                          }
                          return null;
                        },
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Image URL is required';
                          }
                          return null;
                        },
                      ),
                      AppUtils().vSpace(size: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _clientController,
                              decoration: const InputDecoration(
                                labelText: 'Client',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          AppUtils().hSpace(size: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _yearController,
                              decoration: const InputDecoration(
                                labelText: 'Year',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _roleController,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _projectUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Project URL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags',
                          border: OutlineInputBorder(),
                          helperText: 'Comma-separated',
                        ),
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _technologiesController,
                        decoration: const InputDecoration(
                          labelText: 'Technologies',
                          border: OutlineInputBorder(),
                          helperText: 'Comma-separated',
                        ),
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _challengeController,
                        decoration: const InputDecoration(
                          labelText: 'Challenge',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _solutionController,
                        decoration: const InputDecoration(
                          labelText: 'Solution',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _imagesController,
                        decoration: const InputDecoration(
                          labelText: 'Additional Images',
                          border: OutlineInputBorder(),
                          helperText: 'Comma-separated URLs',
                        ),
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _appIconUrlController,
                        decoration: const InputDecoration(
                          labelText: 'App Icon URL',
                          border: OutlineInputBorder(),
                          helperText: 'Icon image URL for mobile apps',
                        ),
                      ),
                      AppUtils().vSpace(size: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _playStoreUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Play Store URL',
                                border: OutlineInputBorder(),
                                helperText: 'Google Play Store link',
                              ),
                            ),
                          ),
                          AppUtils().hSpace(size: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _appStoreUrlController,
                              decoration: const InputDecoration(
                                labelText: 'App Store URL',
                                border: OutlineInputBorder(),
                                helperText: 'Apple App Store link',
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppUtils().vSpace(size: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _orderIndex.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Order Index',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                _orderIndex = int.tryParse(value) ?? 0;
                              },
                            ),
                          ),
                          AppUtils().hSpace(size: 16),
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Active'),
                              value: _isActive,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value ?? true;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Featured'),
                              value: _isFeatured,
                              onChanged: (value) {
                                setState(() {
                                  _isFeatured = value ?? false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    AppUtils().hSpace(size: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
