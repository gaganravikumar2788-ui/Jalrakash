import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../models/flood_risk_model.dart';

class FloodRiskProvider extends ChangeNotifier {
  final ApiService apiService;

  FloodRiskModel? _floodRisk;
  bool _isLoading = false;
  String? _errorMessage;

  FloodRiskProvider({required this.apiService});

  FloodRiskModel? get floodRisk => _floodRisk;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadFloodRisk(String locationId, {bool forceRefresh = false}) async {
    if (_floodRisk != null && _floodRisk!.locationId == locationId && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _floodRisk = await apiService.fetchFloodRisk(locationId);
    } catch (e) {
      _errorMessage = 'Unable to fetch hydrological risk prediction: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

