import 'package:flutter/foundation.dart';
import 'turso_service.dart';

class SupabaseService {
  SupabaseService._();

  static Future<void> initialize() async {
    await TursoService.initialize();
  }

  static TursoClient? get client => TursoService.client;

  static TursoClient get requiredClient => TursoService.requiredClient;

  static bool get isInitialized => TursoService.isInitialized;

  static dynamic get storage => MockStorage();

  static dynamic get auth => MockAuth();
}

class MockAuth {
  Future<void> signInWithPassword({required String email, required String password}) async {}
  Future<void> resetPasswordForEmail(String email, {String? redirectTo}) async {}
  Future<void> signOut() async {}
  Future<dynamic> verifyOTP({required String token, required String type, required String email}) async => null;
  Future<dynamic> updateUser(dynamic attributes) async => null;
  dynamic get currentUser => MockUser();
  dynamic get currentSession => MockSession();
  Stream<dynamic> get onAuthStateChange => Stream.empty();
}
class MockSession { dynamic get user => MockUser(); }
class MockUser { String get email => 'admin@admin.com'; String get id => 'admin-123'; }

class MockStorage {
  MockBucket from(String bucket) => MockBucket();
}

class MockBucket {
  Future<void> remove(List<String> paths) async {}
  String getPublicUrl(String path) => 'https://example.com/mock.png';
  Future<dynamic> upload(String path, dynamic file, {dynamic fileOptions}) async => 'mock';
  Future<dynamic> uploadBinary(String path, dynamic bytes, {dynamic fileOptions}) async => 'mock';
}
