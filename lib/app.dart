import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'providers/app_state_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/flood_risk_provider.dart';
import 'providers/alerts_provider.dart';
import 'providers/disasters_provider.dart';
import 'providers/shelters_provider.dart';
import 'providers/contacts_provider.dart';
import 'providers/safety_provider.dart';

class FloodGuardApp extends StatelessWidget {
  final StorageService storageService;
  final ApiService apiService;

  const FloodGuardApp({
    super.key,
    required this.storageService,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppStateProvider(
            storageService: storageService,
            apiService: apiService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => FloodRiskProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => AlertsProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => DisastersProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => SheltersProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ContactsProvider(
            apiService: apiService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SafetyProvider(storageService: storageService),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appFullName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

