
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
  await TursoService.client!.from('experiences').delete().gte('id', '');

  print('Adding Work Experiences...');
  
  final experiences = [
    {
      'id': 'exp-1',
      'company': 'Chalhoub Group',
      'position': 'Senior Software Engineer',
      'description': '• Led development of EVLAB platform, enabling EV rentals and leasing workflows across UAE.\n• Architected Flutter applications (Clean Architecture, Riverpod).\n• Built scalable backend services (Node.js, MongoDB, REST APIs).\n• Implemented CI/CD pipelines and automated testing.\n• Designed AWS cloud infrastructure.',
      'start_date': '2023-07-01',
      'end_date': null,
      'is_current': true,
      'order_index': 0
    },
    {
      'id': 'exp-2',
      'company': 'Belong Interactive',
      'position': 'Senior Software Engineer (Team Lead)',
      'description': '• Led full lifecycle development of mobile apps (Nakheel Marinas, Marassi Galleria).\n• Delivered multiple consumer applications, increasing platform adoption.\n• Optimized cloud and backend infrastructure.\n• Established engineering standards (SOLID, Clean Architecture).',
      'start_date': '2022-08-01',
      'end_date': '2023-06-30',
      'is_current': false,
      'order_index': 1
    },
    {
      'id': 'exp-3',
      'company': 'Masaar',
      'position': 'Senior Software Engineer',
      'description': '• Revamped e-commerce mobile platform.\n• Led Agile sprint execution.\n• Implemented secure authentication (OAuth, JWT).\n• Integrated A/B testing and analytics.',
      'start_date': '2022-01-01',
      'end_date': '2022-08-01',
      'is_current': false,
      'order_index': 2
    },
    {
      'id': 'exp-edu-1',
      'company': 'University of Mumbai',
      'position': 'Bachelor of Science in Information Technology',
      'description': '• Achieved a 8.6 GPA, demonstrating strong technical foundation.\n• Capstone: AI chatbot using Python, Flask, TensorFlow, NLP.',
      'start_date': '2016-01-01',
      'end_date': '2019-01-01',
      'is_current': false,
      'order_index': 4
    }
  ];

  for (final exp in experiences) {
    await TursoService.client!.from('experiences').insert(exp);
  }

  print('Portfolio updated successfully via application services!');
}
