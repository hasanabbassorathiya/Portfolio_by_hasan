/// Admin services management screen
import 'package:flutter/material.dart';
import 'package:portfolio/core/repositories/service_repository.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/models/service/service_model.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/features/admin/widgets/service_form_dialog.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  final ServiceRepository _serviceRepository = ServiceRepository();
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      setState(() => _isLoading = true);
      final services = await _serviceRepository.getAllServices();
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteService(String id) async {
    try {
      await SupabaseService.requiredClient.from('services').delete().eq('id', id);
      _loadServices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting service: $e')));
      }
    }
  }

  void _confirmDelete(ServiceModel service) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Service'),
            content: Text(
              'Are you sure you want to delete "${service.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteService(service.id);
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
                'Manage Services',
                style: AppStyles.heading(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditServiceDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Service'),
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
          else if (_services.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.build_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  AppUtils().vSpace(size: 16),
                  Text(
                    'No services yet',
                    style: AppStyles.heading(fontSize: 24),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading:
                          service.iconUrl != null && service.iconUrl!.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  service.iconUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(Icons.build),
                                ),
                              )
                              : const Icon(Icons.build),
                      title: Text(service.title),
                      subtitle: Text(service.description ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(
                              service.isActive ? 'Active' : 'Inactive',
                            ),
                            backgroundColor:
                                service.isActive
                                    ? Colors.green.shade50
                                    : Colors.grey.shade200,
                          ),
                          AppUtils().hSpace(size: 8),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed:
                                () =>
                                    _showAddEditServiceDialog(service: service),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(service),
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

  void _showAddEditServiceDialog({ServiceModel? service}) {
    showDialog(
      context: context,
      builder: (context) => ServiceFormDialog(service: service),
    ).then((saved) {
      if (saved == true) {
        _loadServices();
      }
    });
  }
}
