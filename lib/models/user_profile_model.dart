class UserProfileModel {
  final String name;
  final String phone;
  final String bloodGroup;
  final String primaryLocationId;
  final bool receiveSevereAlerts;
  final bool receiveDailyWeather;
  final bool receiveRiverLevelUpdates;
  final bool locationPermissionGranted;

  UserProfileModel({
    required this.name,
    required this.phone,
    required this.bloodGroup,
    required this.primaryLocationId,
    this.receiveSevereAlerts = true,
    this.receiveDailyWeather = true,
    this.receiveRiverLevelUpdates = true,
    this.locationPermissionGranted = false,
  });

  factory UserProfileModel.defaultProfile() {
    return UserProfileModel(
      name: 'Rohan Sharma',
      phone: '+91 98765 43210',
      bloodGroup: 'O+',
      primaryLocationId: 'patna_bihar',
      receiveSevereAlerts: true,
      receiveDailyWeather: true,
      receiveRiverLevelUpdates: true,
      locationPermissionGranted: true,
    );
  }

  UserProfileModel copyWith({
    String? name,
    String? phone,
    String? bloodGroup,
    String? primaryLocationId,
    bool? receiveSevereAlerts,
    bool? receiveDailyWeather,
    bool? receiveRiverLevelUpdates,
    bool? locationPermissionGranted,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      primaryLocationId: primaryLocationId ?? this.primaryLocationId,
      receiveSevereAlerts: receiveSevereAlerts ?? this.receiveSevereAlerts,
      receiveDailyWeather: receiveDailyWeather ?? this.receiveDailyWeather,
      receiveRiverLevelUpdates:
          receiveRiverLevelUpdates ?? this.receiveRiverLevelUpdates,
      locationPermissionGranted:
          locationPermissionGranted ?? this.locationPermissionGranted,
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      bloodGroup: json['blood_group'] ?? '',
      primaryLocationId: json['primary_location_id'] ?? 'patna_bihar',
      receiveSevereAlerts: json['receive_severe_alerts'] ?? true,
      receiveDailyWeather: json['receive_daily_weather'] ?? true,
      receiveRiverLevelUpdates: json['receive_river_level_updates'] ?? true,
      locationPermissionGranted: json['location_permission_granted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'blood_group': bloodGroup,
        'primary_location_id': primaryLocationId,
        'receive_severe_alerts': receiveSevereAlerts,
        'receive_daily_weather': receiveDailyWeather,
        'receive_river_level_updates': receiveRiverLevelUpdates,
        'location_permission_granted': locationPermissionGranted,
      };
}

