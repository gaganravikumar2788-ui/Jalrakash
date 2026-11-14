import '../core/utils/risk_level_helper.dart';

class EmergencyAlertModel {
  final String id;
  final String title;
  final String description;
  final RiskLevel severity;
  final String affectedLocation;
  final String affectedDistrict;
  final String state;
  final DateTime issuedAt;
  final DateTime? validUntil;
  final String source; // e.g. "NDMA New Delhi", "IMD Flood Cell", "App AI Estimate"
  final bool isOfficialGovernmentWarning; // Crucial requirement
  final List<String> recommendedSafetyActions;
  final List<AlertUpdateHistory> updateHistory;
  final bool isUrgentEvacuation;

  EmergencyAlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.affectedLocation,
    required this.affectedDistrict,
    required this.state,
    required this.issuedAt,
    this.validUntil,
    required this.source,
    required this.isOfficialGovernmentWarning,
    required this.recommendedSafetyActions,
    this.updateHistory = const [],
    this.isUrgentEvacuation = false,
  });

  factory EmergencyAlertModel.fromJson(Map<String, dynamic> json) {
    return EmergencyAlertModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      severity: RiskLevel.fromString(json['severity']),
      affectedLocation: json['affected_location'] ?? '',
      affectedDistrict: json['affected_district'] ?? '',
      state: json['state'] ?? '',
      issuedAt: json['issued_at'] != null
          ? DateTime.parse(json['issued_at'])
          : DateTime.now(),
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'])
          : null,
      source: json['source'] ?? 'NDMA',
      isOfficialGovernmentWarning:
          json['is_official_government_warning'] ?? false,
      recommendedSafetyActions: List<String>.from(
          json['recommended_safety_actions'] ?? []),
      updateHistory: (json['update_history'] as List<dynamic>? ?? [])
          .map((e) => AlertUpdateHistory.fromJson(e))
          .toList(),
      isUrgentEvacuation: json['is_urgent_evacuation'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'severity': severity.shortLabel,
        'affected_location': affectedLocation,
        'affected_district': affectedDistrict,
        'state': state,
        'issued_at': issuedAt.toIso8601String(),
        'valid_until': validUntil?.toIso8601String(),
        'source': source,
        'is_official_government_warning': isOfficialGovernmentWarning,
        'recommended_safety_actions': recommendedSafetyActions,
        'update_history': updateHistory.map((e) => e.toJson()).toList(),
        'is_urgent_evacuation': isUrgentEvacuation,
      };
}

class AlertUpdateHistory {
  final DateTime timestamp;
  final String note;
  final String? revisedSeverity;

  AlertUpdateHistory({
    required this.timestamp,
    required this.note,
    this.revisedSeverity,
  });

  factory AlertUpdateHistory.fromJson(Map<String, dynamic> json) {
    return AlertUpdateHistory(
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      note: json['note'] ?? '',
      revisedSeverity: json['revised_severity'],
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'note': note,
        'revised_severity': revisedSeverity,
      };
}

