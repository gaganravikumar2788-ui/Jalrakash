import '../core/utils/risk_level_helper.dart';

class FloodRiskModel {
  final String locationId;
  final String locationName;
  final String riverBasin;
  final RiskLevel riskLevel;
  final int riskScore; // 0 - 100
  final double rainfall24hMm;
  final double rainfall48hPredictedMm;
  final RiverGaugeData? riverGauge;
  final double soilSaturationPercent; // 0 - 100%
  final String riskExplanation;
  final PredictionUncertainty uncertainty;
  final bool isDemonstrationData;
  final String dataSource;
  final DateTime lastUpdated;

  FloodRiskModel({
    required this.locationId,
    required this.locationName,
    required this.riverBasin,
    required this.riskLevel,
    required this.riskScore,
    required this.rainfall24hMm,
    required this.rainfall48hPredictedMm,
    this.riverGauge,
    required this.soilSaturationPercent,
    required this.riskExplanation,
    required this.uncertainty,
    this.isDemonstrationData = true,
    required this.dataSource,
    required this.lastUpdated,
  });

  factory FloodRiskModel.fromJson(Map<String, dynamic> json) {
    return FloodRiskModel(
      locationId: json['location_id'] ?? '',
      locationName: json['location_name'] ?? '',
      riverBasin: json['river_basin'] ?? '',
      riskLevel: RiskLevel.fromString(json['risk_level']),
      riskScore: json['risk_score'] ?? 0,
      rainfall24hMm: (json['rainfall_24h_mm'] as num?)?.toDouble() ?? 0.0,
      rainfall48hPredictedMm:
          (json['rainfall_48h_predicted_mm'] as num?)?.toDouble() ?? 0.0,
      riverGauge: json['river_gauge'] != null
          ? RiverGaugeData.fromJson(json['river_gauge'])
          : null,
      soilSaturationPercent:
          (json['soil_saturation_percent'] as num?)?.toDouble() ?? 50.0,
      riskExplanation: json['risk_explanation'] ?? '',
      uncertainty: json['uncertainty'] != null
          ? PredictionUncertainty.fromJson(json['uncertainty'])
          : PredictionUncertainty.defaultModel(),
      isDemonstrationData: json['is_demonstration_data'] ?? true,
      dataSource: json['data_source'] ??
          'Central Water Commission (CWC) & ML Hydrology Model',
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'location_id': locationId,
        'location_name': locationName,
        'river_basin': riverBasin,
        'risk_level': riskLevel.shortLabel,
        'risk_score': riskScore,
        'rainfall_24h_mm': rainfall24hMm,
        'rainfall_48h_predicted_mm': rainfall48hPredictedMm,
        'river_gauge': riverGauge?.toJson(),
        'soil_saturation_percent': soilSaturationPercent,
        'risk_explanation': riskExplanation,
        'uncertainty': uncertainty.toJson(),
        'is_demonstration_data': isDemonstrationData,
        'data_source': dataSource,
        'last_updated': lastUpdated.toIso8601String(),
      };
}

class RiverGaugeData {
  final String riverName;
  final String stationName;
  final double currentLevelMeters;
  final double warningLevelMeters;
  final double dangerLevelMeters;
  final double highestFloodLevelMeters;
  final String trend; // "RISING", "FALLING", "STEADY"

  RiverGaugeData({
    required this.riverName,
    required this.stationName,
    required this.currentLevelMeters,
    required this.warningLevelMeters,
    required this.dangerLevelMeters,
    required this.highestFloodLevelMeters,
    required this.trend,
  });

  bool get isAboveDangerLevel => currentLevelMeters >= dangerLevelMeters;
  bool get isAboveWarningLevel => currentLevelMeters >= warningLevelMeters;

  factory RiverGaugeData.fromJson(Map<String, dynamic> json) {
    return RiverGaugeData(
      riverName: json['river_name'] ?? '',
      stationName: json['station_name'] ?? '',
      currentLevelMeters:
          (json['current_level_meters'] as num?)?.toDouble() ?? 0.0,
      warningLevelMeters:
          (json['warning_level_meters'] as num?)?.toDouble() ?? 0.0,
      dangerLevelMeters:
          (json['danger_level_meters'] as num?)?.toDouble() ?? 0.0,
      highestFloodLevelMeters:
          (json['highest_flood_level_meters'] as num?)?.toDouble() ?? 0.0,
      trend: json['trend'] ?? 'STEADY',
    );
  }

  Map<String, dynamic> toJson() => {
        'river_name': riverName,
        'station_name': stationName,
        'current_level_meters': currentLevelMeters,
        'warning_level_meters': warningLevelMeters,
        'danger_level_meters': dangerLevelMeters,
        'highest_flood_level_meters': highestFloodLevelMeters,
        'trend': trend,
      };
}

class PredictionUncertainty {
  final double confidenceScore; // 0.0 to 1.0 (e.g. 0.88 = 88%)
  final double lowerBoundScore;
  final double upperBoundScore;
  final String modelName;
  final String uncertaintyDescription;

  PredictionUncertainty({
    required this.confidenceScore,
    required this.lowerBoundScore,
    required this.upperBoundScore,
    required this.modelName,
    required this.uncertaintyDescription,
  });

  factory PredictionUncertainty.defaultModel() {
    return PredictionUncertainty(
      confidenceScore: 0.85,
      lowerBoundScore: 68.0,
      upperBoundScore: 84.0,
      modelName: 'Hydrological Ensemble ML v2.4 (Gradient Boosting + LSTM)',
      uncertaintyDescription:
          'Prediction interval at 90% confidence level based on 48h rainfall ensemble forecasts and upstream discharge.',
    );
  }

  factory PredictionUncertainty.fromJson(Map<String, dynamic> json) {
    return PredictionUncertainty(
      confidenceScore:
          (json['confidence_score'] as num?)?.toDouble() ?? 0.85,
      lowerBoundScore:
          (json['lower_bound_score'] as num?)?.toDouble() ?? 60.0,
      upperBoundScore:
          (json['upper_bound_score'] as num?)?.toDouble() ?? 85.0,
      modelName: json['model_name'] ?? 'Hydrological Ensemble ML v2.4',
      uncertaintyDescription: json['uncertainty_description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'confidence_score': confidenceScore,
        'lower_bound_score': lowerBoundScore,
        'upper_bound_score': upperBoundScore,
        'model_name': modelName,
        'uncertainty_description': uncertaintyDescription,
      };
}

