enum ContactCategory {
  nationalDisaster,
  stateDistrict,
  medicalRescue,
  policeFire,
  personalFamily;

  String get displayName {
    switch (this) {
      case ContactCategory.nationalDisaster:
        return 'National Disaster Helplines';
      case ContactCategory.stateDistrict:
        return 'State & District Helplines';
      case ContactCategory.medicalRescue:
        return 'Medical & Ambulance';
      case ContactCategory.policeFire:
        return 'Police & Fire Emergency';
      case ContactCategory.personalFamily:
        return 'Family & Personal Contacts';
    }
  }
}

class EmergencyContactModel {
  final String id;
  final String title;
  final String subtitle;
  final String phoneNumber;
  final ContactCategory category;
  final bool isOfficial;
  final bool isTollFree;
  final String? notes;

  EmergencyContactModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.phoneNumber,
    required this.category,
    this.isOfficial = true,
    this.isTollFree = false,
    this.notes,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      category: ContactCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ContactCategory.nationalDisaster,
      ),
      isOfficial: json['is_official'] ?? true,
      isTollFree: json['is_toll_free'] ?? false,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'phone_number': phoneNumber,
        'category': category.name,
        'is_official': isOfficial,
        'is_toll_free': isTollFree,
        'notes': notes,
      };
}

