/// Admin social links management screen
import 'package:flutter/material.dart';
import 'package:portfolio/core/repositories/social_link_repository.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/models/social_link/social_link_model.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/features/admin/widgets/social_link_form_dialog.dart';

class AdminSocialLinksScreen extends StatefulWidget {
  const AdminSocialLinksScreen({super.key});

  @override
  State<AdminSocialLinksScreen> createState() => _AdminSocialLinksScreenState();
}

class _AdminSocialLinksScreenState extends State<AdminSocialLinksScreen> {
  final SocialLinkRepository _socialLinkRepository = SocialLinkRepository();
  List<SocialLinkModel> _socialLinks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSocialLinks();
  }

  Future<void> _loadSocialLinks() async {
    try {
      setState(() => _isLoading = true);
      final links = await _socialLinkRepository.getAllSocialLinks();
      setState(() {
        _socialLinks = links;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSocialLink(String id) async {
    try {
      await SupabaseService.client.from('social_links').delete().eq('id', id);
      _loadSocialLinks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Social link deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting social link: $e')),
        );
      }
    }
  }

  void _confirmDelete(SocialLinkModel link) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Social Link'),
            content: Text(
              'Are you sure you want to delete ${link.platform} link?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteSocialLink(link.id);
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
                'Manage Social Links',
                style: AppStyles.heading(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditSocialLinkDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Social Link'),
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
          else if (_socialLinks.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link, size: 64, color: AppColors.textSecondary),
                  AppUtils().vSpace(size: 16),
                  Text(
                    'No social links yet',
                    style: AppStyles.heading(fontSize: 24),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _socialLinks.length,
                itemBuilder: (context, index) {
                  final link = _socialLinks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: const Icon(Icons.link),
                      title: Text(link.platform.toUpperCase()),
                      subtitle: Text(link.url),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Order: ${link.orderIndex}'),
                          AppUtils().hSpace(size: 16),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed:
                                () => _showAddEditSocialLinkDialog(link: link),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(link),
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

  void _showAddEditSocialLinkDialog({SocialLinkModel? link}) {
    showDialog(
      context: context,
      builder: (context) => SocialLinkFormDialog(socialLink: link),
    ).then((saved) {
      if (saved == true) {
        _loadSocialLinks();
      }
    });
  }
}
