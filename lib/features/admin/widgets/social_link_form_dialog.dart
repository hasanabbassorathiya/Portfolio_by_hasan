/// Social link form dialog for creating/editing social links
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/models/social_link/social_link_model.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/utils/platform_icons.dart';

class SocialLinkFormDialog extends StatefulWidget {
  final SocialLinkModel? socialLink;

  const SocialLinkFormDialog({super.key, this.socialLink});

  @override
  State<SocialLinkFormDialog> createState() => _SocialLinkFormDialogState();
}

class _SocialLinkFormDialogState extends State<SocialLinkFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _orderIndexController = TextEditingController();
  String _selectedPlatform = 'facebook';
  bool _isLoading = false;

  final List<String> _platforms = [
    'facebook',
    'twitter',
    'instagram',
    'linkedin',
    'github',
    'behance',
    'dribbble',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.socialLink != null) {
      _urlController.text = widget.socialLink!.url;
      _orderIndexController.text = widget.socialLink!.orderIndex.toString();
      _selectedPlatform = widget.socialLink!.platform;
    } else {
      _orderIndexController.text = '0';
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _orderIndexController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get first profile ID if exists
      final profileResponse =
          await SupabaseService.requiredClient
              .from('profiles')
              .select('id')
              .maybeSingle();
      final profileId = profileResponse?['id'] as String?;

      final data = {
        'profile_id': profileId,
        'platform': _selectedPlatform,
        'url': _urlController.text.trim(),
        'order_index': int.tryParse(_orderIndexController.text) ?? 0,
      };

      if (widget.socialLink != null) {
        await SupabaseService.requiredClient
            .from('social_links')
            .update(data)
            .eq('id', widget.socialLink!.id);
      } else {
        await SupabaseService.requiredClient.from('social_links').insert(data);
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
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
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
                      widget.socialLink == null
                          ? 'Add Social Link'
                          : 'Edit Social Link',
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
                      DropdownButtonFormField<String>(
                        value: _selectedPlatform,
                        decoration: const InputDecoration(
                          labelText: 'Platform *',
                          border: OutlineInputBorder(),
                          helperText: 'Select a social media platform',
                        ),
                        items:
                            _platforms.map((platform) {
                              return DropdownMenuItem(
                                value: platform,
                                child: Row(
                                  children: [
                                    FaIcon(
                                      PlatformIcons.getIcon(platform),
                                      size: 20,
                                      color: PlatformIcons.getColor(platform),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(PlatformIcons.getDisplayName(platform)),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPlatform = value;
                            });
                          }
                        },
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          labelText: 'URL *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'URL is required';
                          }
                          if (!value.startsWith('http://') &&
                              !value.startsWith('https://')) {
                            return 'URL must start with http:// or https://';
                          }
                          return null;
                        },
                      ),
                      AppUtils().vSpace(size: 16),
                      TextFormField(
                        controller: _orderIndexController,
                        decoration: const InputDecoration(
                          labelText: 'Order Index',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
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
