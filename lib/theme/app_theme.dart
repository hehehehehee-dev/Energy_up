import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared colors used throughout the app (ported from the prototype).
class AppColors {
  static const Color text = Color(0xFF3D3454);
  static const Color textSoft = Color(0xFF5A4A6A);
  static const Color muted = Color(0xFF8B7FA8);
  static const Color muted2 = Color(0xFFB0A8C8);
  static const Color muted3 = Color(0xFFC0B8D8);
  static const Color lavender = Color(0xFF9B8FCC);
  static const Color lavenderLight = Color(0xFFC4B0E8);
  static const Color lavender2 = Color(0xFFC4B8E8);
  static const Color pink = Color(0xFFC47898);
  static const Color pinkLight = Color(0xFFF4B8CC);
  static const Color teal = Color(0xFF4A9A8A);
  static const Color tealSoft = Color(0xFFA8DDD1);
  static const Color gold = Color(0xFFA07840);
  static const Color goldLight = Color(0xFFF5C4A0);
  static const Color aboveText = Color(0xFF3A8A7A);
  static const Color belowText = Color(0xFF7060AA);
  static const Color canvas = Color(0xFFFAF8F5);
}

/// Parse a `#RRGGBB` (or `#AARRGGBB`) string into a [Color].
Color hexToColor(String hex) {
  var h = hex.replaceAll('#', '').trim();
  if (h.length == 6) h = 'FF$h';
  return Color(int.parse(h, radix: 16));
}

/// Apply a 2-digit hex alpha suffix (e.g. "40") to a color — mirrors the
/// `${color}40` pattern used in the original CSS.
Color withHexAlpha(Color c, String aa) =>
    c.withOpacity(int.parse(aa, radix: 16) / 255);

/// Typography helpers — Playfair Display (serif) + DM Sans (sans).
class AppText {
  static TextStyle serif({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.text,
    double? height,
    FontStyle? style,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        fontStyle: style,
      );

  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.text,
    double? height,
    double? letterSpacing,
    FontStyle? style,
  }) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: style,
      );
}
