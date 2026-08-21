import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class AdminEntityEditor extends StatefulWidget {
  final String entityType;
  final List<Map<String, dynamic>> items;
  final Future<void> Function(Map<String, dynamic>) onSave;
  final Future<void> Function(String) onDelete;

  const AdminEntityEditor({
    super.key,
    required this.entityType,
    required this.items,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<AdminEntityEditor> createState() => _AdminEntityEditorState();
}

class _AdminEntityEditorState extends State<AdminEntityEditor> {
  bool _editing = false;
  Map<String, dynamic>? _editingItem;
  Map<String, TextEditingController> _controllers = {};
  bool _saving = false;

  List<EntityField> get _fields => _fieldConfig[widget.entityType] ?? [];

  static final Map<String, List<EntityField>> _fieldConfig = {
    'experience': [
      EntityField('company', label: 'Company', required: true),
      EntityField('position', label: 'Position', required: true),
      EntityField('start_date', label: 'Start Date', hint: 'e.g. Jul 2023'),
      EntityField('end_date', label: 'End Date', hint: 'e.g. Jan 2026 or Present'),
      EntityField('location', label: 'Location', hint: 'e.g. Dubai, UAE'),
      EntityField('highlights', label: 'Highlights', multiline: true, isJsonList: true, hint: 'One per line'),
    ],
    'education': [
      EntityField('degree', label: 'Degree', required: true),
      EntityField('institution', label: 'Institution', required: true),
      EntityField('period', label: 'Period', hint: 'e.g. 2016 – 2019'),
      EntityField('details', label: 'Details', multiline: true),
    ],
    'certifications': [
      EntityField('name', label: 'Certification Name', required: true),
      EntityField('issuer', label: 'Issuer'),
      EntityField('date', label: 'Date', hint: 'e.g. 2023'),
      EntityField('url', label: 'URL'),
    ],
    'skills': [
      EntityField('name', label: 'Skill Name', required: true),
      EntityField('category', label: 'Category', required: true, hint: 'e.g. Mobile & Cross-Platform'),
      EntityField('level', label: 'Level', hint: 'e.g. Expert, Advanced, Intermediate'),
    ],
    'languages': [
      EntityField('name', label: 'Language', required: true),
      EntityField('proficiency', label: 'Proficiency', hint: 'e.g. Native, Professional, Intermediate'),
    ],
    'projects': [
      EntityField('title', label: 'Title', required: true),
      EntityField('category', label: 'Category', hint: 'e.g. Mobile, Web, FinTech'),
      EntityField('description', label: 'Description', multiline: true, required: true),
      EntityField('client', label: 'Client'),
      EntityField('year', label: 'Year'),
      EntityField('role', label: 'Role'),
      EntityField('technologies', label: 'Technologies', isJsonList: true, hint: 'One per line'),
      EntityField('tags', label: 'Tags', isJsonList: true, hint: 'One per line'),
      EntityField('ios_url', label: 'iOS URL'),
      EntityField('android_url', label: 'Android URL'),
      EntityField('web_url', label: 'Web URL'),
    ],
    'testimonials': [
      EntityField('quote', label: 'Quote', multiline: true, required: true),
      EntityField('client_name', label: 'Client Name', required: true),
      EntityField('client_company', label: 'Company'),
      EntityField('client_role', label: 'Role'),
      EntityField('avatar_url', label: 'Avatar URL'),
    ],
    'services': [
      EntityField('title', label: 'Title', required: true),
      EntityField('description', label: 'Description', multiline: true, required: true),
      EntityField('features', label: 'Features', isJsonList: true, hint: 'One per line'),
    ],
    'blog': [
      EntityField('title', label: 'Title', required: true),
      EntityField('slug', label: 'Slug', required: true, hint: 'e.g. my-post-url'),
      EntityField('excerpt', label: 'Excerpt', multiline: true),
      EntityField('category', label: 'Category', hint: 'e.g. Engineering, AI'),
      EntityField('read_time', label: 'Read Time', hint: 'e.g. 8 min read'),
      EntityField('published_at', label: 'Published At', hint: 'e.g. 2026-01-15'),
      EntityField('tags', label: 'Tags', isJsonList: true, hint: 'One per line'),
    ],
    'social': [
      EntityField('platform', label: 'Platform', required: true),
      EntityField('url', label: 'URL', required: true),
      EntityField('icon', label: 'Icon Key', hint: 'linkedin, email, coffee, github'),
    ],
  };

  String get _title => widget.entityType.toUpperCase();

  void _startEditing([Map<String, dynamic>? item]) {
    _editingItem = item;
    _controllers = {};
    for (final f in _fields) {
      dynamic val = item?[f.key] ?? '';
      if (f.isJsonList && val is List) {
        val = (val).join('\n');
      }
      _controllers[f.key] = TextEditingController(text: val.toString());
    }
    setState(() => _editing = true);
  }

  void _cancelEditing() {
    setState(() {
      _editing = false;
      _editingItem = null;
      _controllers = {};
    });
  }

  Future<void> _save() async {
    final data = <String, dynamic>{};
    for (final f in _fields) {
      final text = _controllers[f.key]?.text.trim() ?? '';
      if (f.required && text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${f.label.toUpperCase()} IS REQUIRED'), backgroundColor: AppColors.error),
        );
        return;
      }
      if (f.isJsonList) {
        data[f.key] = text.isEmpty ? [] : text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      } else {
        data[f.key] = text;
      }
    }

    if (_editingItem != null && _editingItem!['id'] != null) {
      data['id'] = _editingItem!['id'];
    } else {
      data['id'] = '${widget.entityType}_${DateTime.now().millisecondsSinceEpoch}';
    }

    if (data.containsKey('display_order')) {
      // keep existing
    } else if (_editingItem != null && _editingItem!['display_order'] != null) {
      data['display_order'] = _editingItem!['display_order'];
    } else {
      data['display_order'] = widget.items.length;
    }

    setState(() => _saving = true);
    try {
      await widget.onSave(data);
      _cancelEditing();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_title SAVED'), backgroundColor: AppColors.accent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    final name = item['name'] ?? item['title'] ?? item['company'] ?? item['degree'] ?? item['id'];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.base,
        shape: const RoundedRectangleBorder(side: BorderSide(color: AppColors.border, width: 2)),
        title: Text('DELETE $_title', style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w900, letterSpacing: 1)),
        content: Text('Delete "$name"? This cannot be undone.', style: GoogleFonts.spaceGrotesk(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: GoogleFonts.spaceGrotesk(color: AppColors.textMuted, fontWeight: FontWeight.w700, letterSpacing: 1)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('DELETE', style: GoogleFonts.spaceGrotesk(color: AppColors.error, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.onDelete(item['id'].toString());
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) return _buildEditor();
    return _buildList();
  }

  Widget _buildList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_title, style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text('${widget.items.length} ITEMS', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1)),
                ],
              ),
              InkWell(
                onTap: () => _startEditing(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    border: Border.all(color: AppColors.accent, width: 2),
                    boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(3, 3))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 16, color: AppColors.deep),
                      const SizedBox(width: 8),
                      Text('ADD $_title', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.deep, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(width: 24, height: 3, color: AppColors.accent),
          const SizedBox(height: 24),
          if (widget.items.isEmpty)
            _buildEmptyState()
          else
            ...widget.items.map((item) => _buildItemCard(item)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.base,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x30000000), offset: Offset(4, 4))],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(_getIcon(), size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('NO ${widget.entityType.toUpperCase()} YET', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 2)),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _startEditing(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  border: Border.all(color: AppColors.accent, width: 2),
                  boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(3, 3))],
                ),
                child: Text('ADD FIRST $_title', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.deep, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final displayName = item['name'] ?? item['title'] ?? item['company'] ?? item['degree'] ?? item['quote'] ?? item['platform'] ?? item['id'];
    final subtitle = item['position'] ?? item['institution'] ?? item['issuer'] ?? item['description'] ?? item['client_name'] ?? item['excerpt'] ?? item['url'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.base,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x30000000), offset: Offset(3, 3))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName.toString(), style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 0.5)),
                if (subtitle.toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle.toString(), style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: () => _startEditing(item),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all(color: AppColors.border, width: 1)),
              child: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _confirmDelete(item),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all(color: AppColors.error, width: 1)),
              child: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: _cancelEditing,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.border, width: 2)),
                  child: const Icon(Icons.arrow_back, color: AppColors.textMuted, size: 18),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _editingItem != null ? 'EDIT $_title' : 'NEW $_title',
                style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(width: 24, height: 3, color: AppColors.accent),
          const SizedBox(height: 32),
          for (int i = 0; i < _fields.length; i++) ...[
            _buildField(_fields[i]),
            if (i < _fields.length - 1) const SizedBox(height: 20),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              InkWell(
                onTap: _saving ? null : _save,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: _saving ? AppColors.muted : AppColors.accent,
                    border: Border.all(color: _saving ? AppColors.muted : AppColors.accent, width: 2),
                    boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(4, 4))],
                  ),
                  child: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.deep))
                      : Text('SAVE', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.deep, letterSpacing: 1)),
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: _cancelEditing,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.border, width: 2)),
                  child: Text('CANCEL', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(EntityField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controllers[field.key],
          maxLines: field.multiline ? 5 : 1,
          style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.base,
            hintText: field.hint,
            hintStyle: GoogleFonts.spaceGrotesk(color: AppColors.textMuted.withValues(alpha: 0.5), fontSize: 12),
            border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.border, width: 2)),
            enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.border, width: 2)),
            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.accent, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  IconData _getIcon() {
    switch (widget.entityType) {
      case 'experience': return Icons.work_outline;
      case 'education': return Icons.school_outlined;
      case 'certifications': return Icons.verified_outlined;
      case 'skills': return Icons.code_outlined;
      case 'languages': return Icons.translate_outlined;
      case 'projects': return Icons.folder_outlined;
      case 'testimonials': return Icons.format_quote;
      case 'services': return Icons.build_outlined;
      case 'blog': return Icons.article_outlined;
      case 'social': return Icons.share_outlined;
      default: return Icons.article_outlined;
    }
  }
}

class EntityField {
  final String key;
  final String label;
  final bool required;
  final bool multiline;
  final bool isJsonList;
  final String? hint;

  const EntityField(this.key, {required this.label, this.required = false, this.multiline = false, this.isJsonList = false, this.hint});
}
