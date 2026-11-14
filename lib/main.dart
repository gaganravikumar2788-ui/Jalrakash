import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline persistent storage
  final storageService = await StorageService.init();

  // Initialize API service (ready for FastAPI backend / mock fallback)
  final apiService = ApiService(
    useMockData: storageService.getUseMockData(),
    baseUrl: storageService.getApiBaseUrl() ?? 'http://10.0.2.2:8000/api/v1',
  );

  runApp(
    FloodGuardApp(
      storageService: storageService,
      apiService: apiService,
    ),
  );
}
