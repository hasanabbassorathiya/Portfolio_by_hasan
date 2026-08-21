import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/database/portfolio_repository.dart';

class AdminAnalytics extends StatefulWidget {
  const AdminAnalytics({super.key});

  @override
  State<AdminAnalytics> createState() => _AdminAnalyticsState();
}

class _AdminAnalyticsState extends State<AdminAnalytics> {
  Map<String, int> _stats = {};
  List<Map<String, dynamic>> _analyticsData = [];
  bool _loading = true;
  late PortfolioRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = PortfolioRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    _stats = await _repo.getStats();
    _analyticsData = await _repo.getAnalyticsSummary();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ANALYTICS', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1)),
          const SizedBox(height: 8),
          Container(width: 24, height: 3, color: AppColors.accent),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(child: _statCard('TOTAL VIEWS', '${_stats['views'] ?? 0}', Icons.visibility_outlined, AppColors.accent)),
              const SizedBox(width: 16),
              Expanded(child: _statCard('CONTACTS', '${_stats['contacts'] ?? 0}', Icons.mail_outline, AppColors.accentHover)),
              const SizedBox(width: 16),
              Expanded(child: _statCard('SUBSCRIBERS', '${_stats['subscribers'] ?? 0}', Icons.people_outline, AppColors.accent)),
              const SizedBox(width: 16),
              Expanded(child: _statCard('PROJECTS', '${_stats['projects'] ?? 0}', Icons.work_outline, AppColors.accentHover)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _statCard('EXPERIENCE', '${_stats['experience'] ?? 0}', Icons.timeline, AppColors.accent)),
              const SizedBox(width: 16),
              Expanded(child: _statCard('SKILLS', '${_stats['skills'] ?? 0}', Icons.code_outlined, AppColors.accentHover)),
              const SizedBox(width: 16),
              Expanded(child: _statCard('DB STATUS', _repo.usesDatabase ? 'CONNECTED' : 'FALLBACK', Icons.storage, _repo.usesDatabase ? AppColors.accent : AppColors.warning)),
              const SizedBox(width: 16),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 48),

          _buildSectionLabel('PAGE VIEWS (LAST 30 DAYS)'),
          const SizedBox(height: 16),
          _buildSimpleChart(),
          const SizedBox(height: 48),

          _buildSectionLabel('RECENT CONTACTS'),
          const SizedBox(height: 16),
          _buildRecentContacts(),
          const SizedBox(height: 48),

          _buildSectionLabel('RECENT SUBSCRIBERS'),
          const SizedBox(height: 16),
          _buildRecentSubscribers(),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
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
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Row(
      children: [
        Container(width: 24, height: 3, color: AppColors.accent),
        const SizedBox(width: 12),
        Text(text, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 2)),
      ],
    );
  }

  Widget _buildSimpleChart() {
    final viewData = _analyticsData.where((d) => d['event_type'] == 'page_view').toList();

    if (viewData.isEmpty) {
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
              const Icon(Icons.analytics_outlined, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text('NO ANALYTICS DATA YET', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text('Page views will appear here as visitors browse your portfolio', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    final maxCount = viewData.fold<int>(0, (max, d) {
      final c = (d['count'] ?? 0) as int;
      return c > max ? c : max;
    });

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.base,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x30000000), offset: Offset(4, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: viewData.take(14).map((d) {
                final count = (d['count'] ?? 0) as int;
                final height = maxCount > 0 ? (count / maxCount) * 180.0 : 0.0;
                final date = d['date']?.toString() ?? '';
                final shortDate = date.length >= 5 ? date.substring(5) : date;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('$count', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Container(
                          height: height.clamp(4.0, 180.0),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(shortDate, style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentContacts() {
    final contacts = _repo.contactSubmissions.take(5).toList();

    if (contacts.isEmpty) {
      return _emptyCard('NO CONTACT SUBMISSIONS YET');
    }

    return Column(
      children: contacts.map((c) {
        final isUnread = c['status'] == 'unread';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.base,
            border: Border.all(
              color: isUnread ? AppColors.accent : AppColors.border,
              width: 2,
            ),
            boxShadow: const [BoxShadow(color: Color(0x30000000), offset: Offset(3, 3))],
          ),
          child: Row(
            children: [
              if (isUnread)
                Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 12), decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent))
              else
                const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${c['name']} · ${c['email']}', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(c['message']?.toString() ?? '', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Text(c['submitted_at']?.toString() ?? '', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentSubscribers() {
    final subs = _repo.subscribers.take(5).toList();

    if (subs.isEmpty) {
      return _emptyCard('NO SUBSCRIBERS YET');
    }

    return Column(
      children: subs.map((s) => Container(
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
            const SizedBox(width: 12),
            Expanded(
              child: Text(s['email']?.toString() ?? '', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ),
            Text(s['subscribed_at']?.toString() ?? '', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.base,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x30000000), offset: Offset(3, 3))],
      ),
      child: Center(child: Text(text, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 2))),
    );
  }
}
