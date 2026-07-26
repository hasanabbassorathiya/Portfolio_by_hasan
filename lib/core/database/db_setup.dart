import 'dart:convert';
import '../services/turso_service.dart';
import '../../data/profile_data.dart';
import '../../data/projects_data.dart';
import '../../data/experience_data.dart';

class DbSetup {
  static final List<String> _schemas = [
    // ── Profile ──
    '''CREATE TABLE IF NOT EXISTS profile (
      id TEXT PRIMARY KEY DEFAULT 'main',
      name TEXT NOT NULL DEFAULT '',
      title TEXT NOT NULL DEFAULT '',
      subtitle TEXT NOT NULL DEFAULT '',
      location TEXT NOT NULL DEFAULT '',
      email TEXT NOT NULL DEFAULT '',
      phone TEXT NOT NULL DEFAULT '',
      bio TEXT DEFAULT '',
      about TEXT DEFAULT '',
      quote TEXT DEFAULT '',
      avatar_url TEXT DEFAULT '',
      resume_url TEXT DEFAULT '',
      linkedin_url TEXT DEFAULT '',
      github_url TEXT DEFAULT '',
      buy_me_a_coffee_url TEXT DEFAULT '',
      calcom_username TEXT DEFAULT '',
      stats TEXT DEFAULT '[]',
      tech_stack TEXT DEFAULT '[]',
      updated_at TEXT DEFAULT (datetime('now'))
    )''',
    // ── Projects ──
    '''CREATE TABLE IF NOT EXISTS projects (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      category TEXT NOT NULL DEFAULT 'Mobile',
      description TEXT NOT NULL DEFAULT '',
      client TEXT DEFAULT '',
      year TEXT DEFAULT '',
      role TEXT DEFAULT '',
      technologies TEXT DEFAULT '[]',
      challenge TEXT DEFAULT '',
      solution TEXT DEFAULT '',
      tags TEXT DEFAULT '[]',
      is_featured INTEGER DEFAULT 1,
      display_order INTEGER DEFAULT 0,
      icon_url TEXT DEFAULT '',
      screenshots TEXT DEFAULT '[]',
      ios_url TEXT DEFAULT '',
      android_url TEXT DEFAULT '',
      web_url TEXT DEFAULT '',
      created_at TEXT DEFAULT (datetime('now'))
    )''',
    // ── Experience ──
    '''CREATE TABLE IF NOT EXISTS experience (
      id TEXT PRIMARY KEY,
      company TEXT NOT NULL,
      position TEXT NOT NULL,
      start_date TEXT DEFAULT '',
      end_date TEXT DEFAULT '',
      location TEXT DEFAULT '',
      highlights TEXT DEFAULT '[]',
      display_order INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now'))
    )''',
    // ── Education ──
    '''CREATE TABLE IF NOT EXISTS education (
      id TEXT PRIMARY KEY,
      degree TEXT NOT NULL,
      institution TEXT NOT NULL,
      period TEXT DEFAULT '',
      details TEXT DEFAULT '',
      display_order INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now'))
    )''',
    // ── Certifications ──
    '''CREATE TABLE IF NOT EXISTS certifications (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      issuer TEXT DEFAULT '',
      date TEXT DEFAULT '',
      url TEXT DEFAULT '',
      display_order INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now'))
    )''',
    // ── Skills (grouped by category) ──
    '''CREATE TABLE IF NOT EXISTS skills (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      category TEXT NOT NULL DEFAULT 'General',
      level TEXT DEFAULT '',
      display_order INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now'))
    )''',
    // ── Languages ──
    '''CREATE TABLE IF NOT EXISTS languages (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      proficiency TEXT DEFAULT '',
      display_order INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now'))
    )''',
    // ── Testimonials ──
    '''CREATE TABLE IF NOT EXISTS testimonials (
      id TEXT PRIMARY KEY,
      quote TEXT NOT NULL,
      client_name TEXT NOT NULL,
      client_company TEXT DEFAULT '',
      client_role TEXT DEFAULT '',
      avatar_url TEXT DEFAULT '',
      display_order INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now'))
    )''',
    // ── Services ──
    '''CREATE TABLE IF NOT EXISTS services (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL DEFAULT '',
      icon_codepoint INTEGER DEFAULT 0,
      features TEXT DEFAULT '[]',
      display_order INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now'))
    )''',
    // ── Contact Submissions ──
    '''CREATE TABLE IF NOT EXISTS contact_submissions (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT NOT NULL,
      message TEXT NOT NULL,
      submitted_at TEXT DEFAULT (datetime('now')),
      status TEXT DEFAULT 'unread'
    )''',
    // ── Newsletter Subscribers ──
    '''CREATE TABLE IF NOT EXISTS newsletter_subscribers (
      id TEXT PRIMARY KEY,
      email TEXT NOT NULL,
      name TEXT DEFAULT '',
      source TEXT DEFAULT 'website',
      subscribed_at TEXT DEFAULT (datetime('now')),
      is_active INTEGER DEFAULT 1
    )''',
    // ── Analytics Events ──
    '''CREATE TABLE IF NOT EXISTS analytics_events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      event_type TEXT NOT NULL,
      event_data TEXT DEFAULT '{}',
      page TEXT DEFAULT '',
      visitor_id TEXT DEFAULT '',
      timestamp TEXT DEFAULT (datetime('now'))
    )''',
  ];

  static Future<void> createAllTables() async {
    for (final sql in _schemas) {
      try {
        await TursoService.query(sql);
      } catch (_) {}
    }
  }

  static Future<bool> isDatabaseEmpty() async {
    try {
      final result = await TursoService.query(
        "SELECT COUNT(*) as count FROM profile WHERE id = 'main'",
      );
      if (result.isEmpty) return true;
      final count = result.first['count'];
      return count == 0;
    } catch (_) {
      return true;
    }
  }

  // ── Seed Profile ──
  static Future<void> seedProfile() async {
    final data = {
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
      'resume_url': 'https://flowcv.com/resume/pmesjl0q9sm9',
      'linkedin_url': 'https://linkedin.com/in/hasanabbassorathiya',
      'github_url': '',
      'buy_me_a_coffee_url': 'https://buymeacoffee.com/hasanabbassorathiya',
      'calcom_username': 'hasanabbassorathiya',
      'stats': jsonEncode(AppProfileData.stats),
      'tech_stack': jsonEncode(AppProfileData.techStack),
    };
    try {
      final existing = await TursoService.query("SELECT id FROM profile WHERE id = 'main'");
      if (existing.isEmpty) {
        await TursoService.insert('profile', data);
      }
    } catch (_) {}
  }

  // ── Seed Projects ──
  static Future<void> seedProjects() async {
    for (var i = 0; i < AppProjectsData.featuredProjects.length; i++) {
      final p = Map<String, dynamic>.from(AppProjectsData.featuredProjects[i]);
      p['display_order'] = i;
      if (p['technologies'] is List) p['technologies'] = jsonEncode(p['technologies']);
      if (p['tags'] is List) p['tags'] = jsonEncode(p['tags']);
      if (p['screenshots'] is List) p['screenshots'] = jsonEncode(p['screenshots']);
      try {
        await TursoService.insert('projects', p);
      } catch (_) {}
    }
  }

  // ── Seed Experience ──
  static Future<void> seedExperience() async {
    for (var i = 0; i < AppExperienceData.experiences.length; i++) {
      final e = Map<String, dynamic>.from(AppExperienceData.experiences[i]);
      final id = e['company'].toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
      e['id'] = id;
      e['start_date'] = e.remove('startDate') ?? '';
      e['end_date'] = e.remove('endDate') ?? '';
      e['display_order'] = i;
      if (e['highlights'] is List) e['highlights'] = jsonEncode(e['highlights']);
      try {
        await TursoService.insert('experience', e);
      } catch (_) {}
    }
  }

  // ── Seed Education ──
  static Future<void> seedEducation() async {
    final items = [
      {'id': 'edu_mca', 'degree': 'Master of Computer Applications (MCA)', 'institution': 'Saurashtra University', 'period': '2016 – 2019', 'details': '', 'display_order': 0},
    ];
    for (final item in items) {
      try {
        await TursoService.insert('education', item);
      } catch (_) {}
    }
  }

  // ── Seed Certifications ──
  static Future<void> seedCertifications() async {
    final items = [
      {'id': 'cert_gad', 'name': 'Google Associate Android Developer', 'issuer': 'Google', 'date': '', 'url': '', 'display_order': 0},
      {'id': 'cert_flutter', 'name': 'Flutter Development Specialization', 'issuer': 'Google / Udacity', 'date': '', 'url': '', 'display_order': 1},
      {'id': 'cert_aws', 'name': 'AWS Cloud Practitioner', 'issuer': 'Amazon Web Services', 'date': '', 'url': '', 'display_order': 2},
    ];
    for (final item in items) {
      try {
        await TursoService.insert('certifications', item);
      } catch (_) {}
    }
  }

  // ── Seed Skills ──
  static Future<void> seedSkills() async {
    final items = [
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
    for (final item in items) {
      try {
        await TursoService.insert('skills', item);
      } catch (_) {}
    }
  }

  // ── Seed Languages ──
  static Future<void> seedLanguages() async {
    final items = [
      {'id': 'lang_en', 'name': 'English', 'proficiency': 'Professional', 'display_order': 0},
      {'id': 'lang_hi', 'name': 'Hindi', 'proficiency': 'Native', 'display_order': 1},
      {'id': 'lang_gu', 'name': 'Gujarati', 'proficiency': 'Native', 'display_order': 2},
    ];
    for (final item in items) {
      try {
        await TursoService.insert('languages', item);
      } catch (_) {}
    }
  }

  // ── Master Seed ──
  static Future<void> seedAll() async {
    await createAllTables();
    await seedProfile();
    await seedProjects();
    await seedExperience();
    await seedEducation();
    await seedCertifications();
    await seedSkills();
    await seedLanguages();
  }
}
