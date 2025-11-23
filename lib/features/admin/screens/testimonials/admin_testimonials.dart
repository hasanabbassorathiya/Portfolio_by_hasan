/// Admin testimonials management screen
import 'package:flutter/material.dart';
import 'package:portfolio/core/repositories/testimonial_repository.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/features/admin/widgets/testimonial_form_dialog.dart';

class AdminTestimonialsScreen extends StatefulWidget {
  const AdminTestimonialsScreen({super.key});

  @override
  State<AdminTestimonialsScreen> createState() =>
      _AdminTestimonialsScreenState();
}

class _AdminTestimonialsScreenState extends State<AdminTestimonialsScreen> {
  List<TestimonialModel> _testimonials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTestimonials();
  }

  Future<void> _loadTestimonials() async {
    try {
      setState(() => _isLoading = true);
      // Get all testimonials (not just active)
      final response = await SupabaseService.client
          .from('testimonials')
          .select()
          .order('order_index', ascending: true);
      final testimonials =
          (response as List)
              .map(
                (json) =>
                    TestimonialModel.fromMap(json as Map<String, dynamic>),
              )
              .toList();
      setState(() {
        _testimonials = testimonials;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTestimonial(String id) async {
    try {
      await SupabaseService.client.from('testimonials').delete().eq('id', id);
      _loadTestimonials();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Testimonial deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting testimonial: $e')),
        );
      }
    }
  }

  void _confirmDelete(TestimonialModel testimonial) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Testimonial'),
            content: Text(
              'Are you sure you want to delete testimonial from "${testimonial.clientName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteTestimonial(testimonial.id);
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
                'Manage Testimonials',
                style: AppStyles.heading(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditTestimonialDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Testimonial'),
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
          else if (_testimonials.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.format_quote_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  AppUtils().vSpace(size: 16),
                  Text(
                    'No testimonials yet',
                    style: AppStyles.heading(fontSize: 24),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _testimonials.length,
                itemBuilder: (context, index) {
                  final testimonial = _testimonials[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading:
                          testimonial.clientImageUrl != null &&
                                  testimonial.clientImageUrl!.isNotEmpty
                              ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                  testimonial.clientImageUrl!,
                                ),
                                onBackgroundImageError: (_, __) {},
                              )
                              : CircleAvatar(
                                child: Text(
                                  testimonial.clientName[0].toUpperCase(),
                                ),
                              ),
                      title: Text(testimonial.clientName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (testimonial.clientRole != null ||
                              testimonial.clientCompany != null)
                            Text(
                              '${testimonial.clientRole ?? ''}${testimonial.clientRole != null && testimonial.clientCompany != null ? ' at ' : ''}${testimonial.clientCompany ?? ''}',
                            ),
                          AppUtils().vSpace(size: 4),
                          Text(
                            testimonial.quote,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (testimonial.rating != null)
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < testimonial.rating!
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          AppUtils().hSpace(size: 8),
                          Chip(
                            label: Text(
                              testimonial.isActive ? 'Active' : 'Inactive',
                            ),
                            backgroundColor:
                                testimonial.isActive
                                    ? Colors.green.shade50
                                    : Colors.grey.shade200,
                          ),
                          AppUtils().hSpace(size: 8),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed:
                                () => _showAddEditTestimonialDialog(
                                  testimonial: testimonial,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(testimonial),
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

  void _showAddEditTestimonialDialog({TestimonialModel? testimonial}) {
    showDialog(
      context: context,
      builder: (context) => TestimonialFormDialog(testimonial: testimonial),
    ).then((saved) {
      if (saved == true) {
        _loadTestimonials();
      }
    });
  }
}
