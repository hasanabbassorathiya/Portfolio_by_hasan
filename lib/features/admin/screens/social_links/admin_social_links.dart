/// Admin social links management screen
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio/core/repositories/social_link_repository.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/models/social_link/social_link_model.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/utils/platform_icons.dart';
import 'package:portfolio/shared/widgets/draggable_list_widget.dart';
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
      debugPrint('Loading social links...');
      final links = await _socialLinkRepository.getAllSocialLinks();
      debugPrint('Fetched ${links.length} social links: ${links.map((l) => l.platform).join(', ')}');
      // Sort by order_index
      links.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      setState(() {
        debugPrint('Loaded ${links.length} social links');
        _socialLinks = links;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading social links: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Load error: $e'), duration: const Duration(seconds: 10)),
        );
      }
    }
  }

  Future<void> _updateOrder(List<SocialLinkModel> reorderedItems) async {
    try {
      // Update order_index for each item
      for (int i = 0; i < reorderedItems.length; i++) {
        await SupabaseService.requiredClient
            .from('social_links')
            .update({'order_index': i})
            .eq('id', reorderedItems[i].id);
      }
      // Reload to get updated list
      await _loadSocialLinks();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted'), backgroundColor: Colors.green));
      debugPrint('Successfully deleted item');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _deleteSocialLink(String id) async {
    try {
      await SupabaseService.requiredClient.from('social_links').delete().eq('id', id);
      _loadSocialLinks();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted'), backgroundColor: Colors.green));
      debugPrint('Successfully deleted item');
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
              child: DraggableListWidget<SocialLinkModel>(
                items: _socialLinks,
                onReorder: _updateOrder,
                emptyMessage: 'No social links yet. Add one to get started!',
                itemBuilder: (context, link, index) {
                  return ListTile(
                    leading: const Icon(Icons.drag_handle, color: Colors.grey),
                    title: Row(
                      children: [
                        FaIcon(
                          PlatformIcons.getIcon(link.platform),
                          size: 24,
                          color: PlatformIcons.getColor(link.platform),
                        ),
                        AppUtils().hSpace(size: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                PlatformIcons.getDisplayName(link.platform),
                                style: AppStyles.body(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              AppUtils().vSpace(size: 4),
                              Text(
                                link.url,
                                style: AppStyles.body(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#${index + 1}',
                          style: AppStyles.body(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        AppUtils().hSpace(size: 8),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showAddEditSocialLinkDialog(link: link),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () => _confirmDelete(link),
                          tooltip: 'Delete',
                        ),
                      ],
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted'), backgroundColor: Colors.green));
      debugPrint('Successfully deleted item');
      }
    });
  }
}
