import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum RiskLevel {
  low,
  moderate,
  high,
  severe;

  static RiskLevel fromString(String? value) {
    if (value == null) return RiskLevel.low;
    switch (value.toUpperCase().trim()) {
      case 'SEVERE':
      case 'CRITICAL':
      case 'RED':
        return RiskLevel.severe;
      case 'HIGH':
      case 'ORANGE':
        return RiskLevel.high;
      case 'MODERATE':
      case 'MEDIUM':
      case 'YELLOW':
        return RiskLevel.moderate;
      case 'LOW':
      case 'GREEN':
      default:
        return RiskLevel.low;
    }
  }

  String get label {
    switch (this) {
      case RiskLevel.severe:
        return 'SEVERE RISK';
      case RiskLevel.high:
        return 'HIGH RISK';
      case RiskLevel.moderate:
        return 'MODERATE RISK';
      case RiskLevel.low:
        return 'LOW RISK';
    }
  }

  String get shortLabel {
    switch (this) {
      case RiskLevel.severe:
        return 'SEVERE';
      case RiskLevel.high:
        return 'HIGH';
      case RiskLevel.moderate:
        return 'MODERATE';
      case RiskLevel.low:
        return 'LOW';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevel.severe:
        return AppColors.riskSevere;
      case RiskLevel.high:
        return AppColors.riskHigh;
      case RiskLevel.moderate:
        return AppColors.riskModerate;
      case RiskLevel.low:
        return AppColors.riskLow;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case RiskLevel.severe:
        return AppColors.riskSevereBg;
      case RiskLevel.high:
        return AppColors.riskHighBg;
      case RiskLevel.moderate:
        return AppColors.riskModerateBg;
      case RiskLevel.low:
        return AppColors.riskLowBg;
    }
  }

  Color get borderColor {
    switch (this) {
      case RiskLevel.severe:
        return AppColors.riskSevereBorder;
      case RiskLevel.high:
        return AppColors.riskHighBorder;
      case RiskLevel.moderate:
        return AppColors.riskModerateBorder;
      case RiskLevel.low:
        return AppColors.riskLowBorder;
    }
  }

  IconData get icon {
    switch (this) {
      case RiskLevel.severe:
        return Icons.warning_rounded;
      case RiskLevel.high:
        return Icons.report_problem_rounded;
      case RiskLevel.moderate:
        return Icons.info_outline_rounded;
      case RiskLevel.low:
        return Icons.check_circle_outline_rounded;
    }
  }

  String get advisory {
    switch (this) {
      case RiskLevel.severe:
        return 'Immediate danger of flash flooding. Move to high ground immediately. Avoid all travel.';
      case RiskLevel.high:
        return 'River water levels approaching danger mark. Prepare emergency kit and stay alert for evacuation notice.';
      case RiskLevel.moderate:
        return 'Catchment rainfall active. Low-lying areas may experience waterlogging. Monitor bulletins.';
      case RiskLevel.low:
        return 'Normal hydrological conditions. No imminent flood risk detected in this basin.';
    }
  }
}

