import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../models/weather_model.dart';

class WeatherProvider extends ChangeNotifier {
  final ApiService apiService;

  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  WeatherProvider({required this.apiService});

  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadWeather(String locationId, {bool forceRefresh = false}) async {
    if (_weather != null && _weather!.locationId == locationId && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _weather = await apiService.fetchWeather(locationId);
    } catch (e) {
      _errorMessage = 'Unable to fetch weather telemetry: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

