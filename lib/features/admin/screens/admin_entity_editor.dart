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
  };

  String get _title => widget.entityType[0].toUpperCase() + widget.entityType.substring(1);

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
          SnackBar(content: Text('${f.label} is required'), backgroundColor: AppColors.error),
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
          SnackBar(content: Text('$_title saved'), backgroundColor: AppColors.accent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
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
        title: Text('Delete $_title', style: GoogleFonts.montserrat(color: AppColors.textPrimary)),
        content: Text('Delete "$name"? This cannot be undone.', style: GoogleFonts.montserrat(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
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
              Text(_title, style: GoogleFonts.cormorant(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Row(
                children: [
                  Text('${widget.items.length} items', style: GoogleFonts.montserrat(fontSize: 14, color: AppColors.textMuted)),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _startEditing(),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('Add $_title', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.deep,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surface),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(_getIcon(), size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('No ${widget.entityType} yet', style: GoogleFonts.montserrat(fontSize: 16, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _startEditing(),
              icon: const Icon(Icons.add, size: 18),
              label: Text('Add First $_title', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.deep,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final displayName = item['name'] ?? item['title'] ?? item['company'] ?? item['degree'] ?? item['quote'] ?? item['id'];
    final subtitle = item['position'] ?? item['institution'] ?? item['issuer'] ?? item['description'] ?? item['client_name'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.base,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surface),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName.toString(), style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                if (subtitle.toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle.toString(), style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _startEditing(item),
            icon: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 20),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: () => _confirmDelete(item),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            tooltip: 'Delete',
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
              IconButton(
                onPressed: _cancelEditing,
                icon: const Icon(Icons.arrow_back, color: AppColors.textMuted),
              ),
              const SizedBox(width: 8),
              Text(
                _editingItem != null ? 'Edit $_title' : 'New $_title',
                style: GoogleFonts.cormorant(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 32),
          for (int i = 0; i < _fields.length; i++) ...[
            _buildField(_fields[i]),
            if (i < _fields.length - 1) const SizedBox(height: 20),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.deep,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.deep))
                    : Text('Save', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: _cancelEditing,
                child: Text('Cancel', style: GoogleFonts.montserrat(color: AppColors.textMuted)),
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
          style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controllers[field.key],
          maxLines: field.multiline ? 5 : 1,
          style: GoogleFonts.montserrat(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.deep,
            hintText: field.hint,
            hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.glassBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.glassBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent)),
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
