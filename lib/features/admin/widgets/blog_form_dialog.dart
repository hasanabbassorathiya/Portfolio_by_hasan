/// Blog form dialog for creating/editing blogs
import 'package:flutter/foundation.dart';
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

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + '_' + 
           (1000 + DateTime.now().microsecond).toString();
  }

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _excerptController = TextEditingController();
  final _authorController = TextEditingController();
  final _readTimeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _tagsController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;
  bool _isHtmlMode = false;
  String _blogStatus = 'draft'; // 'draft', 'private', 'published'
  DateTime? _scheduledPublishDate;
  TimeOfDay? _scheduledPublishTime;

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

  /// Check if a slug already exists in the database
  Future<bool> _slugExists(String slug, {String? excludeId}) async {
    try {
      var query = SupabaseService.requiredClient
          .from('blogs')
          .select('id')
          .eq('slug', slug);
      
      // If editing, exclude the current blog's ID
      if (excludeId != null) {
        query = query.not('id', 'eq', excludeId);
      }
      
      final response = await query.limit(1);
      return (response as List).isNotEmpty;
    } catch (e) {
      debugPrint('Error checking slug: $e');
      // If check fails, assume it doesn't exist to allow save attempt
      return false;
    }
  }

  /// Generate a unique slug by appending a number if needed
  Future<String> _ensureUniqueSlug(String baseSlug, {String? excludeId}) async {
    String slug = baseSlug;
    int counter = 1;
    
    // Check if slug exists, and if so, append a number
    while (await _slugExists(slug, excludeId: excludeId)) {
      slug = '$baseSlug-$counter';
      counter++;
      
      // Safety limit to prevent infinite loop
      if (counter > 1000) {
        // If we hit 1000, use timestamp as fallback
        slug = '$baseSlug-${DateTime.now().millisecondsSinceEpoch}';
        break;
      }
    }
    
    return slug;
  }

  /// Build data map for blog save/update
  Map<String, dynamic> _buildDataMap(
    String slugValue, {
    required bool isPublished,
    DateTime? publishedAt,
  }) {
    final tags =
        _tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    // Build scheduled publish date if status is published but date is in future
    DateTime? scheduledPublishAt;
    if (_blogStatus == 'published' && 
        _scheduledPublishDate != null && 
        _scheduledPublishDate!.isAfter(DateTime.now())) {
      scheduledPublishAt = DateTime(
        _scheduledPublishDate!.year,
        _scheduledPublishDate!.month,
        _scheduledPublishDate!.day,
        _scheduledPublishTime?.hour ?? DateTime.now().hour,
        _scheduledPublishTime?.minute ?? DateTime.now().minute,
      );
    }

    return {
      'title': _titleController.text.trim(),
      'slug': slugValue,
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
      'status': _blogStatus,
      'is_published': isPublished,
      if (publishedAt != null) 'published_at': publishedAt.toIso8601String(),
      if (scheduledPublishAt != null) 'scheduled_publish_at': scheduledPublishAt.toIso8601String(),
    };
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if user is authenticated
      final session = SupabaseService.auth?.currentSession;
      if (session == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You must be logged in to create blogs. Please log in again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      debugPrint('Blog Save: User authenticated - ${session.user.email}');
      debugPrint('Blog Save: User ID - ${session.user.id}');

      // Get content from editor
      final content = _contentController.text.trim();
      
      if (content.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Content is required')),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      // Generate or use provided slug, then ensure it's unique
      String baseSlug = _slugController.text.trim().isEmpty
          ? _generateSlug(_titleController.text)
          : _slugController.text.trim();
      
      // Ensure slug is unique (unless editing the same blog)
      final slug = await _ensureUniqueSlug(
        baseSlug,
        excludeId: widget.blog?.id,
      );
      
      // Update slug field if it was auto-generated
      if (slug != baseSlug && _slugController.text.trim().isEmpty) {
        _slugController.text = slug;
      }
      
      debugPrint('Blog Save: Using slug - $slug');

      // Determine publish status based on blog status
      final isPublished = _blogStatus == 'published';
      final publishedAt = isPublished 
          ? (_scheduledPublishDate != null 
              ? DateTime(
                  _scheduledPublishDate!.year,
                  _scheduledPublishDate!.month,
                  _scheduledPublishDate!.day,
                  _scheduledPublishTime?.hour ?? DateTime.now().hour,
                  _scheduledPublishTime?.minute ?? DateTime.now().minute,
                )
              : DateTime.now())
          : null;

      final data = _buildDataMap(slug, isPublished: isPublished, publishedAt: publishedAt);

      debugPrint('Blog Save: Attempting to ${widget.blog == null ? "insert" : "update"} blog');
      debugPrint('Blog Save: Status - $_blogStatus, Published - $isPublished');
      debugPrint('Blog Save: Data keys - ${data.keys.join(", ")}');
      debugPrint('Blog Save: Content length - ${content.length}');
      debugPrint('Blog Save: Content preview - ${content.substring(0, content.length > 100 ? 100 : content.length)}...');

      if (widget.blog != null) {
        await SupabaseService.requiredClient
            .from('blogs')
            .update(data)
            .eq('id', widget.blog!.id);
        debugPrint('Blog Save: Update successful');
      } else {
        data['id'] = _generateId();
        await SupabaseService.requiredClient.from('blogs').insert(data);
        debugPrint('Blog Save: Insert successful');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.blog == null ? 'Blog created successfully!' : 'Blog updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully saved'), backgroundColor: Colors.green));
        debugPrint('Successfully saved item');
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      debugPrint('Blog Save Error: $e');
      debugPrint('Blog Save StackTrace: $stackTrace');
      
      String errorMessage = 'Failed to save blog';
      
      // Parse error message for better user feedback
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('row-level security') || errorString.contains('rls')) {
        errorMessage = 'Permission denied. Please check:\n'
            '1. You are logged in\n'
            '2. RLS policies are configured correctly\n'
            '3. Try logging out and back in';
      } else if (errorString.contains('duplicate') || errorString.contains('unique')) {
        // This should rarely happen now since we auto-generate unique slugs
        // But if it does, try once more with a timestamp
        errorMessage = 'Slug conflict detected. Retrying with unique slug...';
        debugPrint('Blog Save: Duplicate slug error, this should be rare now');
        
        // Try one more time with timestamp-based slug
        try {
          final timestampSlug = '${_generateSlug(_titleController.text)}-${DateTime.now().millisecondsSinceEpoch}';
          final isPublished = _blogStatus == 'published';
          final publishedAt = isPublished ? DateTime.now() : null;
          final retryData = _buildDataMap(timestampSlug, isPublished: isPublished, publishedAt: publishedAt);
          
          if (widget.blog != null) {
            await SupabaseService.requiredClient
                .from('blogs')
                .update(retryData)
                .eq('id', widget.blog!.id);
          } else {
            await SupabaseService.requiredClient.from('blogs').insert(retryData);
          }
          
          // Success on retry
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.blog == null ? 'Blog created successfully!' : 'Blog updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully saved'), backgroundColor: Colors.green));
        debugPrint('Successfully saved item');
        Navigator.pop(context, true);
            return;
          }
        } catch (retryError) {
          errorMessage = 'Failed to save blog. Please try changing the title.';
          debugPrint('Blog Save: Retry also failed: $retryError');
        }
      } else if (errorString.contains('null') || errorString.contains('required')) {
        errorMessage = 'Please fill in all required fields.';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
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
                                labelText: 'Image URL',
                                border: OutlineInputBorder(),
                              ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Content *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                'Plain Text',
                                style: TextStyle(fontSize: 12),
                              ),
                              Switch(
                                value: _isHtmlMode,
                                onChanged: (value) {
                                  setState(() {
                                    _isHtmlMode = value;
                                  });
                                },
                              ),
                              const Text(
                                'HTML Mode',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      AppUtils().vSpace(size: 8),
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: _isHtmlMode
                              ? 'HTML Content (supports HTML tags)'
                              : 'Content (supports markdown)',
                          border: const OutlineInputBorder(),
                          hintText: _isHtmlMode
                              ? '<p>Enter your HTML content here...</p>'
                              : 'Enter your content here. Use markdown or switch to HTML mode for rich formatting.',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 15,
                        minLines: 10,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Content is required';
                          }
                          return null;
                        },
                      ),
                      AppUtils().vSpace(size: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isHtmlMode
                                    ? 'HTML Mode: Write HTML directly (e.g., <p>Text</p>, <h1>Heading</h1>, <strong>Bold</strong>)'
                                    : 'Plain Text Mode: Write markdown or plain text. Switch to HTML mode for advanced formatting.',
                                style: AppStyles.body(
                                  fontSize: 12,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppUtils().vSpace(size: 16),
                      // Blog Status Selection
                      DropdownButtonFormField<String>(
                        value: _blogStatus,
                        decoration: const InputDecoration(
                          labelText: 'Blog Status *',
                          border: OutlineInputBorder(),
                          helperText: 'Choose how this blog should be published',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'draft',
                            child: Text('Draft (Save for later)'),
                          ),
                          DropdownMenuItem(
                            value: 'private',
                            child: Text('Private (Only you can see)'),
                          ),
                          DropdownMenuItem(
                            value: 'published',
                            child: Text('Published (Public)'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _blogStatus = value;
                              // Clear scheduled date if switching to draft/private
                              if (value != 'published') {
                                _scheduledPublishDate = null;
                                _scheduledPublishTime = null;
                              }
                            });
                          }
                        },
                      ),
                      // Scheduling options (only show if status is published)
                      if (_blogStatus == 'published') ...[
                        AppUtils().vSpace(size: 16),
                        CheckboxListTile(
                          title: const Text('Schedule publication'),
                          subtitle: const Text('Publish at a specific date and time'),
                          value: _scheduledPublishDate != null,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _scheduledPublishDate = DateTime.now();
                                _scheduledPublishTime = TimeOfDay.now();
                              } else {
                                _scheduledPublishDate = null;
                                _scheduledPublishTime = null;
                              }
                            });
                          },
                        ),
                        if (_scheduledPublishDate != null) ...[
                          AppUtils().vSpace(size: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _scheduledPublishDate ?? DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        _scheduledPublishDate = date;
                                      });
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Publish Date',
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    child: Text(
                                      _scheduledPublishDate != null
                                          ? '${_scheduledPublishDate!.day}/${_scheduledPublishDate!.month}/${_scheduledPublishDate!.year}'
                                          : 'Select date',
                                    ),
                                  ),
                                ),
                              ),
                              AppUtils().hSpace(size: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: _scheduledPublishTime ?? TimeOfDay.now(),
                                    );
                                    if (time != null) {
                                      setState(() {
                                        _scheduledPublishTime = time;
                                      });
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Publish Time',
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.access_time),
                                    ),
                                    child: Text(
                                      _scheduledPublishTime != null
                                          ? _scheduledPublishTime!.format(context)
                                          : 'Select time',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
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
