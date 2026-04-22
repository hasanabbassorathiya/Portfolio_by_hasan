/// Admin experiences management screen
import 'package:flutter/material.dart';
import 'package:portfolio/core/repositories/experience_repository.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/features/admin/widgets/experience_form_dialog.dart';

class AdminExperiencesScreen extends StatefulWidget {
  const AdminExperiencesScreen({super.key});

  @override
  State<AdminExperiencesScreen> createState() => _AdminExperiencesScreenState();
}

class _AdminExperiencesScreenState extends State<AdminExperiencesScreen> {
  final ExperienceRepository _experienceRepository = ExperienceRepository();
  List<ExperienceModel> _experiences = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExperiences();
  }

  Future<void> _loadExperiences() async {
    try {
      setState(() => _isLoading = true);
      final experiences = await _experienceRepository.getAllExperiences();
      setState(() {
        _experiences = experiences;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteExperience(String id) async {
    try {
      await SupabaseService.requiredClient.from('experiences').delete().eq('id', id);
      _loadExperiences();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted'), backgroundColor: Colors.green));
      debugPrint('Successfully deleted item');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Experience deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting experience: $e')),
        );
      }
    }
  }

  void _confirmDelete(ExperienceModel experience) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Experience'),
            content: Text(
              'Are you sure you want to delete "${experience.position} at ${experience.company}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteExperience(experience.id);
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
                'Manage Experiences',
                style: AppStyles.heading(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditExperienceDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Experience'),
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
          else if (_experiences.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  AppUtils().vSpace(size: 16),
                  Text(
                    'No experiences yet',
                    style: AppStyles.heading(fontSize: 24),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _experiences.length,
                itemBuilder: (context, index) {
                  final experience = _experiences[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: const Icon(Icons.business),
                      title: Text(experience.position),
                      subtitle: Text(
                        '${experience.company} • ${experience.startDate.year} - ${experience.isCurrent ? 'Present' : experience.endDate?.year ?? 'N/A'}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (experience.isCurrent)
                            Chip(
                              label: const Text('Current'),
                              backgroundColor: Colors.green.shade50,
                            ),
                          AppUtils().hSpace(size: 8),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed:
                                () => _showAddEditExperienceDialog(
                                  experience: experience,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(experience),
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

  void _showAddEditExperienceDialog({ExperienceModel? experience}) {
    showDialog(
      context: context,
      builder: (context) => ExperienceFormDialog(experience: experience),
    ).then((saved) {
      if (saved == true) {
        _loadExperiences();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted'), backgroundColor: Colors.green));
      debugPrint('Successfully deleted item');
      }
    });
  }
}
