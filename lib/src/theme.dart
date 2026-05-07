import 'package:flutter/material.dart';

class ZennoTheme {
  // Primary colors
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryCyan = Color(0xFF06B6D4);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color darkBg = Color(0xFF0F172A);
  static const Color lightBg = Color(0xFFFAFAFA);
  
  // Gradients
  static const LinearGradient gamingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E3A8A),
      Color(0xFF0F172A),
    ],
  );
  
  // Text styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryBlue,
    letterSpacing: 2,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryBlue,
    letterSpacing: 1.5,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: primaryBlue,
    letterSpacing: 1,
  );
  
  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: Colors.white,
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: Color(0xFFAAAAAA),
    fontWeight: FontWeight.w400,
  );
}
