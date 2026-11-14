import 'package:flutter/material.dart';

/// Professional color palette tailored for an emergency management application.
/// Uses deep ocean blues as primary branding, with strict color-coded
/// risk indicators matching NDMA / international disaster guidelines.
class AppColors {
  // Brand Primary & Surface
  static const Color primary = Color(0xFF0D47A1); // Deep Ocean Blue
  static const Color primaryDark = Color(0xFF002171);
  static const Color primaryLight = Color(0xFF5472D3);
  static const Color secondary = Color(0xFF0288D1); // Marine Blue Accent
  static const Color secondaryLight = Color(0xFFE1F5FE);

  // Backgrounds & Surfaces
  static const Color backgroundLight = Color(0xFFF5F8FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFEEF2F8);

  static const Color backgroundDark = Color(0xFF0A192F); // Deep Navy
  static const Color surfaceDark = Color(0xFF112240);
  static const Color surfaceDarkElevated = Color(0xFF1E3A8A);

  // Risk Level Colors (Strictly according to requirements)
  // Green: Low Risk
  static const Color riskLow = Color(0xFF2E7D32);
  static const Color riskLowBg = Color(0xFFE8F5E9);
  static const Color riskLowBorder = Color(0xFFA5D6A7);

  // Yellow: Moderate Risk
  static const Color riskModerate = Color(0xFFF57F17);
  static const Color riskModerateBg = Color(0xFFFFFDE7);
  static const Color riskModerateBorder = Color(0xFFFFF59D);

  // Orange: High Risk
  static const Color riskHigh = Color(0xFFE65100);
  static const Color riskHighBg = Color(0xFFFFF3E0);
  static const Color riskHighBorder = Color(0xFFFFCC80);

  // Red: Severe Risk
  static const Color riskSevere = Color(0xFFC62828);
  static const Color riskSevereBg = Color(0xFFFFEBEE);
  static const Color riskSevereBorder = Color(0xFFEF9A9A);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF5A6A80);
  static const Color textMuted = Color(0xFF8C9BAE);
  static const Color textOnPrimary = Colors.white;

  // Status & Utility
  static const Color info = Color(0xFF0288D1);
  static const Color warning = Color(0xFFED6C02);
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color divider = Color(0xFFE2E8F0);
}

