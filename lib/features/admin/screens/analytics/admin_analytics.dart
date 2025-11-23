/// Admin analytics dashboard
/// Displays comprehensive analytics and metrics
import 'package:flutter/material.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  Map<String, dynamic> _analyticsData = {};
  bool _isLoading = true;
  String _selectedPeriod = '7d'; // 7d, 30d, 90d, all

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      setState(() => _isLoading = true);

      // Calculate date range
      final now = DateTime.now();
      DateTime startDate;
      switch (_selectedPeriod) {
        case '7d':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case '30d':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case '90d':
          startDate = now.subtract(const Duration(days: 90));
          break;
        default:
          startDate = DateTime(2020);
      }

      // Load page views
      final pageViewsResponse = await SupabaseService.client
          .from('page_views')
          .select()
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: false);

      // Load custom events
      final eventsResponse = await SupabaseService.client
          .from('custom_events')
          .select()
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: false);

      // Calculate statistics
      final pageViews =
          (pageViewsResponse as List).cast<Map<String, dynamic>>();
      final events = (eventsResponse as List).cast<Map<String, dynamic>>();

      // Group page views by path
      final Map<String, int> pageViewsByPath = {};
      for (final view in pageViews) {
        final path = view['page_path'] as String? ?? 'unknown';
        pageViewsByPath[path] = (pageViewsByPath[path] ?? 0) + 1;
      }

      // Group events by name
      final Map<String, int> eventsByName = {};
      for (final event in events) {
        final name = event['event_name'] as String? ?? 'unknown';
        eventsByName[name] = (eventsByName[name] ?? 0) + 1;
      }

      setState(() {
        _analyticsData = {
          'totalPageViews': pageViews.length,
          'totalEvents': events.length,
          'uniqueVisitors': _calculateUniqueVisitors(pageViews),
          'pageViewsByPath': pageViewsByPath,
          'eventsByName': eventsByName,
          'recentPageViews': pageViews.take(10).toList(),
          'recentEvents': events.take(10).toList(),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  int _calculateUniqueVisitors(List<Map<String, dynamic>> pageViews) {
    final uniqueSessions = <String>{};
    for (final view in pageViews) {
      final sessionId = view['session_id'] as String?;
      if (sessionId != null) {
        uniqueSessions.add(sessionId);
      }
    }
    return uniqueSessions.length;
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
                'Analytics Dashboard',
                style: AppStyles.heading(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: _selectedPeriod,
                items: const [
                  DropdownMenuItem(value: '7d', child: Text('Last 7 days')),
                  DropdownMenuItem(value: '30d', child: Text('Last 30 days')),
                  DropdownMenuItem(value: '90d', child: Text('Last 90 days')),
                  DropdownMenuItem(value: 'all', child: Text('All time')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPeriod = value;
                    });
                    _loadAnalytics();
                  }
                },
              ),
            ],
          ),
          AppUtils().vSpace(size: 32),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        _StatCard(
                          title: 'Total Page Views',
                          value: '${_analyticsData['totalPageViews'] ?? 0}',
                          icon: Icons.visibility,
                          color: Colors.blue,
                        ),
                        _StatCard(
                          title: 'Unique Visitors',
                          value: '${_analyticsData['uniqueVisitors'] ?? 0}',
                          icon: Icons.people,
                          color: Colors.green,
                        ),
                        _StatCard(
                          title: 'Total Events',
                          value: '${_analyticsData['totalEvents'] ?? 0}',
                          icon: Icons.event,
                          color: Colors.orange,
                        ),
                        _StatCard(
                          title: 'Avg. Views/Day',
                          value: _calculateAvgPerDay(
                            _analyticsData['totalPageViews'] ?? 0,
                          ),
                          icon: Icons.trending_up,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    AppUtils().vSpace(size: 32),
                    // Page Views Chart
                    if (_analyticsData['pageViewsByPath'] != null)
                      _PageViewsChart(
                        data:
                            _analyticsData['pageViewsByPath']
                                as Map<String, int>,
                      ),
                    AppUtils().vSpace(size: 32),
                    // Events Chart
                    if (_analyticsData['eventsByName'] != null)
                      _EventsChart(
                        data:
                            _analyticsData['eventsByName'] as Map<String, int>,
                      ),
                    AppUtils().vSpace(size: 32),
                    // Recent Activity
                    Row(
                      children: [
                        Expanded(
                          child: _RecentActivityCard(
                            title: 'Recent Page Views',
                            items:
                                _analyticsData['recentPageViews']
                                    as List<Map<String, dynamic>>? ??
                                [],
                            getLabel:
                                (item) =>
                                    item['page_path'] as String? ?? 'Unknown',
                            getSubtitle:
                                (item) =>
                                    _formatDate(item['created_at'] as String?),
                          ),
                        ),
                        AppUtils().hSpace(size: 24),
                        Expanded(
                          child: _RecentActivityCard(
                            title: 'Recent Events',
                            items:
                                _analyticsData['recentEvents']
                                    as List<Map<String, dynamic>>? ??
                                [],
                            getLabel:
                                (item) =>
                                    item['event_name'] as String? ?? 'Unknown',
                            getSubtitle:
                                (item) =>
                                    _formatDate(item['created_at'] as String?),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _calculateAvgPerDay(int total) {
    int days;
    switch (_selectedPeriod) {
      case '7d':
        days = 7;
        break;
      case '30d':
        days = 30;
        break;
      case '90d':
        days = 90;
        break;
      default:
        days = 1;
    }
    return (total / days).toStringAsFixed(1);
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return dateString;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          AppUtils().vSpace(size: 16),
          Text(
            value,
            style: AppStyles.heading(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          AppUtils().vSpace(size: 4),
          Text(title, style: AppStyles.body(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _PageViewsChart extends StatelessWidget {
  final Map<String, int> data;

  const _PageViewsChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final sortedData =
        data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Page Views by Path',
              style: AppStyles.heading(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppUtils().vSpace(size: 24),
            if (sortedData.isEmpty)
              const Center(child: Text('No data available'))
            else
              ...sortedData.take(10).map((entry) {
                final maxValue = sortedData.first.value.toDouble();
                final percentage = entry.value / maxValue;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: AppStyles.body(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text('${entry.value}', style: AppStyles.body()),
                        ],
                      ),
                      AppUtils().vSpace(size: 8),
                      LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor,
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _EventsChart extends StatelessWidget {
  final Map<String, int> data;

  const _EventsChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final sortedData =
        data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Events by Name',
              style: AppStyles.heading(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppUtils().vSpace(size: 24),
            if (sortedData.isEmpty)
              const Center(child: Text('No data available'))
            else
              ...sortedData.take(10).map((entry) {
                final maxValue = sortedData.first.value.toDouble();
                final percentage = entry.value / maxValue;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: AppStyles.body(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text('${entry.value}', style: AppStyles.body()),
                        ],
                      ),
                      AppUtils().vSpace(size: 8),
                      LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String Function(Map<String, dynamic>) getLabel;
  final String Function(Map<String, dynamic>) getSubtitle;

  const _RecentActivityCard({
    required this.title,
    required this.items,
    required this.getLabel,
    required this.getSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppStyles.heading(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppUtils().vSpace(size: 16),
            if (items.isEmpty)
              const Center(child: Text('No recent activity'))
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getLabel(item),
                        style: AppStyles.body(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        getSubtitle(item),
                        style: AppStyles.body(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
