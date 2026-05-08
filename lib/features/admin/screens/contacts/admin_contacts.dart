import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminContactsScreen extends StatefulWidget {
  const AdminContactsScreen({super.key});

  @override
  State<AdminContactsScreen> createState() => _AdminContactsScreenState();
}

class _AdminContactsScreenState extends State<AdminContactsScreen> {
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      setState(() => _isLoading = true);
      final response = await SupabaseService.requiredClient
          .from('contact_messages')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _messages = (response as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id, bool isRead) async {
    try {
      await SupabaseService.requiredClient
          .from('contact_messages')
          .update({'is_read': !isRead})
          .eq('id', id);
      _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          Text(
            'Contact Messages',
            style: AppStyles.heading(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          AppUtils().vSpace(size: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_messages.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  AppUtils().vSpace(size: 16),
                  Text(
                    'No messages yet',
                    style: AppStyles.heading(fontSize: 24),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isRead = message['is_read'] as bool? ?? false;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: isRead ? Colors.white : Colors.blue.shade50,
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          (message['name'] as String? ?? 'U')[0].toUpperCase(),
                        ),
                      ),
                      title: Text(
                        message['name'] as String? ?? 'Unknown',
                        style: TextStyle(
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(message['email'] as String? ?? ''),
                          AppUtils().vSpace(size: 4),
                          Text(
                            message['message'] as String? ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppUtils().vSpace(size: 4),
                          Text(
                            _formatDate(message['created_at'] as String?),
                            style: AppStyles.body(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isRead
                              ? Icons.mark_email_read
                              : Icons.mark_email_unread,
                        ),
                        onPressed:
                            () => _markAsRead(message['id'] as String, isRead),
                      ),
                      onTap: () => _showMessageDetail(message),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showMessageDetail(Map<String, dynamic> message) {
    final attachmentUrl = message['attachment_url'] as String?;
    final subject = message['subject'] as String?;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(message['name'] as String? ?? 'Unknown'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Email: ${message['email']}'),
                  if (subject != null && subject.isNotEmpty) ...[
                    AppUtils().vSpace(size: 8),
                    Text('Subject: $subject', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                  AppUtils().vSpace(size: 16),
                  Text('Message:', style: const TextStyle(fontWeight: FontWeight.bold)),
                  AppUtils().vSpace(size: 8),
                  Text(message['message'] as String? ?? ''),
                  if (attachmentUrl != null && attachmentUrl.isNotEmpty) ...[
                    AppUtils().vSpace(size: 16),
                    Text('Attachment:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    AppUtils().vSpace(size: 8),
                    _buildAttachmentView(attachmentUrl),
                  ],
                  AppUtils().vSpace(size: 16),
                  Text(
                    'Date: ${_formatDate(message['created_at'] as String?)}',
                    style: AppStyles.body(fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildAttachmentView(String attachmentData) {
    if (attachmentData.startsWith('data:image')) {
      try {
        final base64String = attachmentData.split(',').last;
        final bytes = base64Decode(base64String);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.memory(bytes, height: 200, fit: BoxFit.contain),
            AppUtils().vSpace(size: 8),
            ElevatedButton.icon(
              onPressed: () => _downloadFile(attachmentData, 'attachment.png'),
              icon: const Icon(Icons.download),
              label: const Text('Download Image'),
            ),
          ],
        );
      } catch (e) {
        return const Text('Invalid image data');
      }
    } else if (attachmentData.startsWith('data:application/pdf')) {
      return ElevatedButton.icon(
        onPressed: () => _downloadFile(attachmentData, 'attachment.pdf'),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Download PDF'),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () => _downloadFile(attachmentData, 'attachment.file'),
        icon: const Icon(Icons.download),
        label: const Text('Download File'),
      );
    }
  }

  void _downloadFile(String dataUrl, String defaultName) {
    try {
      // Platform-agnostic download via url_launcher
      final Uri uri = Uri.parse(dataUrl);
      launchUrl(uri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not download file: $e')),
        );
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return dateString;
    }
  }
}
