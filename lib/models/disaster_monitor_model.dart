import 'package:flutter/material.dart';
import '../core/utils/risk_level_helper.dart';

enum DisasterType {
  flood,
  earthquake,
  landslide,
  cyclone,
  heatwave,
  drought,
  thunderstormLightning,
  tsunami,
  forestFire;

  String get displayName {
    switch (this) {
      case DisasterType.flood:
        return 'Floods & Inundation';
      case DisasterType.earthquake:
        return 'Earthquakes (Seismic)';
      case DisasterType.landslide:
        return 'Landslides & Debris Flow';
      case DisasterType.cyclone:
        return 'Tropical Cyclones';
      case DisasterType.heatwave:
        return 'Heatwaves & Thermal Stress';
      case DisasterType.drought:
        return 'Drought & Water Scarcity';
      case DisasterType.thunderstormLightning:
        return 'Thunderstorms & Lightning';
      case DisasterType.tsunami:
        return 'Tsunami & Coastal Surges';
      case DisasterType.forestFire:
        return 'Forest Fires & Wildfires';
    }
  }

  IconData get icon {
    switch (this) {
      case DisasterType.flood:
        return Icons.flood_rounded;
      case DisasterType.earthquake:
        return Icons.vibration_rounded;
      case DisasterType.landslide:
        return Icons.landscape_rounded;
      case DisasterType.cyclone:
        return Icons.cyclone_rounded;
      case DisasterType.heatwave:
        return Icons.wb_sunny_rounded;
      case DisasterType.drought:
        return Icons.water_damage_outlined;
      case DisasterType.thunderstormLightning:
        return Icons.flash_on_rounded;
      case DisasterType.tsunami:
        return Icons.tsunami_rounded;
      case DisasterType.forestFire:
        return Icons.local_fire_department_rounded;
    }
  }

  Color get iconColor {
    switch (this) {
      case DisasterType.flood:
        return const Color(0xFF1976D2);
      case DisasterType.earthquake:
        return const Color(0xFF8D6E63);
      case DisasterType.landslide:
        return const Color(0xFF795548);
      case DisasterType.cyclone:
        return const Color(0xFF0097A7);
      case DisasterType.heatwave:
        return const Color(0xFFF57C00);
      case DisasterType.drought:
        return const Color(0xFFFFA000);
      case DisasterType.thunderstormLightning:
        return const Color(0xFFFBC02D);
      case DisasterType.tsunami:
        return const Color(0xFF0288D1);
      case DisasterType.forestFire:
        return const Color(0xFFD32F2F);
    }
  }
}

class DisasterMonitorModel {
  final DisasterType type;
  final RiskLevel severity;
  final bool hasActiveVerifiedWarning; // True only when official backend telemetry exists
  final String statusSummary;
  final String affectedRegions;
  final String safetyAdvisory;
  final String reportingAgency;
  final DateTime lastChecked;

  DisasterMonitorModel({
    required this.type,
    required this.severity,
    required this.hasActiveVerifiedWarning,
    required this.statusSummary,
    required this.affectedRegions,
    required this.safetyAdvisory,
    required this.reportingAgency,
    required this.lastChecked,
  });

  factory DisasterMonitorModel.fromJson(Map<String, dynamic> json) {
    return DisasterMonitorModel(
      type: DisasterType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DisasterType.flood,
      ),
      severity: RiskLevel.fromString(json['severity']),
      hasActiveVerifiedWarning: json['has_active_verified_warning'] ?? false,
      statusSummary: json['status_summary'] ?? '',
      affectedRegions: json['affected_regions'] ?? '',
      safetyAdvisory: json['safety_advisory'] ?? '',
      reportingAgency: json['reporting_agency'] ?? 'NDMA',
      lastChecked: json['last_checked'] != null
          ? DateTime.parse(json['last_checked'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'severity': severity.shortLabel,
        'has_active_verified_warning': hasActiveVerifiedWarning,
        'status_summary': statusSummary,
        'affected_regions': affectedRegions,
        'safety_advisory': safetyAdvisory,
        'reporting_agency': reportingAgency,
        'last_checked': lastChecked.toIso8601String(),
      };
}

