
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:portfolio/core/config/app_config.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/core/services/turso_service.dart';
import 'package:portfolio/models/profile/profile_model.dart';
import 'package:portfolio/core/repositories/profile_repository.dart';
import 'package:portfolio/core/repositories/experience_repository.dart';
import 'package:portfolio/core/repositories/service_repository.dart';

// Since we're running this via CLI, we can't use Flutter's WidgetsFlutterBinding easily
// We'll just run it as a standard Dart script after initializing Turso manually.

void main() async {
  print('Initializing environment...');
  await dotenv.load(fileName: '.env');
  
  print('Initializing Turso...');
  await TursoService.initialize();
  
  if (!TursoService.isInitialized) {
    print('Failed to initialize Turso.');
    return;
  }

  final profileRepo = ProfileRepository();
  final experienceRepo = ExperienceRepository();
  final serviceRepo = ServiceRepository();

  print('Updating Profile...');
  
  // Note: Using TursoQueryBuilder directly to update the profile to avoid UI coupling
  // Update Profile
  await TursoService.client!.from('profiles').upsert({
    'id': 'profile-1',
    'name': 'HASAN ABBAS SORATHIYA',
    'title': 'Senior Software Engineer | Mobile & Cloud Platforms',
    'bio': 'Senior Software Engineer with 6+ years of experience building and scaling mobile and full-stack applications across e-commerce, mobility, and enterprise platforms. Specialized in Flutter, MERN stack, and cloud-native architectures (AWS, Firebase, GCP).',
    'email': 'hasanabbassorathiya12@gmail.com',
    'phone': '+971-589602320',
    'location': 'Dubai, United Arab Emirates',
    'avatar_url': 'https://github.com/hasanabbassorathiya/portfolio/raw/main/assets/icons/hasan.png',
    'years_of_experience': 6
  });

  print('Deleting old experiences...');
  await TursoService.client!.from('experiences').deleteAll();

  print('Adding Works...');

  final works = [
    {
      'id': 'work-1',
      'title': 'Duas and Aamal',
      'description': 'A religious lifestyle app providing a collection of daily duas, aamal, and spiritual content. Designed for accessibility and simplicity, with features like categorized content, bookmarking, and offline availability for uninterrupted use.',
      'image_url': 'https://placehold.co/800x600?text=Duas+and+Aamal',
      'project_link': 'https://apps.apple.com/ae/app/duas-and-aamal/id6478907381',
      'is_active': true,
      'is_featured': true,
      'order_index': 1
    },
    {
      'id': 'work-2',
      'title': '14 Stars',
      'description': 'A mobile-first astrology and horoscope application designed to deliver personalized daily insights, zodiac compatibility analysis, and spiritual guidance. Built with a focus on intuitive UX, real-time content updates, and engaging visual storytelling to enhance user retention.',
      'image_url': 'https://placehold.co/800x600?text=14+Stars+App',
      'project_link': 'https://apps.apple.com/in/app/14-stars/id1526359119',
      'is_active': true,
      'is_featured': true,
      'order_index': 2
    },
    {
      'id': 'work-3',
      'title': 'Automover (TMS)',
      'description': 'A full-scale logistics and transport management platform enabling vehicle tracking, dispatch optimization, job scheduling, and operational analytics. Delivered both mobile and web solutions to streamline fleet operations and improve delivery efficiency.',
      'image_url': 'https://placehold.co/800x600?text=Automover+TMS',
      'project_link': 'https://www.automover.com.au/',
      'is_active': true,
      'is_featured': false,
      'order_index': 3
    },
    {
      'id': 'work-4',
      'title': 'Pool Inspection Apps',
      'description': 'A field-service inspection application for pool compliance and safety audits. Features include offline inspections, photo evidence capture, report generation, and regulatory compliance workflows, reducing manual paperwork and increasing inspection accuracy.',
      'image_url': 'https://placehold.co/800x600?text=Pool+Inspection',
      'project_link': 'https://apps.apple.com/us/app/pool-inspection-apps/id1528932146',
      'is_active': true,
      'is_featured': false,
      'order_index': 4
    },
    {
      'id': 'work-5',
      'title': 'Good2Go Loans',
      'description': 'A fintech mobile application providing fast loan approvals, credit assessment, and repayment management. Integrated secure KYC flows, payment gateways, and user-friendly dashboards to simplify borrowing for end users.',
      'image_url': 'https://placehold.co/800x600?text=Good2Go+Loans',
      'project_link': 'https://apps.apple.com/us/app/good-to-go-loans/id1542316639',
      'is_active': true,
      'is_featured': false,
      'order_index': 5
    },
    {
      'id': 'work-6',
      'title': 'Nutrabay',
      'description': 'A high-performance e-commerce platform for health and nutrition products. Focused on scalable architecture, seamless checkout experience, and optimized mobile performance to support high transaction volumes and customer retention.',
      'image_url': 'https://placehold.co/800x600?text=Nutrabay',
      'project_link': 'https://nutrabay.com/',
      'is_active': true,
      'is_featured': false,
      'order_index': 6
    },
    {
      'id': 'work-7',
      'title': 'EVLAB',
      'description': 'A fitness and supplement tracking application designed to support workout planning, nutrition tracking, and product discovery. Delivered a responsive cross-platform experience with real-time data synchronization and performance insights.',
      'image_url': 'https://placehold.co/800x600?text=EVLAB',
      'project_link': 'https://apps.apple.com/ae/app/evlab/id1635102548',
      'is_active': true,
      'is_featured': false,
      'order_index': 7
    },
    {
      'id': 'work-8',
      'title': 'Hoda',
      'description': 'A modern Islamic lifestyle and guidance application delivering curated content, reminders, and user-centric features aimed at enhancing spiritual engagement through a clean and minimal interface.',
      'image_url': 'https://placehold.co/800x600?text=Hoda+App',
      'project_link': 'https://apps.apple.com/ae/app/hoda/id6755375239',
      'is_active': true,
      'is_featured': false,
      'order_index': 8
    },
    {
      'id': 'work-9',
      'title': 'Fragrance of Mastership',
      'description': 'A content-driven mobile application centered around spiritual teachings and personal development. Focused on immersive reading experience, structured content delivery, and user engagement through clean UI design.',
      'image_url': 'https://placehold.co/800x600?text=Fragrance+of+Mastership',
      'project_link': 'https://apps.apple.com/ae/app/fragrance-of-mastership/id6480333197',
      'is_active': true,
      'is_featured': false,
      'order_index': 9
    },
    {
      'id': 'work-10',
      'title': 'Lumio IPTV',
      'description': 'A multimedia streaming application enabling users to access IPTV content with optimized playback performance, channel management, and user-friendly navigation. Built for stability and high-quality streaming across devices.',
      'image_url': 'https://placehold.co/800x600?text=Lumio+IPTV',
      'project_link': 'https://play.google.com/store/apps/details?id=app.lumioiptv.com',
      'is_active': true,
      'is_featured': false,
      'order_index': 10
    },
    {
      'id': 'work-11',
      'title': 'Kokoro Michi',
      'description': 'A wellness and mindfulness application focused on mental well-being through guided practices, journaling, and self-improvement tools. Designed to provide a calming user experience with intuitive navigation and minimalistic design.',
      'image_url': 'https://placehold.co/800x600?text=Kokoro+Michi',
      'project_link': 'https://play.google.com/store/apps/details?id=app.kokoromichi.com',
      'is_active': true,
      'is_featured': false,
      'order_index': 11
    },
  ];

  await TursoService.client!.from('works').deleteAll();
  for (final work in works) {
    await TursoService.client!.from('works').insert(work);
  }

  print('Works updated successfully!');

  print('Portfolio updated successfully via application services!');
}
