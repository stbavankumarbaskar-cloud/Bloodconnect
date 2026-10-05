import 'package:flutter/material.dart';

class AppColors {
  // Primary Healthcare Blood Red Palette
  static const Color primary = Color(0xFFD32F2F);       // Vibrant Medical Red
  static const Color primaryDark = Color(0xFFB71C1C);   // Deep Crimson Red
  static const Color primaryLight = Color(0xFFFFCDD2);  // Soft Blood Tint
  static const Color primarySoft = Color(0xFFFFEBEE);   // Ultra Light Red BG

  // Status Colors
  static const Color availableGreen = Color(0xFF2E7D32); // 6+ Months Eligible
  static const Color availableGreenLight = Color(0xFFE8F5E9);
  static const Color recentlyDonatedRed = Color(0xFFC62828); // < 6 Months Ineligible
  static const Color recentlyDonatedRedLight = Color(0xFFFFEBEE);
  static const Color busyOrange = Color(0xFFEF6C00);
  static const Color busyOrangeLight = Color(0xFFFFF3E0);

  // Urgency Colors
  static const Color criticalUrgency = Color(0xFFD50000);
  static const Color highUrgency = Color(0xFFFF6D00);
  static const Color standardUrgency = Color(0xFF0288D1);

  // Neutral Background & Surface Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color cardBorder = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Typography Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color textWhite = Colors.white;

  // Accents
  static const Color whatsappGreen = Color(0xFF25D366);
  static const Color callBlue = Color(0xFF1976D2);
  static const Color starAmber = Color(0xFFFFA000);
}
