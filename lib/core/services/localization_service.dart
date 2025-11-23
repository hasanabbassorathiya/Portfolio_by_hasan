/// Localization service
/// Handles multi-language content management
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../services/supabase_service.dart';

class LocalizationService extends ChangeNotifier {
  LocalizationService._();
  static final LocalizationService _instance = LocalizationService._();
  factory LocalizationService() => _instance;

  Locale _currentLocale = Locale(AppConfig.defaultLocale);
  Locale get currentLocale => _currentLocale;

  /// Supported locales
  List<Locale> get supportedLocales {
    return AppConfig.supportedLocales
        .map((code) => Locale(code))
        .toList();
  }

  /// Change locale
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      return;
    }
    _currentLocale = locale;
    Intl.defaultLocale = locale.languageCode;
    notifyListeners();
  }

  /// Get localized text from database
  Future<String?> getLocalizedText({
    required String tableName,
    required String recordId,
    required String fieldName,
    String? locale,
  }) async {
    try {
      final targetLocale = locale ?? _currentLocale.languageCode;
      
      // Try to get translation
      final response = await SupabaseService.client
          .from('localizations')
          .select()
          .eq('table_name', tableName)
          .eq('record_id', recordId)
          .eq('locale', targetLocale)
          .eq('field_name', fieldName)
          .maybeSingle();

      if (response != null) {
        return response['translated_value'] as String?;
      }

      // Fallback to default locale if not found
      if (targetLocale != AppConfig.defaultLocale) {
        final defaultResponse = await SupabaseService.client
            .from('localizations')
            .select()
            .eq('table_name', tableName)
            .eq('record_id', recordId)
            .eq('locale', AppConfig.defaultLocale)
            .eq('field_name', fieldName)
            .maybeSingle();

        if (defaultResponse != null) {
          return defaultResponse['translated_value'] as String?;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get all translations for a record
  Future<Map<String, String>> getRecordTranslations({
    required String tableName,
    required String recordId,
    String? locale,
  }) async {
    try {
      final targetLocale = locale ?? _currentLocale.languageCode;
      
      final response = await SupabaseService.client
          .from('localizations')
          .select()
          .eq('table_name', tableName)
          .eq('record_id', recordId)
          .eq('locale', targetLocale);

      final translations = <String, String>{};
      for (final item in response as List) {
        translations[item['field_name'] as String] =
            item['translated_value'] as String;
      }

      return translations;
    } catch (e) {
      return {};
    }
  }
}

