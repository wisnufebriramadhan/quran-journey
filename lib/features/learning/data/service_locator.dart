import 'package:quran_tracker/core/services/api_client.dart';
import 'package:quran_tracker/features/learning/data/learning_service.dart';
import 'package:quran_tracker/features/quran_log/data/quran_log_repository.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final ApiClient apiClient;
  late final LearningService learningService;
  late final QuranLogRepository quranLogRepository;

  void init() {
    // Initialize ApiClient
    apiClient = ApiClient();
    
    // Initialize services
    learningService = LearningService(apiClient);
    quranLogRepository = QuranLogRepository(apiClient);
  }
}

final sl = ServiceLocator();