/// Resume Parser Service
/// Extracts structured data from uploaded resume PDFs
/// 
/// NOTE: PDF parsing requires a PDF text extraction package.
/// For now, this service provides the structure. To enable PDF parsing:
/// 1. Add a PDF parsing package (e.g., pdf_text, doc_text_extractor)
/// 2. Update the parseResumeFromFile and parseResumeFromBytes methods
/// 
/// Alternative: Use a server-side API (Supabase Edge Function) to parse PDFs
import 'package:flutter/foundation.dart';

/// Parsed resume data structure
class ParsedResumeData {
  // Personal Information
  String? name;
  String? email;
  String? phone;
  String? location;
  String? title;
  String? bio;

  // Work Experience
  List<ParsedExperience> experiences = [];

  // Skills
  List<String> skills = [];

  // Education
  List<ParsedEducation> education = [];

  // Social Links (extracted from text)
  Map<String, String> socialLinks = {};

  // Projects/Works (if mentioned)
  List<ParsedProject> projects = [];
}

class ParsedExperience {
  String company;
  String position;
  String? description;
  DateTime? startDate;
  DateTime? endDate;
  bool isCurrent;

  ParsedExperience({
    required this.company,
    required this.position,
    this.description,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
  });
}

class ParsedEducation {
  String institution;
  String? degree;
  String? field;
  DateTime? startDate;
  DateTime? endDate;

  ParsedEducation({
    required this.institution,
    this.degree,
    this.field,
    this.startDate,
    this.endDate,
  });
}

class ParsedProject {
  String name;
  String? description;
  List<String> technologies = [];
  String? url;

  ParsedProject({
    required this.name,
    this.description,
    this.technologies = const [],
    this.url,
  });
}

class ResumeParserService {
  /// Parse resume from file path (mobile/desktop)
  /// 
  /// TODO: Integrate PDF parsing package
  /// For now, this is a placeholder that will need PDF parsing implementation
  static Future<ParsedResumeData> parseResumeFromFile(
    String filePath,
  ) async {
    try {
      debugPrint('ResumeParserService: Starting to parse resume from $filePath');
      
      // TODO: Add PDF parsing here
      // Example with pdf_text package:
      // final doc = await PdfDoc.fromFile(filePath);
      // final text = await doc.text;
      // return _parseText(text);
      
      // For now, throw an error indicating PDF parsing is not yet implemented
      throw UnimplementedError(
        'PDF parsing not yet implemented. Please add a PDF parsing package '
        '(e.g., pdf_text, doc_text_extractor) or use a server-side API.',
      );
    } catch (e, stackTrace) {
      debugPrint('ResumeParserService: Error parsing PDF: $e');
      debugPrint('ResumeParserService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Parse resume from bytes (web)
  /// 
  /// TODO: Integrate PDF parsing package
  /// For now, this is a placeholder that will need PDF parsing implementation
  static Future<ParsedResumeData> parseResumeFromBytes(
    List<int> bytes,
  ) async {
    try {
      debugPrint('ResumeParserService: Starting to parse resume from bytes (${bytes.length} bytes)');
      
      // TODO: Add PDF parsing here
      // Example with pdf_text package:
      // final doc = await PdfDoc.fromData(bytes);
      // final text = await doc.text;
      // return _parseText(text);
      
      // For now, throw an error indicating PDF parsing is not yet implemented
      throw UnimplementedError(
        'PDF parsing not yet implemented. Please add a PDF parsing package '
        '(e.g., pdf_text, doc_text_extractor) or use a server-side API.',
      );
    } catch (e, stackTrace) {
      debugPrint('ResumeParserService: Error parsing PDF: $e');
      debugPrint('ResumeParserService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Parse text content and extract structured data
  static ParsedResumeData _parseText(String text) {
    final data = ParsedResumeData();
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    // Extract personal information
    data.name = _extractName(lines);
    data.email = _extractEmail(text);
    data.phone = _extractPhone(text);
    data.location = _extractLocation(lines);
    data.title = _extractTitle(lines);
    data.bio = _extractBio(lines);

    // Extract work experience
    data.experiences = _extractExperiences(text, lines);

    // Extract skills
    data.skills = _extractSkills(text, lines);

    // Extract education
    data.education = _extractEducation(text, lines);

    // Extract social links
    data.socialLinks = _extractSocialLinks(text);

    // Extract projects
    data.projects = _extractProjects(text, lines);

    debugPrint('ResumeParserService: Parsed data - Name: ${data.name}, Email: ${data.email}, Experiences: ${data.experiences.length}');
    return data;
  }

  /// Extract name (usually first line or after "Name:")
  static String? _extractName(List<String> lines) {
    if (lines.isEmpty) return null;

    // Check for "Name:" pattern
    for (final line in lines.take(5)) {
      if (line.toLowerCase().contains('name:')) {
        return line.split(':').last.trim();
      }
    }

    // First non-empty line is often the name
    final firstLine = lines.first;
    if (firstLine.length > 2 && firstLine.length < 50 && !firstLine.contains('@')) {
      return firstLine;
    }

    return null;
  }

  /// Extract email address
  static String? _extractEmail(String text) {
    final emailRegex = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
    final match = emailRegex.firstMatch(text);
    return match?.group(0);
  }

  /// Extract phone number
  static String? _extractPhone(String text) {
    final phoneRegex = RegExp(
      r'(\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}|\+\d{10,15}',
    );
    final match = phoneRegex.firstMatch(text);
    return match?.group(0);
  }

  /// Extract location
  static String? _extractLocation(List<String> lines) {
    final locationKeywords = ['location', 'address', 'city', 'based in', 'residing'];
    for (final line in lines.take(20)) {
      final lower = line.toLowerCase();
      for (final keyword in locationKeywords) {
        if (lower.contains(keyword)) {
          final parts = line.split(':');
          if (parts.length > 1) {
            return parts.last.trim();
          }
          return line.replaceAll(RegExp(keyword, caseSensitive: false), '').trim();
        }
      }
    }
    return null;
  }

  /// Extract job title
  static String? _extractTitle(List<String> lines) {
    final titleKeywords = ['title', 'position', 'role', 'job title'];
    for (final line in lines.take(10)) {
      final lower = line.toLowerCase();
      for (final keyword in titleKeywords) {
        if (lower.contains(keyword)) {
          final parts = line.split(':');
          if (parts.length > 1) {
            return parts.last.trim();
          }
        }
      }
    }

    // Check second or third line (often contains title)
    if (lines.length > 1) {
      final secondLine = lines[1];
      if (secondLine.length < 60 && !secondLine.contains('@')) {
        return secondLine;
      }
    }

    return null;
  }

  /// Extract bio/summary
  static String? _extractBio(List<String> lines) {
    final bioKeywords = ['summary', 'about', 'profile', 'objective', 'overview'];
    int? startIndex;

    for (int i = 0; i < lines.length && i < 20; i++) {
      final lower = lines[i].toLowerCase();
      for (final keyword in bioKeywords) {
        if (lower.contains(keyword)) {
          startIndex = i;
          break;
        }
      }
      if (startIndex != null) break;
    }

    if (startIndex != null && startIndex < lines.length - 1) {
      final bioLines = <String>[];
      for (int i = startIndex + 1; i < lines.length && i < startIndex + 5; i++) {
        if (lines[i].length > 20) {
          bioLines.add(lines[i]);
        } else {
          break;
        }
      }
      if (bioLines.isNotEmpty) {
        return bioLines.join(' ');
      }
    }

    return null;
  }

  /// Extract work experience
  static List<ParsedExperience> _extractExperiences(
    String text,
    List<String> lines,
  ) {
    final experiences = <ParsedExperience>[];
    final experienceKeywords = ['experience', 'employment', 'work history', 'career'];
    int? startIndex;

    // Find experience section
    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();
      for (final keyword in experienceKeywords) {
        if (lower.contains(keyword)) {
          startIndex = i;
          break;
        }
      }
      if (startIndex != null) break;
    }

    if (startIndex == null) return experiences;

    // Parse experiences (look for company names and positions)
    for (int i = startIndex + 1; i < lines.length && i < startIndex + 50; i++) {
      final line = lines[i];
      if (line.isEmpty) continue;

      // Check if this looks like a company/position line
      if (line.length > 5 && line.length < 80 && !line.contains('@')) {
        // Try to extract dates
        final datePattern = RegExp(
          r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4}|\d{4}[/-]\d{1,2}[/-]\d{1,2}|(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{4})',
          caseSensitive: false,
        );
        final dates = datePattern.allMatches(line);

        if (dates.isNotEmpty || line.contains('–') || line.contains('-')) {
          // This might be a position line
          final parts = line.split(RegExp(r'[–-]|to|present|current', caseSensitive: false));
          if (parts.length >= 2) {
            final companyPosition = parts[0].trim();
            final positionParts = companyPosition.split(RegExp(r'[|•]'));

            if (positionParts.length >= 2) {
              experiences.add(ParsedExperience(
                company: positionParts[0].trim(),
                position: positionParts[1].trim(),
                isCurrent: line.toLowerCase().contains('present') ||
                    line.toLowerCase().contains('current'),
              ));
            } else if (positionParts.length == 1) {
              // Try to split by common separators
              final split = companyPosition.split(RegExp(r'at|@'));
              if (split.length >= 2) {
                experiences.add(ParsedExperience(
                  company: split[1].trim(),
                  position: split[0].trim(),
                  isCurrent: line.toLowerCase().contains('present') ||
                      line.toLowerCase().contains('current'),
                ));
              }
            }
          }
        }
      }
    }

    return experiences;
  }

  /// Extract skills
  static List<String> _extractSkills(String text, List<String> lines) {
    final skills = <String>[];
    final skillKeywords = ['skills', 'technical skills', 'competencies', 'expertise'];
    int? startIndex;

    // Find skills section
    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();
      for (final keyword in skillKeywords) {
        if (lower.contains(keyword)) {
          startIndex = i;
          break;
        }
      }
      if (startIndex != null) break;
    }

    if (startIndex == null) return skills;

    // Common skills/technologies to look for
    final commonSkills = [
      'Flutter', 'Dart', 'React', 'JavaScript', 'TypeScript', 'Python', 'Java',
      'Node.js', 'Express', 'MongoDB', 'PostgreSQL', 'MySQL', 'Firebase',
      'Supabase', 'AWS', 'Docker', 'Kubernetes', 'Git', 'Figma', 'Adobe XD',
      'UI/UX', 'HTML', 'CSS', 'SASS', 'Vue', 'Angular', 'Swift', 'Kotlin',
    ];

    // Extract skills from text
    final lowerText = text.toLowerCase();
    for (final skill in commonSkills) {
      if (lowerText.contains(skill.toLowerCase())) {
        skills.add(skill);
      }
    }

    // Also look for comma-separated skills
    if (startIndex < lines.length - 1) {
      for (int i = startIndex + 1; i < lines.length && i < startIndex + 10; i++) {
        final line = lines[i];
        if (line.contains(',') && line.length < 200) {
          final lineSkills = line.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty && s.length < 30).toList();
          skills.addAll(lineSkills);
        }
      }
    }

    return skills.toSet().toList(); // Remove duplicates
  }

  /// Extract education
  static List<ParsedEducation> _extractEducation(
    String text,
    List<String> lines,
  ) {
    final education = <ParsedEducation>[];
    final educationKeywords = ['education', 'academic', 'qualification', 'degree'];
    int? startIndex;

    // Find education section
    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();
      for (final keyword in educationKeywords) {
        if (lower.contains(keyword)) {
          startIndex = i;
          break;
        }
      }
      if (startIndex != null) break;
    }

    if (startIndex == null) return education;

    // Look for degree patterns
    final degreePattern = RegExp(
      r'(Bachelor|Master|PhD|B\.?S\.?|M\.?S\.?|B\.?A\.?|M\.?A\.?|Diploma)',
      caseSensitive: false,
    );

    for (int i = startIndex + 1; i < lines.length && i < startIndex + 20; i++) {
      final line = lines[i];
      if (degreePattern.hasMatch(line)) {
        final match = degreePattern.firstMatch(line);
        education.add(ParsedEducation(
          institution: line.replaceAll(degreePattern, '').trim(),
          degree: match?.group(0),
        ));
      }
    }

    return education;
  }

  /// Extract social links
  static Map<String, String> _extractSocialLinks(String text) {
    final links = <String, String>{};

    // URL patterns
    final urlPattern = RegExp(
      r'https?://(?:www\.)?(linkedin\.com|github\.com|twitter\.com|x\.com|facebook\.com|instagram\.com|behance\.net|dribbble\.com)/[\w/.-]+',
      caseSensitive: false,
    );

    final matches = urlPattern.allMatches(text);
    for (final match in matches) {
      final url = match.group(0)!;
      final domain = match.group(1)!.toLowerCase();

      String platform;
      if (domain.contains('linkedin')) {
        platform = 'linkedin';
      } else if (domain.contains('github')) {
        platform = 'github';
      } else if (domain.contains('twitter') || domain.contains('x.com')) {
        platform = 'twitter';
      } else if (domain.contains('facebook')) {
        platform = 'facebook';
      } else if (domain.contains('instagram')) {
        platform = 'instagram';
      } else if (domain.contains('behance')) {
        platform = 'behance';
      } else if (domain.contains('dribbble')) {
        platform = 'dribbble';
      } else {
        continue;
      }

      links[platform] = url;
    }

    return links;
  }

  /// Extract projects
  static List<ParsedProject> _extractProjects(String text, List<String> lines) {
    final projects = <ParsedProject>[];
    final projectKeywords = ['projects', 'portfolio', 'work samples'];
    int? startIndex;

    // Find projects section
    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();
      for (final keyword in projectKeywords) {
        if (lower.contains(keyword)) {
          startIndex = i;
          break;
        }
      }
      if (startIndex != null) break;
    }

    if (startIndex == null) return projects;

    // Look for project names (lines that might be project titles)
    for (int i = startIndex + 1; i < lines.length && i < startIndex + 30; i++) {
      final line = lines[i];
      if (line.length > 5 && line.length < 60 && !line.contains('@') && !line.contains('http')) {
        // Might be a project name
        projects.add(ParsedProject(name: line));
      }
    }

    return projects;
  }
}

