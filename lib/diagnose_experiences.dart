import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:portfolio/core/services/turso_service.dart';
import 'package:portfolio/core/repositories/experience_repository.dart';

void main() async {
  print('Loading environment...');
  await dotenv.load(fileName: '.env');

  print('Initializing Turso...');
  await TursoService.initialize();

  final repo = ExperienceRepository();
  print('Fetching experiences...');

  try {
    // We need to bypass the repository wrapper to see what Turso *actually* returns
    // directly, to isolate if the issue is in the repository or the service.
    final client = TursoService.requiredClient;
    final response = await client
        .from('experiences')
        .select('id, company, position, description, start_date, end_date, is_current, order_index')
        .order('order_index', ascending: true);

    print('Raw Turso Response: $response');
  } catch (e) {
    print('Error: $e');
  }
}
