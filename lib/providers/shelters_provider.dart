import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../models/shelter_model.dart';

class SheltersProvider extends ChangeNotifier {
  final ApiService apiService;

  List<ShelterModel> _shelters = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  bool _verifiedOnlyFilter = true;

  SheltersProvider({required this.apiService});

  List<ShelterModel> get allShelters => _shelters;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get verifiedOnlyFilter => _verifiedOnlyFilter;

  List<ShelterModel> get filteredShelters {
    return _shelters.where((s) {
      if (_verifiedOnlyFilter && !s.isVerifiedByAuthority) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = s.name.toLowerCase().contains(q);
        final matchAddress = s.address.toLowerCase().contains(q);
        final matchDistrict = s.district.toLowerCase().contains(q);
        return matchName || matchAddress || matchDistrict;
      }
      return true;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleVerifiedOnly() {
    _verifiedOnlyFilter = !_verifiedOnlyFilter;
    notifyListeners();
  }

  Future<void> loadShelters({String? locationId, bool forceRefresh = false}) async {
    if (_shelters.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _shelters = await apiService.fetchShelters(locationId: locationId);
    } catch (e) {
      _errorMessage = 'Failed to load verified relief shelters: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

