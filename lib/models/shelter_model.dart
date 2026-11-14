class ShelterModel {
  final String id;
  final String name;
  final String address;
  final String district;
  final String state;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final int capacityPeople;
  final int currentOccupancy;
  final bool isVerifiedByAuthority; // Crucial requirement
  final String managingAuthority; // e.g. "Patna District Disaster Management Authority (DDMA)"
  final String contactPhone;
  final List<String> availableFacilities; // e.g. ["Drinking Water", "First Aid", "Backup Power", "Food Packets"]
  final bool isAccessible;

  ShelterModel({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.capacityPeople,
    required this.currentOccupancy,
    required this.isVerifiedByAuthority,
    required this.managingAuthority,
    required this.contactPhone,
    required this.availableFacilities,
    this.isAccessible = true,
  });

  int get availableBeds => (capacityPeople - currentOccupancy).clamp(0, capacityPeople);

  factory ShelterModel.fromJson(Map<String, dynamic> json) {
    return ShelterModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      capacityPeople: json['capacity_people'] ?? 0,
      currentOccupancy: json['current_occupancy'] ?? 0,
      isVerifiedByAuthority: json['is_verified_by_authority'] ?? false,
      managingAuthority: json['managing_authority'] ?? 'District Administration',
      contactPhone: json['contact_phone'] ?? '',
      availableFacilities:
          List<String>.from(json['available_facilities'] ?? []),
      isAccessible: json['is_accessible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'district': district,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        'distance_km': distanceKm,
        'capacity_people': capacityPeople,
        'current_occupancy': currentOccupancy,
        'is_verified_by_authority': isVerifiedByAuthority,
        'managing_authority': managingAuthority,
        'contact_phone': contactPhone,
        'available_facilities': availableFacilities,
        'is_accessible': isAccessible,
      };
}

