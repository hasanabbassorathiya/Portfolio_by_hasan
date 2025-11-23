/// App localizations
/// Provides localized strings for the application
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final List<Locale> supportedLocales = [
    const Locale('en', ''),
    const Locale('ar', ''),
    const Locale('fr', ''),
  ];

  // Navigation
  String get home => _localizedValues[locale.languageCode]?['home'] ?? 'Home';
  String get about => _localizedValues[locale.languageCode]?['about'] ?? 'About';
  String get services =>
      _localizedValues[locale.languageCode]?['services'] ?? 'Services';
  String get works => _localizedValues[locale.languageCode]?['works'] ?? 'Works';
  String get blogs => _localizedValues[locale.languageCode]?['blogs'] ?? 'Blogs';
  String get contact =>
      _localizedValues[locale.languageCode]?['contact'] ?? 'Contact';

  // Common
  String get loadMore =>
      _localizedValues[locale.languageCode]?['loadMore'] ?? 'Load more';
  String get readMore =>
      _localizedValues[locale.languageCode]?['readMore'] ?? 'Read more';
  String get submit =>
      _localizedValues[locale.languageCode]?['submit'] ?? 'Submit';
  String get cancel =>
      _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';

  // Contact
  String get name => _localizedValues[locale.languageCode]?['name'] ?? 'Name';
  String get email =>
      _localizedValues[locale.languageCode]?['email'] ?? 'Email';
  String get message =>
      _localizedValues[locale.languageCode]?['message'] ?? 'Message';
  String get attachFile =>
      _localizedValues[locale.languageCode]?['attachFile'] ?? 'Attach file';
  String get anyProject =>
      _localizedValues[locale.languageCode]?['anyProject'] ?? 'any project?';
  String get submitNow =>
      _localizedValues[locale.languageCode]?['submitNow'] ?? 'Submit now';
  String get reachOutMe =>
      _localizedValues[locale.languageCode]?['reachOutMe'] ?? 'Reach out me';

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'home': 'Home',
      'about': 'About',
      'services': 'Services',
      'works': 'Works',
      'blogs': 'Blogs',
      'contact': 'Contact',
      'loadMore': 'Load more',
      'readMore': 'Read more',
      'submit': 'Submit',
      'cancel': 'Cancel',
      'name': 'Name',
      'email': 'Email',
      'message': 'Message',
      'attachFile': 'Attach file',
      'anyProject': 'any project?',
      'submitNow': 'Submit now',
      'reachOutMe': 'Reach out me',
    },
    'ar': {
      'home': 'الرئيسية',
      'about': 'نبذة',
      'services': 'الخدمات',
      'works': 'الأعمال',
      'blogs': 'المدونة',
      'contact': 'اتصل',
      'loadMore': 'تحميل المزيد',
      'readMore': 'اقرأ المزيد',
      'submit': 'إرسال',
      'cancel': 'إلغاء',
      'name': 'الاسم',
      'email': 'البريد الإلكتروني',
      'message': 'الرسالة',
      'attachFile': 'إرفاق ملف',
      'anyProject': 'أي مشروع؟',
      'submitNow': 'إرسال الآن',
      'reachOutMe': 'تواصل معي',
    },
    'fr': {
      'home': 'Accueil',
      'about': 'À propos',
      'services': 'Services',
      'works': 'Travaux',
      'blogs': 'Blogs',
      'contact': 'Contact',
      'loadMore': 'Charger plus',
      'readMore': 'Lire plus',
      'submit': 'Soumettre',
      'cancel': 'Annuler',
      'name': 'Nom',
      'email': 'E-mail',
      'message': 'Message',
      'attachFile': 'Joindre un fichier',
      'anyProject': 'un projet?',
      'submitNow': 'Soumettre maintenant',
      'reachOutMe': 'Contactez-moi',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

