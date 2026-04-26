
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:portfolio/core/config/app_config.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/core/services/turso_service.dart';
import 'package:portfolio/models/profile/profile_model.dart';
import 'package:portfolio/core/repositories/profile_repository.dart';

void main() async {
  print('Loading environment and repositories...');
  await dotenv.load(fileName: '.env');
  await TursoService.initialize();
  
  if (!TursoService.isInitialized) {
    print('Failed to initialize Database.');
    return;
  }

  // Use the ACTUAL Application Repository, same as the Admin Panel uses!
  final profileRepo = ProfileRepository();
  
  print('Updating Profile via ProfileRepository...');
  
  final newProfile = ProfileModel(
    id: 'profile-1',
    name: 'HASAN ABBAS SORATHIYA',
    title: 'Senior Software Engineer | Mobile & Cloud Platforms',
    bio: 'Senior Software Engineer with 6+ years of experience building and scaling mobile and full-stack applications across e-commerce, mobility, and enterprise platforms. Specialized in Flutter, MERN stack, and cloud-native architectures (AWS, Firebase, GCP).',
    email: 'hasanabbassorathiya12@gmail.com',
    phone: '+971-589602320',
    location: 'Dubai, United Arab Emirates',
    avatarUrl: 'https://github.com/hasanabbassorathiya/portfolio/raw/main/assets/icons/hasan.png',
    resumeUrl: 'https://flowcv.com/resume/pmesjl0q9sm9', // Added resume URL
    yearsOfExperience: 6,
  );

  try {
    await profileRepo.updateProfile(newProfile);
    print('✅ Successfully updated Profile using App Admin Repository Logic!');
  } catch (e) {
    print('Error: $e');
  }

  print('Done.');
}
