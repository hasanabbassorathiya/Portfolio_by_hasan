import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_strategy/url_strategy.dart';
import 'app.dart';
import 'core/database/portfolio_repository.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
  } catch (_) {}

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setPathUrlStrategy();

  await PortfolioRepository().init();

  runApp(const PortfolioApp());
}
