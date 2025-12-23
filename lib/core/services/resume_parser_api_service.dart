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
      debugPrint(
        'ResumeParserApiService: Calling Edge Function to parse resume',
      );
      debugPrint('ResumeParserApiService: File URL: $fileUrl');
      debugPrint('ResumeParserApiService: Bucket: ${bucket ?? 'resumes'}');
      debugPrint('ResumeParserApiService: File Name: $fileName');

      if (!SupabaseService.isInitialized) {
        throw Exception('Supabase not initialized');
      }

      final client = SupabaseService.client!;

      // Call the Edge Function
      debugPrint('ResumeParserApiService: Invoking function: parse-resume');
      final response = await client.functions.invoke(
        'parse-resume',
        body: {
          'fileUrl': fileUrl,
          'bucket': bucket ?? 'resumes',
          'fileName': fileName,
        },
      );

      debugPrint('ResumeParserApiService: Edge Function response received');
      debugPrint('ResumeParserApiService: Response status: ${response.status}');
      debugPrint('ResumeParserApiService: Response data: ${response.data}');

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMessage =
            errorData?['error']?.toString() ??
            errorData?['message']?.toString() ??
            'Failed to parse resume: ${response.status}';
        throw Exception(errorMessage);
      }

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['success'] != true) {
        final errorMessage =
            responseData['error']?.toString() ??
            responseData['message']?.toString() ??
            'Failed to parse resume';
        throw Exception(errorMessage);
      }

      final parsedData = responseData['data'] as Map<String, dynamic>;

      // Convert API response to ParsedResumeData
      return _convertToParsedResumeData(parsedData);
    } catch (e, stackTrace) {
      debugPrint('ResumeParserApiService: Error parsing resume via API: $e');
      debugPrint('ResumeParserApiService: Error type: ${e.runtimeType}');
      debugPrint('ResumeParserApiService: Stack trace: $stackTrace');

      final errorString = e.toString();

      // Check for network/fetch errors
      if (errorString.contains('Failed to fetch') ||
          errorString.contains('NetworkError') ||
          errorString.contains('ClientException')) {
        throw Exception(
          'Edge Function "parse-resume" is not deployed or not accessible.\n\n'
          'Please deploy the Edge Function:\n'
          '1. Go to Supabase Dashboard → Edge Functions\n'
          '2. Create/Deploy function: "parse-resume"\n'
          '3. Copy code from: supabase/functions/parse-resume/index.ts\n'
          '4. Or use CLI: supabase functions deploy parse-resume\n\n'
          'Original error: $errorString',
        );
      }

      // Re-throw with original error if it's already a helpful message
      rethrow;
    }
  }

  /// Convert API response to ParsedResumeData
  static ParsedResumeData _convertToParsedResumeData(
    Map<String, dynamic> data,
  ) {
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
      result.experiences =
          experiences.map((exp) {
            final expMap = exp as Map<String, dynamic>;
            return ParsedExperience(
              company: expMap['company'] as String,
              position: expMap['position'] as String,
              description: expMap['description'] as String?,
              startDate:
                  expMap['startDate'] != null
                      ? DateTime.tryParse(expMap['startDate'] as String)
                      : null,
              endDate:
                  expMap['endDate'] != null
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
      result.education =
          education.map((edu) {
            final eduMap = edu as Map<String, dynamic>;
            return ParsedEducation(
              institution: eduMap['institution'] as String,
              degree: eduMap['degree'] as String?,
              field: eduMap['field'] as String?,
              startDate:
                  eduMap['startDate'] != null
                      ? DateTime.tryParse(eduMap['startDate'] as String)
                      : null,
              endDate:
                  eduMap['endDate'] != null
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
      result.projects =
          projects.map((proj) {
            final projMap = proj as Map<String, dynamic>;
            return ParsedProject(
              name: projMap['name'] as String,
              description: projMap['description'] as String?,
              technologies:
                  projMap['technologies'] != null
                      ? List<String>.from(projMap['technologies'] as List)
                      : [],
              url: projMap['url'] as String?,
            );
          }).toList();
    }

    return result;
  }
}
