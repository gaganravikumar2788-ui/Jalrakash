import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../models/user_profile_model.dart';

class AppStateProvider extends ChangeNotifier {
  final StorageService storageService;
  final ApiService apiService;

  String _selectedLocationId = 'patna_bihar';
  Map<String, dynamic> _selectedLocation = AppConstants.predefinedLocations[0];
  int _currentNavigationIndex = 0;
  bool _isOffline = false;
  late UserProfileModel _userProfile;

  AppStateProvider({
    required this.storageService,
    required this.apiService,
  }) {
    _init();
  }

  void _init() {
    _selectedLocationId = storageService.getSelectedLocationId();
    _selectedLocation = AppConstants.predefinedLocations.firstWhere(
      (loc) => loc['id'] == _selectedLocationId,
      orElse: () => AppConstants.predefinedLocations[0],
    );
    _userProfile = storageService.getUserProfile();
    apiService.useMockData = storageService.getUseMockData();
    final savedUrl = storageService.getApiBaseUrl();
    if (savedUrl != null && savedUrl.isNotEmpty) {
      apiService.baseUrl = savedUrl;
    }
  }

  String get selectedLocationId => _selectedLocationId;
  Map<String, dynamic> get selectedLocation => _selectedLocation;
  int get currentNavigationIndex => _currentNavigationIndex;
  bool get isOffline => _isOffline;
  UserProfileModel get userProfile => _userProfile;
  List<Map<String, dynamic>> get allLocations => AppConstants.predefinedLocations;

  void setNavigationIndex(int index) {
    if (_currentNavigationIndex != index) {
      _currentNavigationIndex = index;
      notifyListeners();
    }
  }

  Future<void> changeLocation(String locationId) async {
    if (_selectedLocationId == locationId) return;

    _selectedLocationId = locationId;
    _selectedLocation = AppConstants.predefinedLocations.firstWhere(
      (loc) => loc['id'] == locationId,
      orElse: () => AppConstants.predefinedLocations[0],
    );
    await storageService.setSelectedLocationId(locationId);
    notifyListeners();
  }

  void toggleOfflineMode() {
    _isOffline = !_isOffline;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfileModel profile) async {
    _userProfile = profile;
    await storageService.saveUserProfile(profile);
    notifyListeners();
  }

  Future<void> updateApiConfig({required String baseUrl, required bool useMock}) async {
    apiService.baseUrl = baseUrl;
    apiService.useMockData = useMock;
    await storageService.setApiBaseUrl(baseUrl);
    await storageService.setUseMockData(useMock);
    notifyListeners();
  }
}

