/// Resume Parser API Service
/// Uses Supabase Edge Function to parse PDF resumes server-side
import 'package:flutter/foundation.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/core/services/resume_parser_service.dart';

class ResumeParserApiService {
  /// Parse resume using Supabase Edge Function
  /// 
  /// This method uploads the PDF to Supabase Storage and calls
  /// the Edge Function to parse it server-side
  static Future<ParsedResumeData> parseResumeViaAPI({
    required String fileUrl,
    String? bucket,
    String? fileName,
  }) async {
    try {
      debugPrint('ResumeParserApiService: Calling Edge Function to parse resume');
      debugPrint('ResumeParserApiService: File URL: $fileUrl');

      if (!SupabaseService.isInitialized) {
        throw Exception('Supabase not initialized');
      }

      // Call the Edge Function
      final response = await SupabaseService.client!.functions.invoke(
        'parse-resume',
        body: {
          'fileUrl': fileUrl,
          'bucket': bucket ?? 'resumes',
          'fileName': fileName,
        },
      );

      debugPrint('ResumeParserApiService: Edge Function response received');

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        throw Exception(
          errorData?['error']?.toString() ?? 'Failed to parse resume: ${response.status}',
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      
      if (responseData['success'] != true) {
        throw Exception(responseData['error']?.toString() ?? 'Failed to parse resume');
      }

      final parsedData = responseData['data'] as Map<String, dynamic>;
      
      // Convert API response to ParsedResumeData
      return _convertToParsedResumeData(parsedData);
    } catch (e, stackTrace) {
      debugPrint('ResumeParserApiService: Error parsing resume via API: $e');
      debugPrint('ResumeParserApiService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Convert API response to ParsedResumeData
  static ParsedResumeData _convertToParsedResumeData(Map<String, dynamic> data) {
    final result = ParsedResumeData();

    // Personal information
    result.name = data['name'] as String?;
    result.email = data['email'] as String?;
    result.phone = data['phone'] as String?;
    result.location = data['location'] as String?;
    result.title = data['title'] as String?;
    result.bio = data['bio'] as String?;

    // Experiences
    if (data['experiences'] != null) {
      final experiences = data['experiences'] as List<dynamic>;
      result.experiences = experiences.map((exp) {
        final expMap = exp as Map<String, dynamic>;
        return ParsedExperience(
          company: expMap['company'] as String,
          position: expMap['position'] as String,
          description: expMap['description'] as String?,
          startDate: expMap['startDate'] != null
              ? DateTime.tryParse(expMap['startDate'] as String)
              : null,
          endDate: expMap['endDate'] != null
              ? DateTime.tryParse(expMap['endDate'] as String)
              : null,
          isCurrent: expMap['isCurrent'] as bool? ?? false,
        );
      }).toList();
    }

    // Skills
    if (data['skills'] != null) {
      result.skills = List<String>.from(data['skills'] as List);
    }

    // Education
    if (data['education'] != null) {
      final education = data['education'] as List<dynamic>;
      result.education = education.map((edu) {
        final eduMap = edu as Map<String, dynamic>;
        return ParsedEducation(
          institution: eduMap['institution'] as String,
          degree: eduMap['degree'] as String?,
          field: eduMap['field'] as String?,
          startDate: eduMap['startDate'] != null
              ? DateTime.tryParse(eduMap['startDate'] as String)
              : null,
          endDate: eduMap['endDate'] != null
              ? DateTime.tryParse(eduMap['endDate'] as String)
              : null,
        );
      }).toList();
    }

    // Social links
    if (data['socialLinks'] != null) {
      final socialLinks = data['socialLinks'] as Map<String, dynamic>;
      result.socialLinks = Map<String, String>.from(
        socialLinks.map((key, value) => MapEntry(key, value.toString())),
      );
    }

    // Projects
    if (data['projects'] != null) {
      final projects = data['projects'] as List<dynamic>;
      result.projects = projects.map((proj) {
        final projMap = proj as Map<String, dynamic>;
        return ParsedProject(
          name: projMap['name'] as String,
          description: projMap['description'] as String?,
          technologies: projMap['technologies'] != null
              ? List<String>.from(projMap['technologies'] as List)
              : [],
          url: projMap['url'] as String?,
        );
      }).toList();
    }

    return result;
  }
}

