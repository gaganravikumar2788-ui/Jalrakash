import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/emergency_contact_model.dart';
import '../../models/user_profile_model.dart';

class StorageService {
  static const String _keySelectedLocation = 'selected_location_id';
  static const String _keyCustomContacts = 'custom_emergency_contacts';
  static const String _keyChecklistState = 'safety_checklist_state';
  static const String _keyUserProfile = 'user_profile_data';
  static const String _keyApiBaseUrl = 'api_base_url';
  static const String _keyUseMockData = 'use_mock_data';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Location
  String getSelectedLocationId() {
    return _prefs.getString(_keySelectedLocation) ?? 'patna_bihar';
  }

  Future<void> setSelectedLocationId(String locationId) async {
    await _prefs.setString(_keySelectedLocation, locationId);
  }

  // Custom Family Emergency Contacts
  List<EmergencyContactModel> getCustomContacts() {
    final jsonStr = _prefs.getString(_keyCustomContacts);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => EmergencyContactModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCustomContacts(List<EmergencyContactModel> contacts) async {
    final list = contacts.map((e) => e.toJson()).toList();
    await _prefs.setString(_keyCustomContacts, jsonEncode(list));
  }

  // Safety Checklist Items
  Set<String> getChecklistItems() {
    final list = _prefs.getStringList(_keyChecklistState);
    return list != null ? list.toSet() : <String>{};
  }

  Future<void> toggleChecklistItem(String itemId) async {
    final current = getChecklistItems();
    if (current.contains(itemId)) {
      current.remove(itemId);
    } else {
      current.add(itemId);
    }
    await _prefs.setStringList(_keyChecklistState, current.toList());
  }

  // User Profile
  UserProfileModel getUserProfile() {
    final jsonStr = _prefs.getString(_keyUserProfile);
    if (jsonStr == null || jsonStr.isEmpty) {
      return UserProfileModel.defaultProfile();
    }
    try {
      return UserProfileModel.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return UserProfileModel.defaultProfile();
    }
  }

  Future<void> saveUserProfile(UserProfileModel profile) async {
    await _prefs.setString(_keyUserProfile, jsonEncode(profile.toJson()));
  }

  // API Config
  String? getApiBaseUrl() => _prefs.getString(_keyApiBaseUrl);
  Future<void> setApiBaseUrl(String url) => _prefs.setString(_keyApiBaseUrl, url);

  bool getUseMockData() => _prefs.getBool(_keyUseMockData) ?? true;
  Future<void> setUseMockData(bool value) => _prefs.setBool(_keyUseMockData, value);
}

