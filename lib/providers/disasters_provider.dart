import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../models/disaster_monitor_model.dart';

class DisastersProvider extends ChangeNotifier {
  final ApiService apiService;

  List<DisasterMonitorModel> _disasters = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _activeOnlyFilter = false;

  DisastersProvider({required this.apiService});

  List<DisasterMonitorModel> get allDisasters => _disasters;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get activeOnlyFilter => _activeOnlyFilter;

  List<DisasterMonitorModel> get filteredDisasters {
    if (_activeOnlyFilter) {
      return _disasters.where((d) => d.hasActiveVerifiedWarning).toList();
    }
    return _disasters;
  }

  void toggleActiveOnlyFilter() {
    _activeOnlyFilter = !_activeOnlyFilter;
    notifyListeners();
  }

  Future<void> loadDisasters({bool forceRefresh = false}) async {
    if (_disasters.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _disasters = await apiService.fetchDisasterStatuses();
    } catch (e) {
      _errorMessage = 'Failed to load multi-disaster telemetry: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

