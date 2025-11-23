/// Service form dialog for creating/editing services
import 'package:flutter/material.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/models/service/service_model.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/features/admin/widgets/image_upload_widget.dart';

class ServiceFormDialog extends StatefulWidget {
  final ServiceModel? service;

  const ServiceFormDialog({super.key, this.service});

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _orderIndexController = TextEditingController();
  String? _iconUrl;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _titleController.text = widget.service!.title;
      _descriptionController.text = widget.service!.description ?? '';
      _orderIndexController.text = widget.service!.orderIndex.toString();
      _iconUrl = widget.service!.iconUrl;
      _isActive = widget.service!.isActive;
    } else {
      _orderIndexController.text = '0';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _orderIndexController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'title': _titleController.text.trim(),
        'description':
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        'icon_url': _iconUrl,
        'order_index': int.tryParse(_orderIndexController.text) ?? 0,
        'is_active': _isActive,
      };

      if (widget.service != null) {
        await SupabaseService.client
            .from('services')
            .update(data)
            .eq('id', widget.service!.id);
      } else {
        await SupabaseService.client.from('services').insert(data);
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
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
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
                      widget.service == null ? 'Add Service' : 'Edit Service',
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
                      ImageUploadWidget(
                        initialImageUrl: _iconUrl,
                        bucket: 'services',
                        label: 'Service Icon',
                        onImageUploaded: (url) {
                          setState(() {
                            _iconUrl = url;
                          });
                        },
                      ),
                      AppUtils().vSpace(size: 24),
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
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                      ),
                      AppUtils().vSpace(size: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _orderIndexController,
                              decoration: const InputDecoration(
                                labelText: 'Order Index',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
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
