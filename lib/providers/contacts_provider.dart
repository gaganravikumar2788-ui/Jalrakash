import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../models/emergency_contact_model.dart';

class ContactsProvider extends ChangeNotifier {
  final ApiService apiService;
  final StorageService storageService;

  List<EmergencyContactModel> _officialContacts = [];
  List<EmergencyContactModel> _familyContacts = [];
  ContactCategory? _selectedCategory;

  ContactsProvider({
    required this.apiService,
    required this.storageService,
  }) {
    _init();
  }

  void _init() {
    _officialContacts = apiService.getOfficialEmergencyContacts();
    _familyContacts = storageService.getCustomContacts();
  }

  List<EmergencyContactModel> get officialContacts => _officialContacts;
  List<EmergencyContactModel> get familyContacts => _familyContacts;
  ContactCategory? get selectedCategory => _selectedCategory;

  List<EmergencyContactModel> get filteredOfficialContacts {
    if (_selectedCategory == null) return _officialContacts;
    return _officialContacts.where((c) => c.category == _selectedCategory).toList();
  }

  void setCategory(ContactCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addFamilyContact({
    required String name,
    required String relationship,
    required String phoneNumber,
  }) async {
    final newContact = EmergencyContactModel(
      id: 'fam_${DateTime.now().millisecondsSinceEpoch}',
      title: name,
      subtitle: relationship,
      phoneNumber: phoneNumber.trim(),
      category: ContactCategory.personalFamily,
      isOfficial: false,
      isTollFree: false,
    );

    _familyContacts.add(newContact);
    await storageService.saveCustomContacts(_familyContacts);
    notifyListeners();
  }

  Future<void> removeFamilyContact(String id) async {
    _familyContacts.removeWhere((c) => c.id == id);
    await storageService.saveCustomContacts(_familyContacts);
    notifyListeners();
  }

  Future<bool> makePhoneCall(String phoneNumber) async {
    // Strip non-dialable characters except +
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        return await launchUrl(launchUri);
      } else {
        debugPrint('Could not launch dialer for $launchUri');
        return false;
      }
    } catch (e) {
      debugPrint('Error launching dialer: $e');
      return false;
    }
  }
}

