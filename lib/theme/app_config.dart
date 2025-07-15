import 'package:flutter/material.dart';

class AppConfig {
  // ─── App Info ───────────────────────────────────────────────
  static const String appName = 'Flight Tickets';

  // ─── Basic Theme Colors ─────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color backgroundColor = background; // Alias for legacy use

  static const Color surface = Color(0xFFF9F9F9); // Very Light Gray
  static const Color textMain = Color(0xFF000000); // Black
  static const Color textMuted = Color(0xFF666666); // Medium Gray
  static const Color divider = Color(0xFFDDDDDD); // Light Divider
  static const Color gray = Color(0xFFCCCCCC); // General Gray

  static const Color borderColor = divider; // Alias for legacy use
  static const Color primaryAccent = Color(0xFF444444); // Dark Gray Accent

  // ─── Action Colors ──────────────────────────────────────────
  static const Color danger = Color(0xFFB00020); // Red for delete
  static const Color success = Color(0xFF2E7D32); // Green for success

  // ─── Typography ─────────────────────────────────────────────
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textMain,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textMain,
  );

  static const TextStyle body = TextStyle(fontSize: 14, color: textMain);

  static const TextStyle label = TextStyle(fontSize: 12, color: textMuted);

  // ─── Layout ─────────────────────────────────────────────────
  static const double borderRadius = 12.0;
  static const double elevation = 2.0;
}
