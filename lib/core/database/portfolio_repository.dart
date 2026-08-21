import 'dart:convert';
import '../services/turso_service.dart';
import '../config/app_config.dart';
import 'db_setup.dart';
import '../../data/profile_data.dart';
import '../../data/projects_data.dart';
import '../../data/experience_data.dart';
import '../../data/testimonials_data.dart';
import '../../data/blog_data.dart';
import '../../data/social_data.dart';

class PortfolioRepository {
  static final PortfolioRepository _instance = PortfolioRepository._();
  factory PortfolioRepository() => _instance;
  PortfolioRepository._();

  bool _initialized = false;
  bool _usesDb = false;

  Map<String, dynamic> _profile = {};
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _testimonials = [];
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _experience = [];
  List<Map<String, dynamic>> _education = [];
  List<Map<String, dynamic>> _certifications = [];
  List<Map<String, dynamic>> _skills = [];
  List<Map<String, dynamic>> _languages = [];
  List<Map<String, dynamic>> _contactSubmissions = [];
  List<Map<String, dynamic>> _subscribers = [];
  List<Map<String, dynamic>> _analyticsEvents = [];
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _socialLinks = [];

  bool get isInitialized => _initialized;
  bool get usesDatabase => _usesDb;

  Map<String, dynamic> get profile => _profile;
  List<Map<String, dynamic>> get projects => _projects;
  List<Map<String, dynamic>> get testimonials => _testimonials;
  List<Map<String, dynamic>> get services => _services;
  List<Map<String, dynamic>> get experience => _experience;
  List<Map<String, dynamic>> get education => _education;
  List<Map<String, dynamic>> get certifications => _certifications;
  List<Map<String, dynamic>> get skills => _skills;
  List<Map<String, dynamic>> get languages => _languages;
  List<Map<String, dynamic>> get contactSubmissions => _contactSubmissions;
  List<Map<String, dynamic>> get subscribers => _subscribers;
  List<Map<String, dynamic>> get analyticsEvents => _analyticsEvents;
  List<Map<String, dynamic>> get posts => _posts;
  List<Map<String, dynamic>> get socialLinks => _socialLinks;

  List<Map<String, dynamic>> get featuredProjects =>
      _projects.where((p) => p['is_featured'] == 1 || p['is_featured'] == true).toList();

  List<String> get skillCategories {
    final cats = _skills.map((s) => s['category']?.toString() ?? '').toSet().toList();
    cats.sort();
    return cats;
  }

  List<Map<String, dynamic>> skillsForCategory(String category) =>
      _skills.where((s) => s['category'] == category).toList();

  // ── Init ──────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    // Always load fallback data first as a baseline.
    // On web, dotenv is unavailable so DB queries silently fail and
    // _loadFallbackData() inside catch never fires. Loading first
    // guarantees every section has data regardless of DB status.
    _loadFallbackData();

    try {
      await TursoService.initialize();
      await _createTables();

      final isEmpty = await _isProfileEmpty();
      if (isEmpty) {
        await DbSetup.seedAll();
      }
      await _loadAllFromDb();
      _usesDb = true;
    } catch (_) {
      _usesDb = false;
    }

    _initialized = true;
  }

  Future<void> _createTables() async {
    final schemas = [
      "CREATE TABLE IF NOT EXISTS profile (id TEXT PRIMARY KEY DEFAULT 'main', name TEXT NOT NULL DEFAULT '', title TEXT NOT NULL DEFAULT '', subtitle TEXT NOT NULL DEFAULT '', location TEXT NOT NULL DEFAULT '', email TEXT NOT NULL DEFAULT '', phone TEXT NOT NULL DEFAULT '', bio TEXT DEFAULT '', about TEXT DEFAULT '', quote TEXT DEFAULT '', avatar_url TEXT DEFAULT '', resume_url TEXT DEFAULT '', linkedin_url TEXT DEFAULT '', github_url TEXT DEFAULT '', buy_me_a_coffee_url TEXT DEFAULT '', calcom_username TEXT DEFAULT '', stats TEXT DEFAULT '[]', tech_stack TEXT DEFAULT '[]', updated_at TEXT DEFAULT (datetime('now')))",
      "CREATE TABLE IF NOT EXISTS projects (id TEXT PRIMARY KEY, title TEXT NOT NULL, category TEXT NOT NULL DEFAULT 'Mobile', description TEXT NOT NULL DEFAULT '', client TEXT DEFAULT '', year TEXT DEFAULT '', role TEXT DEFAULT '', technologies TEXT DEFAULT '[]', challenge TEXT DEFAULT '', solution TEXT DEFAULT '', tags TEXT DEFAULT '[]', is_featured INTEGER DEFAULT 1, display_order INTEGER DEFAULT 0, icon_url TEXT DEFAULT '', screenshots TEXT DEFAULT '[]', ios_url TEXT DEFAULT '', android_url TEXT DEFAULT '', web_url TEXT DEFAULT '', created_at TEXT DEFAULT (datetime('now')))",
      "CREATE TABLE IF NOT EXISTS experience (id TEXT PRIMARY KEY, company TEXT NOT NULL, position TEXT NOT NULL, start_date TEXT DEFAULT '', end_date TEXT DEFAULT '', location TEXT DEFAULT '', highlights TEXT DEFAULT '[]', display_order INTEGER DEFAULT 0, created_at TEXT DEFAULT (datetime('now')))",
      "CREATE TABLE IF NOT EXISTS education (id TEXT PRIMARY KEY, degree TEXT NOT NULL, institution TEXT NOT NULL, period TEXT DEFAULT '', details TEXT DEFAULT '', display_order INTEGER DEFAULT 0, created_at TEXT DEFAULT (datetime('now')))",
      "CREATE TABLE IF NOT EXISTS certifications (id TEXT PRIMARY KEY, name TEXT NOT NULL, issuer TEXT DEFAULT '', date TEXT DEFAULT '', url TEXT DEFAULT '', display_order INTEGER DEFAULT 0, created_at TEXT DEFAULT (datetime('now')))",
      "CREATE TABLE IF NOT EXISTS skills (id TEXT PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL DEFAULT 'General', level TEXT DEFAULT '', display_order INTEGER DEFAULT 0, created_at TEXT DEFAULT (datetime('now')))",
      "CREATE TABLE IF NOT EXISTS languages (id TEXT PRIMARY KEY, name TEXT NOT NULL, proficiency TEXT DEFAULT '', display_order INTEGER DEFAULT 0, created_at TEXT DEFAULT (datetime('now')))",
      "CREATE TABLE IF NOT EXISTS testimonials (id TEXT PRIMARY KEY, quote TEXT NOT NULL, client_name TEXT NOT NULL, client_company TEXT DEFAULT '', client_role TEXT DEFAULT '', avatar_url TEXT DEFAULT '', display_order INTEGER DEFAULT 0, created_at TEXT DEFAULT (datetime('now')))",
      "CREATE TABLE IF NOT EXISTS services (id TEXT PRIMARY KEY, title TEXT NOT NULL, description TEXT NOT NULL DEFAULT '', icon_codepoint INTEGER DEFAULT 0, features TEXT DEFAULT '[]', display_order INTEGER DEFAULT 0, created_at TEXT DEFAULT (datetime('now')))",
      "CREATE TABLE IF NOT EXISTS contact_submissions (id TEXT PRIMARY KEY, name TEXT NOT NULL, email TEXT NOT NULL, message TEXT NOT NULL, submitted_at TEXT DEFAULT (datetime('now')), status TEXT DEFAULT 'unread')",
      "CREATE TABLE IF NOT EXISTS newsletter_subscribers (id TEXT PRIMARY KEY, email TEXT NOT NULL, name TEXT DEFAULT '', source TEXT DEFAULT 'website', subscribed_at TEXT DEFAULT (datetime('now')), is_active INTEGER DEFAULT 1)",
      "CREATE TABLE IF NOT EXISTS analytics_events (id INTEGER PRIMARY KEY AUTOINCREMENT, event_type TEXT NOT NULL, event_data TEXT DEFAULT '{}', page TEXT DEFAULT '', visitor_id TEXT DEFAULT '', timestamp TEXT DEFAULT (datetime('now')))",
      "CREATE TABLE IF NOT EXISTS posts (id TEXT PRIMARY KEY, title TEXT NOT NULL, slug TEXT NOT NULL DEFAULT '', excerpt TEXT DEFAULT '', category TEXT DEFAULT '', read_time TEXT DEFAULT '', published_at TEXT DEFAULT '', tags TEXT DEFAULT '[]', display_order INTEGER DEFAULT 0, created_at TEXT DEFAULT (datetime('now')))",
      "CREATE TABLE IF NOT EXISTS social_links (id TEXT PRIMARY KEY, platform TEXT NOT NULL, url TEXT NOT NULL DEFAULT '', icon TEXT DEFAULT '', display_order INTEGER DEFAULT 0, created_at TEXT DEFAULT (datetime('now')))",
    ];
    for (final sql in schemas) {
      try { await TursoService.query(sql); } catch (_) {}
    }
  }

  Future<bool> _isProfileEmpty() async {
    try {
      final result = await TursoService.query("SELECT COUNT(*) as count FROM profile WHERE id = 'main'");
      if (result.isEmpty) return true;
      return result.first['count'] == 0;
    } catch (_) {
      return true;
    }
  }

  void _loadFallbackData() {
    _profile = {
      'id': 'main',
      'name': AppProfileData.name,
      'title': AppProfileData.title,
      'subtitle': AppProfileData.subtitle,
      'location': AppProfileData.location,
      'email': AppProfileData.email,
      'phone': AppProfileData.phone,
      'bio': AppProfileData.bio,
      'about': AppProfileData.about,
      'quote': AppProfileData.quote,
      'avatar_url': 'https://hasan-abbas-portfolio.web.app/images/profile.png',
      'resume_url': AppConfig.resumeUrl,
      'linkedin_url': AppConfig.linkedInUrl,
      'github_url': '',
      'buy_me_a_coffee_url': AppConfig.buyMeACoffeeUrl,
      'calcom_username': AppConfig.calComUsername,
      'stats': jsonEncode(AppProfileData.stats),
      'tech_stack': jsonEncode(AppProfileData.techStack),
    };
    _projects = List.from(AppProjectsData.featuredProjects);
    _experience = AppExperienceData.experiences.map((e) {
      return {
        'id': e['company'].toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
        'company': e['company'],
        'position': e['position'],
        'start_date': e['startDate'],
        'end_date': e['endDate'],
        'location': e['location'],
        'highlights': e['highlights'] is String ? e['highlights'] : jsonEncode(e['highlights']),
      };
    }).toList();

    _education = [
      {'id': 'edu_mca', 'degree': 'Master of Computer Applications (MCA)', 'institution': 'Saurashtra University', 'period': '2016 – 2019', 'details': '', 'display_order': 0},
    ];

    _certifications = [
      {'id': 'cert_gad', 'name': 'Google Associate Android Developer', 'issuer': 'Google', 'date': '', 'url': '', 'display_order': 0},
      {'id': 'cert_flutter', 'name': 'Flutter Development Specialization', 'issuer': 'Google / Udacity', 'date': '', 'url': '', 'display_order': 1},
      {'id': 'cert_aws', 'name': 'AWS Cloud Practitioner', 'issuer': 'Amazon Web Services', 'date': '', 'url': '', 'display_order': 2},
    ];

    _skills = [
      {'id': 'sk_flutter', 'name': 'Flutter', 'category': 'Mobile & Cross-Platform', 'level': 'Expert', 'display_order': 0},
      {'id': 'sk_dart', 'name': 'Dart', 'category': 'Mobile & Cross-Platform', 'level': 'Expert', 'display_order': 1},
      {'id': 'sk_android', 'name': 'Android', 'category': 'Mobile & Cross-Platform', 'level': 'Advanced', 'display_order': 2},
      {'id': 'sk_ios', 'name': 'iOS', 'category': 'Mobile & Cross-Platform', 'level': 'Advanced', 'display_order': 3},
      {'id': 'sk_clean', 'name': 'Clean Architecture', 'category': 'Architecture & Patterns', 'level': 'Expert', 'display_order': 4},
      {'id': 'sk_solid', 'name': 'SOLID', 'category': 'Architecture & Patterns', 'level': 'Expert', 'display_order': 5},
      {'id': 'sk_bloc', 'name': 'BLoC', 'category': 'Architecture & Patterns', 'level': 'Advanced', 'display_order': 6},
      {'id': 'sk_riverpod', 'name': 'Riverpod', 'category': 'Architecture & Patterns', 'level': 'Advanced', 'display_order': 7},
      {'id': 'sk_mvvm', 'name': 'MVVM', 'category': 'Architecture & Patterns', 'level': 'Advanced', 'display_order': 8},
      {'id': 'sk_rest', 'name': 'REST APIs', 'category': 'Backend & APIs', 'level': 'Advanced', 'display_order': 9},
      {'id': 'sk_firebase', 'name': 'Firebase', 'category': 'Backend & APIs', 'level': 'Advanced', 'display_order': 10},
      {'id': 'sk_supabase', 'name': 'Supabase', 'category': 'Backend & APIs', 'level': 'Intermediate', 'display_order': 11},
      {'id': 'sk_node', 'name': 'Node.js', 'category': 'Backend & APIs', 'level': 'Intermediate', 'display_order': 12},
      {'id': 'sk_python', 'name': 'Python', 'category': 'Backend & APIs', 'level': 'Intermediate', 'display_order': 13},
      {'id': 'sk_cicd', 'name': 'CI/CD', 'category': 'DevOps & Tools', 'level': 'Advanced', 'display_order': 14},
      {'id': 'sk_codemagic', 'name': 'Codemagic', 'category': 'DevOps & Tools', 'level': 'Advanced', 'display_order': 15},
      {'id': 'sk_github_actions', 'name': 'GitHub Actions', 'category': 'DevOps & Tools', 'level': 'Advanced', 'display_order': 16},
      {'id': 'sk_git', 'name': 'Git', 'category': 'DevOps & Tools', 'level': 'Expert', 'display_order': 17},
      {'id': 'sk_docker', 'name': 'Docker', 'category': 'DevOps & Tools', 'level': 'Intermediate', 'display_order': 18},
      {'id': 'sk_fastlane', 'name': 'Fastlane', 'category': 'DevOps & Tools', 'level': 'Intermediate', 'display_order': 19},
      {'id': 'sk_provider', 'name': 'Provider', 'category': 'State & Data', 'level': 'Expert', 'display_order': 20},
      {'id': 'sk_hive', 'name': 'Hive', 'category': 'State & Data', 'level': 'Intermediate', 'display_order': 21},
      {'id': 'sk_sqlite', 'name': 'SQLite', 'category': 'State & Data', 'level': 'Advanced', 'display_order': 22},
      {'id': 'sk_sharedpref', 'name': 'SharedPreferences', 'category': 'State & Data', 'level': 'Advanced', 'display_order': 23},
      {'id': 'sk_material', 'name': 'Material Design 3', 'category': 'UI & Design', 'level': 'Expert', 'display_order': 24},
      {'id': 'sk_animations', 'name': 'Custom Animations', 'category': 'UI & Design', 'level': 'Advanced', 'display_order': 25},
      {'id': 'sk_responsive', 'name': 'Responsive Design', 'category': 'UI & Design', 'level': 'Advanced', 'display_order': 26},
    ];

    _languages = [
      {'id': 'lang_en', 'name': 'English', 'proficiency': 'Professional', 'display_order': 0},
      {'id': 'lang_hi', 'name': 'Hindi', 'proficiency': 'Native', 'display_order': 1},
      {'id': 'lang_gu', 'name': 'Gujarati', 'proficiency': 'Native', 'display_order': 2},
    ];

    _testimonials = AppTestimonialsData.testimonials.map((t) {
      return {
        'id': t['id'],
        'quote': t['quote'],
        'client_name': t['clientName'],
        'client_company': t['clientCompany'],
        'client_role': t['clientRole'],
        'avatar_url': '',
        'display_order': 0,
      };
    }).toList();

    _services = [
      {'id': 'svc_mobile', 'title': 'Mobile App Development', 'description': 'Cross-platform mobile applications with Flutter, from concept to App Store deployment.', 'icon_codepoint': 59530, 'features': jsonEncode(['Flutter & Dart', 'iOS & Android', 'App Store Deployment']), 'display_order': 0},
      {'id': 'svc_web', 'title': 'Web Application Development', 'description': 'Modern, responsive web applications with Flutter Web and full-stack capabilities.', 'icon_codepoint': 59526, 'features': jsonEncode(['Flutter Web', 'Responsive Design', 'Full-Stack']), 'display_order': 1},
      {'id': 'svc_ai', 'title': 'AI & Agentic App Development', 'description': 'AI-powered applications with LLM integration, intelligent automation, and agentic workflows.', 'icon_codepoint': 59601, 'features': jsonEncode(['LLM Integration', 'Agentic Workflows', 'Intelligent Automation']), 'display_order': 2},
      {'id': 'svc_fintech', 'title': 'FinTech Solutions', 'description': 'Secure financial applications, payment workflows, lending platforms, and transaction systems.', 'icon_codepoint': 59484, 'features': jsonEncode(['Payment Systems', 'Lending Platforms', 'Security']), 'display_order': 3},
      {'id': 'svc_custom', 'title': 'Custom Solutions', 'description': 'Enterprise-grade custom software, APIs, cloud architecture, and scalable systems.', 'icon_codepoint': 59536, 'features': jsonEncode(['Enterprise', 'Cloud Architecture', 'Scalable Systems']), 'display_order': 4},
      {'id': 'svc_consulting', 'title': 'Consulting & Architecture', 'description': 'Technical leadership, Clean Architecture adoption, team mentoring, and code review.', 'icon_codepoint': 59461, 'features': jsonEncode(['Architecture Review', 'Team Mentoring', 'Code Review']), 'display_order': 5},
    ];

    _posts = AppBlogData.posts.asMap().entries.map((entry) {
      final p = entry.value;
      return {
        'id': 'post_${p['id']}',
        'title': p['title'],
        'slug': p['slug'],
        'excerpt': p['excerpt'],
        'category': p['category'],
        'read_time': p['readTime'],
        'published_at': p['publishedAt'],
        'tags': jsonEncode(p['tags']),
        'display_order': entry.key,
      };
    }).toList();

    _socialLinks = AppSocialData.links.asMap().entries.map((entry) {
      final s = entry.value;
      return {
        'id': 'social_${s['icon']}',
        'platform': s['platform'],
        'url': s['url'],
        'icon': s['icon'],
        'display_order': entry.key,
      };
    }).toList();
  }

  Future<void> _loadAllFromDb() async {
    try { final r = await TursoService.query("SELECT * FROM profile WHERE id = 'main' LIMIT 1"); if (r.isNotEmpty) _profile = _parseRow(r.first); } catch (_) {}
    try { final r = await TursoService.query("SELECT * FROM projects ORDER BY display_order ASC"); if (r.isNotEmpty) _projects = r.map((e) => _parseRow(e)).toList(); } catch (_) {}
    try { final r = await TursoService.query("SELECT * FROM experience ORDER BY display_order ASC"); if (r.isNotEmpty) _experience = r.map((e) => _parseRow(e)).toList(); } catch (_) {}
    try { final r = await TursoService.query("SELECT * FROM education ORDER BY display_order ASC"); if (r.isNotEmpty) _education = r.map((e) => _parseRow(e)).toList(); } catch (_) {}
    try { final r = await TursoService.query("SELECT * FROM certifications ORDER BY display_order ASC"); if (r.isNotEmpty) _certifications = r.map((e) => _parseRow(e)).toList(); } catch (_) {}
    try { final r = await TursoService.query("SELECT * FROM skills ORDER BY display_order ASC"); if (r.isNotEmpty) _skills = r.map((e) => _parseRow(e)).toList(); } catch (_) {}
    try { final r = await TursoService.query("SELECT * FROM languages ORDER BY display_order ASC"); if (r.isNotEmpty) _languages = r.map((e) => _parseRow(e)).toList(); } catch (_) {}
    try { final r = await TursoService.query("SELECT * FROM testimonials ORDER BY display_order ASC"); if (r.isNotEmpty) _testimonials = r.map((e) => _parseRow(e)).toList(); } catch (_) {}
    try { final r = await TursoService.query("SELECT * FROM services ORDER BY display_order ASC"); if (r.isNotEmpty) _services = r.map((e) => _parseRow(e)).toList(); } catch (_) {}
    try { final r = await TursoService.query("SELECT * FROM contact_submissions ORDER BY submitted_at DESC"); if (r.isNotEmpty) _contactSubmissions = r.map((e) => _parseRow(e)).toList(); } catch (_) {}
    try { final r = await TursoService.query("SELECT * FROM newsletter_subscribers ORDER BY subscribed_at DESC"); if (r.isNotEmpty) _subscribers = r.map((e) => _parseRow(e)).toList(); } catch (_) {}
    try { final r = await TursoService.query("SELECT * FROM posts ORDER BY display_order ASC"); if (r.isNotEmpty) _posts = r.map((e) => _parseRow(e)).toList(); } catch (_) {}
    try { final r = await TursoService.query("SELECT * FROM social_links ORDER BY display_order ASC"); if (r.isNotEmpty) _socialLinks = r.map((e) => _parseRow(e)).toList(); } catch (_) {}
  }

  Map<String, dynamic> _parseRow(Map<String, dynamic> row) {
    final parsed = Map<String, dynamic>.from(row);
    for (final field in ['stats', 'tech_stack', 'technologies', 'tags', 'screenshots', 'features', 'highlights', 'event_data']) {
      if (parsed[field] is String) {
        try { parsed[field] = jsonDecode(parsed[field] as String); } catch (_) {}
      }
    }
    if (parsed['is_featured'] != null) {
      parsed['is_featured'] = parsed['is_featured'] == 1 || parsed['is_featured'] == true ? 1 : 0;
    }
    return parsed;
  }

  Future<void> refresh() async {
    if (_usesDb) await _loadAllFromDb();
  }

  // ── Profile CRUD ──────────────────────────────────────────────

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final toUpdate = Map<String, dynamic>.from(data);
    toUpdate.remove('id');
    if (toUpdate['stats'] is List) toUpdate['stats'] = jsonEncode(toUpdate['stats']);
    if (toUpdate['tech_stack'] is List) toUpdate['tech_stack'] = jsonEncode(toUpdate['tech_stack']);
    if (_usesDb) await TursoService.update('profile', toUpdate, where: "id = 'main'");
    _profile.addAll(toUpdate);
  }

  // ── Generic CRUD Helper ───────────────────────────────────────

  Future<void> _saveEntity(String table, List<Map<String, dynamic>> list, Map<String, dynamic> entity, {List<String> jsonFields = const []}) async {
    final e = Map<String, dynamic>.from(entity);
    for (final f in jsonFields) {
      if (e[f] is List) e[f] = jsonEncode(e[f]);
    }
    if (_usesDb) {
      final existing = await TursoService.query("SELECT id FROM $table WHERE id = '${e['id']}'");
      if (existing.isNotEmpty) {
        final toUpdate = Map<String, dynamic>.from(e);
        toUpdate.remove('id');
        toUpdate.remove('created_at');
        await TursoService.update(table, toUpdate, where: "id = '${e['id']}'");
      } else {
        await TursoService.insert(table, e);
      }
    }
    final idx = list.indexWhere((x) => x['id'] == e['id']);
    final decoded = _parseRow(e);
    if (idx >= 0) { list[idx] = decoded; } else { list.add(decoded); }
  }

  Future<void> _deleteEntity(String table, List<Map<String, dynamic>> list, String id) async {
    if (_usesDb) await TursoService.delete(table, where: "id = '$id'");
    list.removeWhere((x) => x['id'] == id);
  }

  // ── Projects CRUD ─────────────────────────────────────────────
  Future<void> saveProject(Map<String, dynamic> p) async =>
      _saveEntity('projects', _projects, p, jsonFields: ['technologies', 'tags', 'screenshots']);
  Future<void> deleteProject(String id) async => _deleteEntity('projects', _projects, id);

  // ── Experience CRUD ───────────────────────────────────────────
  Future<void> saveExperience(Map<String, dynamic> e) async =>
      _saveEntity('experience', _experience, e, jsonFields: ['highlights']);
  Future<void> deleteExperience(String id) async => _deleteEntity('experience', _experience, id);

  // ── Education CRUD ────────────────────────────────────────────
  Future<void> saveEducation(Map<String, dynamic> e) async =>
      _saveEntity('education', _education, e);
  Future<void> deleteEducation(String id) async => _deleteEntity('education', _education, id);

  // ── Certifications CRUD ───────────────────────────────────────
  Future<void> saveCertification(Map<String, dynamic> c) async =>
      _saveEntity('certifications', _certifications, c);
  Future<void> deleteCertification(String id) async => _deleteEntity('certifications', _certifications, id);

  // ── Skills CRUD ───────────────────────────────────────────────
  Future<void> saveSkill(Map<String, dynamic> s) async =>
      _saveEntity('skills', _skills, s);
  Future<void> deleteSkill(String id) async => _deleteEntity('skills', _skills, id);

  // ── Languages CRUD ────────────────────────────────────────────
  Future<void> saveLanguage(Map<String, dynamic> l) async =>
      _saveEntity('languages', _languages, l);
  Future<void> deleteLanguage(String id) async => _deleteEntity('languages', _languages, id);

  // ── Testimonials CRUD ─────────────────────────────────────────
  Future<void> saveTestimonial(Map<String, dynamic> t) async =>
      _saveEntity('testimonials', _testimonials, t);
  Future<void> deleteTestimonial(String id) async => _deleteEntity('testimonials', _testimonials, id);

  // ── Services CRUD ─────────────────────────────────────────────
  Future<void> saveService(Map<String, dynamic> s) async =>
      _saveEntity('services', _services, s, jsonFields: ['features']);
  Future<void> deleteService(String id) async => _deleteEntity('services', _services, id);

  // ── Blog Posts CRUD ───────────────────────────────────────────
  Future<void> savePost(Map<String, dynamic> p) async =>
      _saveEntity('posts', _posts, p, jsonFields: ['tags']);
  Future<void> deletePost(String id) async => _deleteEntity('posts', _posts, id);

  // ── Social Links CRUD ─────────────────────────────────────────
  Future<void> saveSocialLink(Map<String, dynamic> s) async =>
      _saveEntity('social_links', _socialLinks, s);
  Future<void> deleteSocialLink(String id) async => _deleteEntity('social_links', _socialLinks, id);

  // ── Contact & Newsletter ──────────────────────────────────────
  Future<void> saveContactSubmission(Map<String, dynamic> submission) async {
    if (_usesDb) await TursoService.insert('contact_submissions', submission);
    _contactSubmissions.insert(0, submission);
  }

  Future<void> updateContactStatus(String id, String status) async {
    if (_usesDb) await TursoService.update('contact_submissions', {'status': status}, where: "id = '$id'");
    final idx = _contactSubmissions.indexWhere((c) => c['id'] == id);
    if (idx >= 0) _contactSubmissions[idx]['status'] = status;
  }

  Future<void> deleteContactSubmission(String id) async {
    if (_usesDb) await TursoService.delete('contact_submissions', where: "id = '$id'");
    _contactSubmissions.removeWhere((c) => c['id'] == id);
  }

  Future<void> saveSubscriber(Map<String, dynamic> subscriber) async {
    if (_usesDb) await TursoService.insert('newsletter_subscribers', subscriber);
    _subscribers.insert(0, subscriber);
  }

  Future<void> deleteSubscriber(String id) async {
    if (_usesDb) await TursoService.delete('newsletter_subscribers', where: "id = '$id'");
    _subscribers.removeWhere((s) => s['id'] == id);
  }

  // ── Analytics ─────────────────────────────────────────────────
  Future<void> trackEvent(String type, {String page = '', Map<String, dynamic> data = const {}}) async {
    if (_usesDb) {
      try {
        await TursoService.insert('analytics_events', {
          'event_type': type,
          'event_data': jsonEncode(data),
          'page': page,
          'visitor_id': DateTime.now().millisecondsSinceEpoch.toString(),
        });
      } catch (_) {}
    }
  }

  Future<void> trackPageView(String page) async => trackEvent('page_view', page: page);

  Future<List<Map<String, dynamic>>> getAnalyticsSummary() async {
    if (!_usesDb) return [];
    try {
      final r = await TursoService.query("""
        SELECT
          event_type,
          DATE(timestamp) as date,
          COUNT(*) as count
        FROM analytics_events
        WHERE timestamp >= datetime('now', '-30 days')
        GROUP BY event_type, DATE(timestamp)
        ORDER BY date ASC
      """);
      return r.map((r) => _parseRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, int>> getStats() async {
    final stats = <String, int>{};
    if (_usesDb) {
      try { final r = await TursoService.query("SELECT COUNT(*) as c FROM contact_submissions"); stats['contacts'] = r.isNotEmpty ? (r.first['c'] ?? 0) as int : 0; } catch (_) { stats['contacts'] = 0; }
      try { final r = await TursoService.query("SELECT COUNT(*) as c FROM newsletter_subscribers"); stats['subscribers'] = r.isNotEmpty ? (r.first['c'] ?? 0) as int : 0; } catch (_) { stats['subscribers'] = 0; }
      try { final r = await TursoService.query("SELECT COUNT(*) as c FROM analytics_events WHERE event_type = 'page_view'"); stats['views'] = r.isNotEmpty ? (r.first['c'] ?? 0) as int : 0; } catch (_) { stats['views'] = 0; }
      try { final r = await TursoService.query("SELECT COUNT(*) as c FROM projects"); stats['projects'] = r.isNotEmpty ? (r.first['c'] ?? 0) as int : 0; } catch (_) { stats['projects'] = 0; }
      try { final r = await TursoService.query("SELECT COUNT(*) as c FROM experience"); stats['experience'] = r.isNotEmpty ? (r.first['c'] ?? 0) as int : 0; } catch (_) { stats['experience'] = 0; }
      try { final r = await TursoService.query("SELECT COUNT(*) as c FROM skills"); stats['skills'] = r.isNotEmpty ? (r.first['c'] ?? 0) as int : 0; } catch (_) { stats['skills'] = 0; }
    } else {
      stats['contacts'] = _contactSubmissions.length;
      stats['subscribers'] = _subscribers.length;
      stats['views'] = 0;
      stats['projects'] = _projects.length;
      stats['experience'] = _experience.length;
      stats['skills'] = _skills.length;
    }
    return stats;
  }

  // ── Seed from defaults (first-time setup) ─────────────────────
  Future<void> seedFromDefaults() async {
    await _createTables();
    try { await TursoService.insert('profile', {'id': 'main', ..._profile}); } catch (_) {}
    for (final p in _projects) {
      try {
        final project = Map<String, dynamic>.from(p);
        if (project['technologies'] is List) project['technologies'] = jsonEncode(project['technologies']);
        if (project['tags'] is List) project['tags'] = jsonEncode(project['tags']);
        await TursoService.insert('projects', project);
      } catch (_) {}
    }
    _usesDb = true;
    await _loadAllFromDb();
  }
}
