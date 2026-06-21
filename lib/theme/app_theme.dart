import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared colors used throughout the app.
///
/// Warm, earthy palette — espresso ink on a soft cream canvas, with clay,
/// honey, dusty-rose and sage accents. Token *names* are kept (lavender, pink,
/// teal…) so every screen picks up the warmth automatically; only the values
/// changed from the original cool/pastel scheme.
class AppColors {
  static const Color text = Color(0xFF3E322A); // warm espresso
  static const Color textSoft = Color(0xFF5C4A3C);
  static const Color muted = Color(0xFF94806B);
  static const Color muted2 = Color(0xFFBCA992);
  static const Color muted3 = Color(0xFFD2C2AE);
  static const Color lavender = Color(0xFFC2895C); // primary accent → warm clay
  static const Color lavenderLight = Color(0xFFE6BE93); // sand
  static const Color lavender2 = Color(0xFFDDB792); // light clay
  static const Color pink = Color(0xFFC57E63); // dusty terracotta-rose
  static const Color pinkLight = Color(0xFFF1C3A8); // peach
  static const Color teal = Color(0xFF5E9E72); // sage (ties to the logo green)
  static const Color tealSoft = Color(0xFFBBD9A8); // soft sage
  static const Color gold = Color(0xFFB07A35); // honey
  static const Color goldLight = Color(0xFFF2C893);
  static const Color aboveText = Color(0xFF4E8A5A); // sage
  static const Color belowText = Color(0xFFA06A48); // warm brown
  static const Color canvas = Color(0xFFFAF1E5); // warm cream paper
  static const Color paper = Color(0xFFFFFBF4); // warm card surface (was cold white)
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

/// Typography helpers — Fraunces (warm, crafted serif) + Be Vietnam Pro (sans).
/// Be Vietnam Pro is designed for Vietnamese, so tone marks on ê/ô/ơ/ư render
/// fully and clearly (DM Sans dropped some at small sizes).
class AppText {
  static TextStyle serif({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.text,
    double? height,
    FontStyle? style,
  }) =>
      GoogleFonts.fraunces(
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
      GoogleFonts.beVietnamPro(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: style,
      );
}
