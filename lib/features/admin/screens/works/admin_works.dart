/// Admin works management screen
import 'package:flutter/material.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/models/work/work_model.dart' hide WorkRepository;
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/features/admin/widgets/work_form_dialog.dart';

class AdminWorksScreen extends StatefulWidget {
  const AdminWorksScreen({super.key});

  @override
  State<AdminWorksScreen> createState() => _AdminWorksScreenState();
}

class _AdminWorksScreenState extends State<AdminWorksScreen> {
  List<WorkModel> _works = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorks();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted'), backgroundColor: Colors.green));
      debugPrint('Successfully deleted item');
  }

  Future<void> _loadWorks() async {
    try {
      setState(() => _isLoading = true);
      final response = await SupabaseService.requiredClient
          .from('works')
          .select()
          .order('order_index', ascending: true);
      final works =
          (response as List)
              .map((json) => WorkModel.fromMap(json as Map<String, dynamic>))
              .toList();
      setState(() {
        _works = works;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteWork(String id) async {
    try {
      await SupabaseService.requiredClient.from('works').delete().eq('id', id);
      _loadWorks();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted'), backgroundColor: Colors.green));
      debugPrint('Successfully deleted item');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Work deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting work: $e')));
      }
    }
  }

  void _confirmDelete(WorkModel work) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Work'),
            content: Text('Are you sure you want to delete "${work.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteWork(work.id);
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

  void _showAddEditWorkDialog({WorkModel? work}) {
    showDialog(
      context: context,
      builder: (context) => WorkFormDialog(work: work),
    ).then((saved) {
      if (saved == true) {
        _loadWorks();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted'), backgroundColor: Colors.green));
      debugPrint('Successfully deleted item');
      }
    });
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
                'Manage Works',
                style: AppStyles.heading(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditWorkDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add New Work'),
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
          else if (_works.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  AppUtils().vSpace(size: 16),
                  Text('No works yet', style: AppStyles.heading(fontSize: 24)),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _works.length,
                itemBuilder: (context, index) {
                  final work = _works[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading:
                          work.imageAsset.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  work.imageAsset,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(Icons.image),
                                ),
                              )
                              : const Icon(Icons.work),
                      title: Text(work.title),
                      subtitle: Text(
                        '${work.category} • ${work.client ?? "N/A"}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showAddEditWorkDialog(work: work),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(work),
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
}
