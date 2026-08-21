import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/database/portfolio_repository.dart';
import 'admin_analytics.dart';
import 'admin_entity_editor.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedTab = 0;
  bool _loading = true;
  Map<String, int> _stats = {};
  late PortfolioRepository _repo;

  // ── Profile editors ──────────────────────────────────────────
  final Map<String, TextEditingController> _profileCtrls = {};

  @override
  void initState() {
    super.initState();
    _repo = PortfolioRepository();
    _loadData();
  }

  @override
  void dispose() {
    for (final c in _profileCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrl(String key, {String? fallback}) {
    return _profileCtrls.putIfAbsent(key, () {
      final val = _repo.profile[key]?.toString() ?? fallback ?? '';
      return TextEditingController(text: val);
    });
  }

  Future<void> _loadData() async {
    await _repo.refresh();
    _stats = await _repo.getStats();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isWide = MediaQuery.sizeOf(context).width > 768;

    return Scaffold(
      backgroundColor: AppColors.deep,
      drawer: isWide ? null : _buildMobileDrawer(),
      body: Row(
        children: [
          if (isWide) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(user, isWide),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Drawer? _buildMobileDrawer() {
    return Drawer(
      backgroundColor: AppColors.base,
      child: _buildSidebarContent(popOnTap: true),
    );
  }

  Widget _buildSidebar() {
    return SizedBox(width: 220, child: _buildSidebarContent());
  }

  Widget _buildSidebarContent({bool popOnTap = false}) {
    final items = [
      _SidebarItem(Icons.dashboard_outlined, 'DASHBOARD'),
      _SidebarItem(Icons.person_outline, 'PROFILE'),
      _SidebarItem(Icons.work_outline, 'PROJECTS'),
      _SidebarItem(Icons.timeline, 'EXPERIENCE'),
      _SidebarItem(Icons.school_outlined, 'EDUCATION'),
      _SidebarItem(Icons.verified_outlined, 'CERTIFICATIONS'),
      _SidebarItem(Icons.code_outlined, 'SKILLS'),
      _SidebarItem(Icons.translate_outlined, 'LANGUAGES'),
      _SidebarItem(Icons.format_quote, 'TESTIMONIALS'),
      _SidebarItem(Icons.build_outlined, 'SERVICES'),
      _SidebarItem(Icons.article_outlined, 'BLOG'),
      _SidebarItem(Icons.share_outlined, 'SOCIAL'),
      _SidebarItem(Icons.mail_outline, 'CONTACTS'),
      _SidebarItem(Icons.people_outline, 'SUBSCRIBERS'),
      _SidebarItem(Icons.analytics_outlined, 'ANALYTICS'),
    ];

    return Container(
      color: AppColors.base,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    border: Border.all(color: AppColors.accent, width: 2),
                  ),
                  child: const Center(
                    child: Text('HS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.deep)),
                  ),
                ),
                const SizedBox(width: 10),
                Text('ADMIN', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 2)),
              ],
            ),
          ),
          const Divider(color: AppColors.border, thickness: 2, height: 2),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = _selectedTab == index;
                return Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  child: Material(
                    color: isSelected ? AppColors.accent.withValues(alpha: 0.12) : Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedTab = index);
                        if (popOnTap) Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Icon(item.icon, color: isSelected ? AppColors.accent : AppColors.textMuted, size: 18),
                            const SizedBox(width: 12),
                            Text(
                              item.label,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? AppColors.accent : AppColors.textMuted,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildAppBar(User? user, bool isWide) {
    final titles = [
      'DASHBOARD', 'PROFILE', 'PROJECTS', 'EXPERIENCE', 'EDUCATION',
      'CERTIFICATIONS', 'SKILLS', 'LANGUAGES', 'TESTIMONIALS', 'SERVICES',
      'BLOG', 'SOCIAL', 'CONTACTS', 'SUBSCRIBERS', 'ANALYTICS',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.base,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isWide)
                Builder(
                  builder: (ctx) => IconButton(
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                    icon: const Icon(Icons.menu, color: AppColors.textMuted),
                  ),
                ),
              if (!isWide) const SizedBox(width: 8),
              Text(
                _loading ? 'LOADING...' : titles[_selectedTab.clamp(0, titles.length - 1)],
                style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1),
              ),
            ],
          ),
          Row(
            children: [
              _badge(_repo.usesDatabase ? 'DB CONNECTED' : 'FALLBACK', _repo.usesDatabase ? AppColors.accent : AppColors.warning),
              if (isWide) ...[
                const SizedBox(width: 16),
                Text(user?.email ?? '', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textMuted)),
              ],
              const SizedBox(width: 16),
              IconButton(
                onPressed: () async => await FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.logout, color: AppColors.textMuted, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), border: Border.all(color: color, width: 2)),
      child: Text(text, style: GoogleFonts.spaceGrotesk(fontSize: 10, color: color, fontWeight: FontWeight.w800, letterSpacing: 1)),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0: return _buildOverview();
      case 1: return _buildProfileEditor();
      case 2: return AdminEntityEditor(entityType: 'projects', items: _repo.projects, onSave: _repo.saveProject, onDelete: (id) async { await _repo.deleteProject(id); await _loadData(); });
      case 3: return AdminEntityEditor(entityType: 'experience', items: _repo.experience, onSave: _repo.saveExperience, onDelete: (id) async { await _repo.deleteExperience(id); await _loadData(); });
      case 4: return AdminEntityEditor(entityType: 'education', items: _repo.education, onSave: _repo.saveEducation, onDelete: (id) async { await _repo.deleteEducation(id); await _loadData(); });
      case 5: return AdminEntityEditor(entityType: 'certifications', items: _repo.certifications, onSave: _repo.saveCertification, onDelete: (id) async { await _repo.deleteCertification(id); await _loadData(); });
      case 6: return AdminEntityEditor(entityType: 'skills', items: _repo.skills, onSave: _repo.saveSkill, onDelete: (id) async { await _repo.deleteSkill(id); await _loadData(); });
      case 7: return AdminEntityEditor(entityType: 'languages', items: _repo.languages, onSave: _repo.saveLanguage, onDelete: (id) async { await _repo.deleteLanguage(id); await _loadData(); });
      case 8: return AdminEntityEditor(entityType: 'testimonials', items: _repo.testimonials, onSave: _repo.saveTestimonial, onDelete: (id) async { await _repo.deleteTestimonial(id); await _loadData(); });
      case 9: return AdminEntityEditor(entityType: 'services', items: _repo.services, onSave: _repo.saveService, onDelete: (id) async { await _repo.deleteService(id); await _loadData(); });
      case 10: return AdminEntityEditor(entityType: 'blog', items: _repo.posts, onSave: _repo.savePost, onDelete: (id) async { await _repo.deletePost(id); await _loadData(); });
      case 11: return AdminEntityEditor(entityType: 'social', items: _repo.socialLinks, onSave: _repo.saveSocialLink, onDelete: (id) async { await _repo.deleteSocialLink(id); await _loadData(); });
      case 12: return _buildContacts();
      case 13: return _buildSubscribers();
      case 14: return const AdminAnalytics();
      default: return _buildOverview();
    }
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OVERVIEW', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1)),
          const SizedBox(height: 8),
          Container(width: 24, height: 3, color: AppColors.accent),
          const SizedBox(height: 32),
          Row(children: [
            Expanded(child: _overviewCard('PROJECTS', '${_stats['projects'] ?? 0}', Icons.work_outline)),
            const SizedBox(width: 16),
            Expanded(child: _overviewCard('EXPERIENCE', '${_stats['experience'] ?? 0}', Icons.timeline)),
            const SizedBox(width: 16),
            Expanded(child: _overviewCard('SKILLS', '${_stats['skills'] ?? 0}', Icons.code_outlined)),
            const SizedBox(width: 16),
            Expanded(child: _overviewCard('VIEWS', '${_stats['views'] ?? 0}', Icons.visibility_outlined)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _overviewCard('CONTACTS', '${_stats['contacts'] ?? 0}', Icons.mail_outline)),
            const SizedBox(width: 16),
            Expanded(child: _overviewCard('SUBSCRIBERS', '${_stats['subscribers'] ?? 0}', Icons.people_outline)),
            const SizedBox(width: 16),
            Expanded(child: _overviewCard('DB STATUS', _repo.usesDatabase ? 'CONNECTED' : 'FALLBACK', Icons.storage)),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()),
          ]),
          const SizedBox(height: 48),
          Text('QUICK ACTIONS', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 2)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _quickAction('VIEW PORTFOLIO', Icons.open_in_new, () {
                context.go('/');
              }),
              _quickAction('ANALYTICS', Icons.analytics_outlined, () {
                setState(() => _selectedTab = 14);
              }),
              _quickAction('REFRESH DATA', Icons.refresh, () async {
                await _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('DATA REFRESHED'), backgroundColor: AppColors.accent),
                  );
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.base,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(4, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _quickAction(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.base,
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: const [BoxShadow(color: Color(0x30000000), offset: Offset(3, 3))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.accent),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileEditor() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PROFILE', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1)),
          const SizedBox(height: 8),
          Container(width: 24, height: 3, color: AppColors.accent),
          const SizedBox(height: 32),
          _field('NAME', _ctrl('name')),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _field('TITLE', _ctrl('title'))),
            const SizedBox(width: 16),
            Expanded(child: _field('SUBTITLE', _ctrl('subtitle'))),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _field('LOCATION', _ctrl('location'))),
            const SizedBox(width: 16),
            Expanded(child: _field('EMAIL', _ctrl('email'))),
            const SizedBox(width: 16),
            Expanded(child: _field('PHONE', _ctrl('phone'))),
          ]),
          const SizedBox(height: 16),
          _field('BIO', _ctrl('bio'), maxLines: 3),
          const SizedBox(height: 16),
          _field('ABOUT', _ctrl('about'), maxLines: 6),
          const SizedBox(height: 16),
          _field('QUOTE', _ctrl('quote')),
          const SizedBox(height: 24),
          Text('LINKS', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 2)),
          const SizedBox(height: 16),
          _field('AVATAR URL', _ctrl('avatar_url')),
          const SizedBox(height: 16),
          _field('RESUME URL', _ctrl('resume_url')),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _field('LINKEDIN URL', _ctrl('linkedin_url'))),
            const SizedBox(width: 16),
            Expanded(child: _field('GITHUB URL', _ctrl('github_url'))),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _field('BUY ME A COFFEE URL', _ctrl('buy_me_a_coffee_url'))),
            const SizedBox(width: 16),
            Expanded(child: _field('CAL.COM USERNAME', _ctrl('calcom_username'))),
          ]),
          const SizedBox(height: 32),
          InkWell(
            onTap: () async {
              await _repo.updateProfile({
                'name': _ctrl('name').text,
                'title': _ctrl('title').text,
                'subtitle': _ctrl('subtitle').text,
                'location': _ctrl('location').text,
                'email': _ctrl('email').text,
                'phone': _ctrl('phone').text,
                'bio': _ctrl('bio').text,
                'about': _ctrl('about').text,
                'quote': _ctrl('quote').text,
                'avatar_url': _ctrl('avatar_url').text,
                'resume_url': _ctrl('resume_url').text,
                'linkedin_url': _ctrl('linkedin_url').text,
                'github_url': _ctrl('github_url').text,
                'buy_me_a_coffee_url': _ctrl('buy_me_a_coffee_url').text,
                'calcom_username': _ctrl('calcom_username').text,
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PROFILE UPDATED'), backgroundColor: AppColors.accent),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.accent,
                border: Border.all(color: AppColors.accent, width: 2),
                boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(4, 4))],
              ),
              child: Text('SAVE PROFILE', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.deep, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContacts() {
    final contacts = _repo.contactSubmissions;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CONTACTS', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1)),
              Text('${contacts.length} SUBMISSIONS', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 8),
          Container(width: 24, height: 3, color: AppColors.accent),
          const SizedBox(height: 24),
          if (contacts.isEmpty)
            _emptyState('NO CONTACT SUBMISSIONS YET')
          else
            ...contacts.map((c) {
              final isUnread = c['status'] == 'unread';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.base,
                  border: Border.all(
                    color: isUnread ? AppColors.accent : AppColors.border,
                    width: 2,
                  ),
                  boxShadow: const [BoxShadow(color: Color(0x30000000), offset: Offset(3, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (isUnread)
                              Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 8), decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent)),
                            Text('${c['name']}', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 0.5)),
                            Text(' · ${c['email']}', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                        Row(
                          children: [
                            if (!isUnread)
                              _smallButton('MARK UNREAD', () async {
                                await _repo.updateContactStatus(c['id'], 'unread');
                                await _loadData();
                              }),
                            if (isUnread)
                              _smallButton('MARK READ', () async {
                                await _repo.updateContactStatus(c['id'], 'read');
                                await _loadData();
                              }),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () async {
                                await _repo.deleteContactSubmission(c['id']);
                                await _loadData();
                              },
                              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(c['message'] ?? '', style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text(c['submitted_at'] ?? '', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSubscribers() {
    final subs = _repo.subscribers;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SUBSCRIBERS', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1)),
              Text('${subs.length} SUBSCRIBERS', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 8),
          Container(width: 24, height: 3, color: AppColors.accent),
          const SizedBox(height: 24),
          if (subs.isEmpty)
            _emptyState('NO SUBSCRIBERS YET')
          else
            ...subs.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.base,
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: const [BoxShadow(color: Color(0x30000000), offset: Offset(3, 3))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: AppColors.accent, size: 18),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['email']?.toString() ?? '', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        Text('${s['source'] ?? 'website'} • ${s['subscribed_at'] ?? ''}', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _repo.deleteSubscriber(s['id']);
                      await _loadData();
                    },
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 2)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.base,
            border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.border, width: 2)),
            enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.border, width: 2)),
            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.accent, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _smallButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1)),
      ),
    );
  }

  Widget _emptyState(String text) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.base,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x30000000), offset: Offset(4, 4))],
      ),
      child: Center(
        child: Text(text, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 2)),
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  const _SidebarItem(this.icon, this.label);
}
