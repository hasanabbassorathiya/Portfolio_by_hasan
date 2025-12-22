/// Testimonial form dialog for creating/editing testimonials
import 'package:flutter/material.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/core/repositories/testimonial_repository.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/features/admin/widgets/image_upload_widget.dart';

class TestimonialFormDialog extends StatefulWidget {
  final TestimonialModel? testimonial;

  const TestimonialFormDialog({super.key, this.testimonial});

  @override
  State<TestimonialFormDialog> createState() => _TestimonialFormDialogState();
}

class _TestimonialFormDialogState extends State<TestimonialFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientRoleController = TextEditingController();
  final _clientCompanyController = TextEditingController();
  final _quoteController = TextEditingController();
  final _orderIndexController = TextEditingController();
  String? _clientImageUrl;
  int? _rating;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.testimonial != null) {
      _clientNameController.text = widget.testimonial!.clientName;
      _clientRoleController.text = widget.testimonial!.clientRole ?? '';
      _clientCompanyController.text = widget.testimonial!.clientCompany ?? '';
      _quoteController.text = widget.testimonial!.quote;
      _orderIndexController.text = widget.testimonial!.orderIndex.toString();
      _clientImageUrl = widget.testimonial!.clientImageUrl;
      _rating = widget.testimonial!.rating;
      _isActive = widget.testimonial!.isActive;
    } else {
      _orderIndexController.text = '0';
      _rating = 5;
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientRoleController.dispose();
    _clientCompanyController.dispose();
    _quoteController.dispose();
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
        'client_name': _clientNameController.text.trim(),
        'client_role':
            _clientRoleController.text.trim().isEmpty
                ? null
                : _clientRoleController.text.trim(),
        'client_company':
            _clientCompanyController.text.trim().isEmpty
                ? null
                : _clientCompanyController.text.trim(),
        'client_image_url': _clientImageUrl,
        'quote': _quoteController.text.trim(),
        'rating': _rating,
        'order_index': int.tryParse(_orderIndexController.text) ?? 0,
        'is_active': _isActive,
      };

      if (widget.testimonial != null) {
        await SupabaseService.requiredClient
            .from('testimonials')
            .update(data)
            .eq('id', widget.testimonial!.id);
      } else {
        await SupabaseService.requiredClient.from('testimonials').insert(data);
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
                      widget.testimonial == null
                          ? 'Add Testimonial'
                          : 'Edit Testimonial',
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
                        initialImageUrl: _clientImageUrl,
                        bucket: 'testimonials',
                        label: 'Client Image',
                        onImageUploaded: (url) {
                          setState(() {
                            _clientImageUrl = url;
                          });
                        },
                      ),
                      AppUtils().vSpace(size: 24),
                      TextFormField(
                        controller: _clientNameController,
                        decoration: const InputDecoration(
                          labelText: 'Client Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Client name is required';
                          }
                          return null;
                        },
                      ),
                      AppUtils().vSpace(size: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _clientRoleController,
                              decoration: const InputDecoration(
                                labelText: 'Client Role',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          AppUtils().hSpace(size: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _clientCompanyController,
                              decoration: const InputDecoration(
                                labelText: 'Company',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _quoteController,
                        decoration: const InputDecoration(
                          labelText: 'Quote *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Quote is required';
                          }
                          return null;
                        },
                      ),
                      AppUtils().vSpace(size: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rating', style: AppStyles.body()),
                                AppUtils().vSpace(size: 8),
                                Row(
                                  children: List.generate(5, (index) {
                                    return IconButton(
                                      icon: Icon(
                                        index < (_rating ?? 0)
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _rating = index + 1;
                                        });
                                      },
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          AppUtils().hSpace(size: 16),
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
                        ],
                      ),
                      AppUtils().vSpace(size: 16),
                      CheckboxListTile(
                        title: const Text('Active'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value ?? true;
                          });
                        },
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
