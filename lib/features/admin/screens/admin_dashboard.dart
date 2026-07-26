import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  void initState() {
    super.initState();
    _repo = PortfolioRepository();
    _loadData();
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
      child: _buildSidebarContent(),
    );
  }

  Widget _buildSidebar() {
    return SizedBox(width: 220, child: _buildSidebarContent());
  }

  Widget _buildSidebarContent() {
    final items = [
      _SidebarItem(Icons.dashboard_outlined, 'Dashboard'),
      _SidebarItem(Icons.person_outline, 'Profile'),
      _SidebarItem(Icons.work_outline, 'Projects'),
      _SidebarItem(Icons.timeline, 'Experience'),
      _SidebarItem(Icons.school_outlined, 'Education'),
      _SidebarItem(Icons.verified_outlined, 'Certifications'),
      _SidebarItem(Icons.code_outlined, 'Skills'),
      _SidebarItem(Icons.translate_outlined, 'Languages'),
      _SidebarItem(Icons.format_quote, 'Testimonials'),
      _SidebarItem(Icons.build_outlined, 'Services'),
      _SidebarItem(Icons.mail_outline, 'Contacts'),
      _SidebarItem(Icons.people_outline, 'Subscribers'),
      _SidebarItem(Icons.analytics_outlined, 'Analytics'),
    ];

    return Column(
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('HS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.deep))),
              ),
              const SizedBox(width: 10),
              Text('Admin', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
        ),
        const Divider(color: AppColors.glassBorder, height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = _selectedTab == index;
              return ListTile(
                leading: Icon(item.icon, color: isSelected ? AppColors.accent : AppColors.textMuted, size: 20),
                title: Text(
                  item.label,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
                selected: isSelected,
                selectedTileColor: AppColors.accent.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                dense: true,
                onTap: () {
                  setState(() => _selectedTab = index);
                  Navigator.pop(context); // close mobile drawer
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(User? user, bool isWide) {
    final titles = [
      'Dashboard', 'Profile', 'Projects', 'Experience', 'Education',
      'Certifications', 'Skills', 'Languages', 'Testimonials', 'Services',
      'Contacts', 'Subscribers', 'Analytics',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.base,
        border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
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
                _loading ? 'Loading...' : titles[_selectedTab.clamp(0, titles.length - 1)],
                style: GoogleFonts.cormorant(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          Row(
            children: [
              if (_repo.usesDatabase)
                _badge('DB Connected', AppColors.accent)
              else
                _badge('Fallback', Colors.orange),
              if (isWide) ...[
                const SizedBox(width: 16),
                Text(user?.email ?? '', style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textMuted)),
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
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
      case 10: return _buildContacts();
      case 11: return _buildSubscribers();
      case 12: return const AdminAnalytics();
      default: return _buildOverview();
    }
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: GoogleFonts.cormorant(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 32),
          Row(children: [
            Expanded(child: _overviewCard('Projects', '${_stats['projects'] ?? 0}', Icons.work_outline)),
            const SizedBox(width: 16),
            Expanded(child: _overviewCard('Experience', '${_stats['experience'] ?? 0}', Icons.timeline)),
            const SizedBox(width: 16),
            Expanded(child: _overviewCard('Skills', '${_stats['skills'] ?? 0}', Icons.code_outlined)),
            const SizedBox(width: 16),
            Expanded(child: _overviewCard('Views', '${_stats['views'] ?? 0}', Icons.visibility_outlined)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _overviewCard('Contacts', '${_stats['contacts'] ?? 0}', Icons.mail_outline)),
            const SizedBox(width: 16),
            Expanded(child: _overviewCard('Subscribers', '${_stats['subscribers'] ?? 0}', Icons.people_outline)),
            const SizedBox(width: 16),
            Expanded(child: _overviewCard('DB', _repo.usesDatabase ? 'Connected' : 'Fallback', Icons.storage)),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()),
          ]),
          const SizedBox(height: 48),
          // Quick actions
          Text('Quick Actions', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _quickAction('View Portfolio', Icons.open_in_new, () {
                Navigator.pushReplacementNamed(context, '/');
              }),
              _quickAction('Analytics', Icons.analytics_outlined, () {
                setState(() => _selectedTab = 12);
              }),
              _quickAction('Refresh Data', Icons.refresh, () async {
                await _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data refreshed'), backgroundColor: AppColors.accent),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 24),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.cormorant(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _quickAction(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.base,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surface),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.accent),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileEditor() {
    final p = _repo.profile;
    final nameCtrl = TextEditingController(text: p['name']?.toString());
    final titleCtrl = TextEditingController(text: p['title']?.toString());
    final subtitleCtrl = TextEditingController(text: p['subtitle']?.toString());
    final locationCtrl = TextEditingController(text: p['location']?.toString());
    final emailCtrl = TextEditingController(text: p['email']?.toString());
    final phoneCtrl = TextEditingController(text: p['phone']?.toString());
    final bioCtrl = TextEditingController(text: p['bio']?.toString());
    final aboutCtrl = TextEditingController(text: p['about']?.toString());
    final quoteCtrl = TextEditingController(text: p['quote']?.toString());
    final avatarCtrl = TextEditingController(text: p['avatar_url']?.toString());
    final resumeCtrl = TextEditingController(text: p['resume_url']?.toString());
    final linkedinCtrl = TextEditingController(text: p['linkedin_url']?.toString());
    final githubCtrl = TextEditingController(text: p['github_url']?.toString());
    final coffeeCtrl = TextEditingController(text: p['buy_me_a_coffee_url']?.toString());
    final calCtrl = TextEditingController(text: p['calcom_username']?.toString());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: GoogleFonts.cormorant(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 32),
          _field('NAME', nameCtrl),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _field('TITLE', titleCtrl)),
            const SizedBox(width: 16),
            Expanded(child: _field('SUBTITLE', subtitleCtrl)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _field('LOCATION', locationCtrl)),
            const SizedBox(width: 16),
            Expanded(child: _field('EMAIL', emailCtrl)),
            const SizedBox(width: 16),
            Expanded(child: _field('PHONE', phoneCtrl)),
          ]),
          const SizedBox(height: 16),
          _field('BIO', bioCtrl, maxLines: 3),
          const SizedBox(height: 16),
          _field('ABOUT', aboutCtrl, maxLines: 6),
          const SizedBox(height: 16),
          _field('QUOTE', quoteCtrl),
          const SizedBox(height: 24),
          Text('Links', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          _field('AVATAR URL', avatarCtrl),
          const SizedBox(height: 16),
          _field('RESUME URL', resumeCtrl),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _field('LINKEDIN URL', linkedinCtrl)),
            const SizedBox(width: 16),
            Expanded(child: _field('GITHUB URL', githubCtrl)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _field('BUY ME A COFFEE URL', coffeeCtrl)),
            const SizedBox(width: 16),
            Expanded(child: _field('CAL.COM USERNAME', calCtrl)),
          ]),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              await _repo.updateProfile({
                'name': nameCtrl.text,
                'title': titleCtrl.text,
                'subtitle': subtitleCtrl.text,
                'location': locationCtrl.text,
                'email': emailCtrl.text,
                'phone': phoneCtrl.text,
                'bio': bioCtrl.text,
                'about': aboutCtrl.text,
                'quote': quoteCtrl.text,
                'avatar_url': avatarCtrl.text,
                'resume_url': resumeCtrl.text,
                'linkedin_url': linkedinCtrl.text,
                'github_url': githubCtrl.text,
                'buy_me_a_coffee_url': coffeeCtrl.text,
                'calcom_username': calCtrl.text,
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated'), backgroundColor: AppColors.accent),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.deep,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save Profile', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
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
              Text('Contacts', style: GoogleFonts.cormorant(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text('${contacts.length} submissions', style: GoogleFonts.montserrat(fontSize: 14, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 24),
          if (contacts.isEmpty)
            _emptyState('No contact submissions yet')
          else
            ...contacts.map((c) {
              final isUnread = c['status'] == 'unread';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.base,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isUnread ? AppColors.accent.withValues(alpha: 0.3) : AppColors.surface),
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
                            Text('${c['name']}', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            Text(' — ${c['email']}', style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textMuted)),
                          ],
                        ),
                        Row(
                          children: [
                            if (!isUnread)
                              TextButton(
                                onPressed: () async {
                                  await _repo.updateContactStatus(c['id'], 'unread');
                                  await _loadData();
                                },
                                child: const Text('Mark Unread', style: TextStyle(fontSize: 12)),
                              ),
                            if (isUnread)
                              TextButton(
                                onPressed: () async {
                                  await _repo.updateContactStatus(c['id'], 'read');
                                  await _loadData();
                                },
                                child: const Text('Mark Read', style: TextStyle(fontSize: 12)),
                              ),
                            IconButton(
                              onPressed: () async {
                                await _repo.deleteContactSubmission(c['id']);
                                await _loadData();
                              },
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(c['message'] ?? '', style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text(c['submitted_at'] ?? '', style: GoogleFonts.montserrat(fontSize: 11, color: AppColors.textMuted)),
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
              Text('Subscribers', style: GoogleFonts.cormorant(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text('${subs.length} subscribers', style: GoogleFonts.montserrat(fontSize: 14, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 24),
          if (subs.isEmpty)
            _emptyState('No subscribers yet')
          else
            ...subs.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.base,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surface),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: AppColors.accent, size: 20),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['email']?.toString() ?? '', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text('${s['source'] ?? 'website'} • ${s['subscribed_at'] ?? ''}', style: GoogleFonts.montserrat(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _repo.deleteSubscriber(s['id']);
                      await _loadData();
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
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
        Text(label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 2)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: GoogleFonts.montserrat(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.deep,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.glassBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.glassBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(String text) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.base,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surface),
      ),
      child: Center(
        child: Text(text, style: GoogleFonts.montserrat(color: AppColors.textMuted)),
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  const _SidebarItem(this.icon, this.label);
}
