import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/utils/risk_level_helper.dart';
import '../models/emergency_alert_model.dart';

class AlertsProvider extends ChangeNotifier {
  final ApiService apiService;

  List<EmergencyAlertModel> _alerts = [];
  bool _isLoading = false;
  String? _errorMessage;
  RiskLevel? _selectedSeverityFilter;
  bool _officialOnlyFilter = false;

  AlertsProvider({required this.apiService});

  List<EmergencyAlertModel> get allAlerts => _alerts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RiskLevel? get selectedSeverityFilter => _selectedSeverityFilter;
  bool get officialOnlyFilter => _officialOnlyFilter;

  List<EmergencyAlertModel> get filteredAlerts {
    return _alerts.where((alert) {
      if (_selectedSeverityFilter != null &&
          alert.severity != _selectedSeverityFilter) {
        return false;
      }
      if (_officialOnlyFilter && !alert.isOfficialGovernmentWarning) {
        return false;
      }
      return true;
    }).toList();
  }

  int get severeAlertsCount =>
      _alerts.where((a) => a.severity == RiskLevel.severe).length;

  bool get hasUrgentEvacuation =>
      _alerts.any((a) => a.isUrgentEvacuation);

  void setSeverityFilter(RiskLevel? level) {
    _selectedSeverityFilter = level;
    notifyListeners();
  }

  void toggleOfficialOnlyFilter() {
    _officialOnlyFilter = !_officialOnlyFilter;
    notifyListeners();
  }

  Future<void> loadAlerts({String? locationId, bool forceRefresh = false}) async {
    if (_alerts.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _alerts = await apiService.fetchAlerts(locationId: locationId);
    } catch (e) {
      _errorMessage = 'Failed to load active disaster alerts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

