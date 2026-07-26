import 'turso_service.dart';

class AnalyticsService {
  static Future<void> trackPageView(String path) async {
    try {
      await TursoService.insert('page_views', {
        'id': _generateId(),
        'page_path': path,
        'session_id': _getOrCreateSessionId(),
        'visited_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  static Future<void> trackVisitor({
    required String pagePath,
    String? city,
    String? country,
    String? device,
    String? browser,
    String? referrer,
  }) async {
    try {
      await TursoService.insert('visitor_logs', {
        'id': _generateId(),
        'session_id': _getOrCreateSessionId(),
        'page_path': pagePath,
        'city': city,
        'country': country,
        'device': device,
        'browser': browser,
        'referrer': referrer,
        'visited_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  static String _getOrCreateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (1000 + DateTime.now().microsecond).toString();
  }
}
