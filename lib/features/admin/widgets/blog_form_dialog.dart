/// Blog form dialog for creating/editing blogs
import 'package:flutter/material.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/models/blog/blog_model.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';

class BlogFormDialog extends StatefulWidget {
  final BlogModel? blog;

  const BlogFormDialog({super.key, this.blog});

  @override
  State<BlogFormDialog> createState() => _BlogFormDialogState();
}

class _BlogFormDialogState extends State<BlogFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _contentController = TextEditingController();
  final _excerptController = TextEditingController();
  final _authorController = TextEditingController();
  final _readTimeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isPublished = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.blog != null) {
      _titleController.text = widget.blog!.title;
      _slugController.text = widget.blog!.title.toLowerCase().replaceAll(
        ' ',
        '-',
      );
      _contentController.text = widget.blog!.content;
      _authorController.text = widget.blog!.author;
      _readTimeController.text = widget.blog!.readTime ?? '';
      _categoryController.text = widget.blog!.category ?? '';
      _imageUrlController.text = widget.blog!.imageAsset;
      _tagsController.text = widget.blog!.tags.join(', ');
    } else {
      _authorController.text = 'Hasan Abbas Sorathiya';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _contentController.dispose();
    _excerptController.dispose();
    _authorController.dispose();
    _readTimeController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  String _generateSlug(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final slug =
          _slugController.text.trim().isEmpty
              ? _generateSlug(_titleController.text)
              : _slugController.text.trim();

      final tags =
          _tagsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      final data = {
        'title': _titleController.text.trim(),
        'slug': slug,
        'content': _contentController.text.trim(),
        'excerpt': _excerptController.text.trim(),
        'author': _authorController.text.trim(),
        'read_time':
            _readTimeController.text.trim().isEmpty
                ? null
                : _readTimeController.text.trim(),
        'category':
            _categoryController.text.trim().isEmpty
                ? null
                : _categoryController.text.trim(),
        'image_url': _imageUrlController.text.trim(),
        'tags': tags,
        'is_published': _isPublished,
        if (_isPublished) 'published_at': DateTime.now().toIso8601String(),
      };

      if (widget.blog != null) {
        await SupabaseService.client
            .from('blogs')
            .update(data)
            .eq('id', widget.blog!.id);
      } else {
        await SupabaseService.client.from('blogs').insert(data);
      }

      if (mounted) {
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
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(gradient: AppUtils().appGradient),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.blog == null ? 'Add New Blog' : 'Edit Blog',
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
              // Form content
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
                        onChanged: (value) {
                          if (_slugController.text.isEmpty ||
                              widget.blog == null) {
                            setState(() {
                              _slugController.text = _generateSlug(value);
                            });
                          }
                        },
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _slugController,
                        decoration: const InputDecoration(
                          labelText: 'Slug',
                          border: OutlineInputBorder(),
                          helperText: 'Auto-generated from title if empty',
                        ),
                      ),
                      AppUtils().vSpace(size: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _authorController,
                              decoration: const InputDecoration(
                                labelText: 'Author *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Author is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          AppUtils().hSpace(size: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _readTimeController,
                              decoration: const InputDecoration(
                                labelText: 'Read Time',
                                border: OutlineInputBorder(),
                                helperText: 'e.g., 5 min read',
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
                              controller: _categoryController,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          AppUtils().hSpace(size: 16),
                          Expanded(
                            child: TextFormField(
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
                          ),
                        ],
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags',
                          border: OutlineInputBorder(),
                          helperText: 'Comma-separated tags',
                        ),
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _excerptController,
                        decoration: const InputDecoration(
                          labelText: 'Excerpt',
                          border: OutlineInputBorder(),
                          helperText: 'Short summary',
                        ),
                        maxLines: 3,
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Content *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 10,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Content is required';
                          }
                          return null;
                        },
                      ),
                      AppUtils().vSpace(size: 16),
                      CheckboxListTile(
                        title: const Text('Publish immediately'),
                        value: _isPublished,
                        onChanged: (value) {
                          setState(() {
                            _isPublished = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Footer buttons
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
