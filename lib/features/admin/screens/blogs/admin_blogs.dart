/// Admin blogs management screen
import 'package:flutter/material.dart';
import 'package:portfolio/core/repositories/blog_repository.dart';
import 'package:portfolio/models/blog/blog_model.dart' hide BlogRepository;
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/features/admin/widgets/blog_form_dialog.dart';

class AdminBlogsScreen extends StatefulWidget {
  const AdminBlogsScreen({super.key});

  @override
  State<AdminBlogsScreen> createState() => _AdminBlogsScreenState();
}

class _AdminBlogsScreenState extends State<AdminBlogsScreen> {
  final BlogRepository _blogRepository = BlogRepository();
  List<BlogModel> _blogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted'), backgroundColor: Colors.green));
      debugPrint('Successfully deleted item');
  }

  Future<void> _loadBlogs() async {
    try {
      setState(() => _isLoading = true);
      // Get all blogs including unpublished
      final response = await _blogRepository.client
          .from('blogs')
          .select()
          .order('created_at', ascending: false);
      final blogs =
          (response as List)
              .map((json) => BlogModel.fromMap(json as Map<String, dynamic>))
              .toList();
      setState(() {
        _blogs = blogs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading blogs: $e')));
      }
    }
  }

  Future<void> _deleteBlog(String id) async {
    try {
      await _blogRepository.client.from('blogs').delete().eq('id', id);
      _loadBlogs();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted'), backgroundColor: Colors.green));
      debugPrint('Successfully deleted item');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blog deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting blog: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Blogs',
                style: AppStyles.heading(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditBlogDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add New Blog'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          AppUtils().vSpace(size: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_blogs.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  AppUtils().vSpace(size: 16),
                  Text('No blogs yet', style: AppStyles.heading(fontSize: 24)),
                  AppUtils().vSpace(size: 8),
                  Text(
                    'Click "Add New Blog" to create your first blog post',
                    style: AppStyles.body(),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _blogs.length,
                itemBuilder: (context, index) {
                  final blog = _blogs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading:
                          blog.imageAsset.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  blog.imageAsset,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(Icons.image),
                                ),
                              )
                              : const Icon(Icons.article),
                      title: Text(blog.title),
                      subtitle: Text('${blog.date} • ${blog.author}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showAddEditBlogDialog(blog: blog),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(blog),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BlogModel blog) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Blog'),
            content: Text('Are you sure you want to delete "${blog.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteBlog(blog.id);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showAddEditBlogDialog({BlogModel? blog}) {
    showDialog(
      context: context,
      builder: (context) => BlogFormDialog(blog: blog),
    ).then((saved) {
      if (saved == true) {
        _loadBlogs();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted'), backgroundColor: Colors.green));
      debugPrint('Successfully deleted item');
      }
    });
  }
}
