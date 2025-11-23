import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:portfolio/shared/routes/router.dart';
import 'package:portfolio/shared/theme/app_theme.dart';
import 'package:portfolio/core/config/app_config.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/core/services/firebase_service.dart';
import 'package:portfolio/core/services/error_handler.dart';
import 'package:portfolio/shared/widgets/maintenance_mode_widget.dart';
import 'package:portfolio/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global error handler (must be first)
  ErrorHandler.initialize();

  // Initialize configuration
  await AppConfig.initialize();

  // Initialize Firebase
  await FirebaseService.initialize();

  // Initialize Supabase
  await SupabaseService.initialize();

  setPathUrlStrategy();
  runApp(const Portfolio());
}

class Portfolio extends StatelessWidget {
  const Portfolio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaintenanceModeWidget(
      child: MaterialApp.router(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter().appRouter,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        // Localization
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(AppConfig.defaultLocale),
      ),
    );
  }
}
