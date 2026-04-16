import 'package:flutter/material.dart';

class AppTheme {
  // ── Surface Architecture (Stitch "No-Line" tonal layers) ──────────────────
  static const Color surfaceLowest         = Color(0xFF0A0E1A); // base canvas
  static const Color surface               = Color(0xFF0F131F); // primary app bg
  static const Color surfaceContainerLow   = Color(0xFF171B28);
  static const Color surfaceContainer      = Color(0xFF1B1F2C); // cards
  static const Color surfaceContainerHigh  = Color(0xFF262A37); // active states
  static const Color surfaceContainerHighest = Color(0xFF313442); // elevated panels
  static const Color surfaceBright         = Color(0xFF353946);

  // ── Primary blue system ───────────────────────────────────────────────────
  static const Color primary               = Color(0xFFADC6FF); // pastel blue
  static const Color primaryContainer      = Color(0xFF4D8EFF); // vibrant blue
  static const Color onPrimary             = Color(0xFF002E6A);
  static const Color onPrimaryContainer    = Color(0xFF00285D);
  static const Color onPrimaryFixed        = Color(0xFF001A42);
  static const Color inversePrimary        = Color(0xFF005AC2);

  // ── Secondary ─────────────────────────────────────────────────────────────
  static const Color secondary             = Color(0xFFB1C6F9);
  static const Color secondaryContainer    = Color(0xFF304671);
  static const Color onSecondary           = Color(0xFF182F59);
  static const Color onSecondaryContainer  = Color(0xFF9FB5E7);

  // ── Tertiary (warm amber — replaces accentAmber) ──────────────────────────
  static const Color tertiary              = Color(0xFFFFB786);
  static const Color tertiaryContainer     = Color(0xFFDF7412);
  static const Color onTertiary            = Color(0xFF502400);

  // ── On-surface / Text ─────────────────────────────────────────────────────
  static const Color onSurface            = Color(0xFFDFE2F3); // primary text
  static const Color onSurfaceVariant     = Color(0xFFC2C6D6); // secondary text
  static const Color outline              = Color(0xFF8C909F); // muted / ghost borders
  static const Color outlineVariant       = Color(0xFF424754); // divider fallback

  // ── Error ─────────────────────────────────────────────────────────────────
  static const Color error                = Color(0xFFFFB4AB);
  static const Color errorContainer       = Color(0xFF93000A);
  static const Color onError              = Color(0xFF690005);

  // ── Legacy aliases (for components not yet migrated) ─────────────────────
  /// @deprecated Use [surfaceLowest] instead
  static const Color bgDark       = surfaceLowest;
  /// @deprecated Use [surfaceContainer] instead
  static const Color bgCard       = surfaceContainer;
  /// @deprecated Use [surfaceContainerHigh] instead
  static const Color bgElevated   = surfaceContainerHigh;
  /// @deprecated Use [surfaceContainerHighest] instead
  static const Color bgSurface    = surfaceContainerHighest;
  static const Color bgLight      = Color(0xFFF1F5F9);
  static const Color bgCardLight  = Color(0xFFFFFFFF);
  static const Color bgElevatedLight = Color(0xFFE2E8F0);
  static const Color bgSurfaceLight  = Color(0xFFCBD5E1);

  /// @deprecated Use [primary] instead
  static const Color accentBlue   = Color(0xFF3B82F6);
  static const Color accentCyan   = Color(0xFF06B6D4);
  static const Color accentGreen  = Color(0xFF10B981);
  /// @deprecated Use [tertiary] instead
  static const Color accentAmber  = tertiary;
  static const Color accentRed    = error;
  static const Color accentPurple = Color(0xFF8B5CF6);

  /// @deprecated Use [onSurface] instead
  static const Color textPrimary       = onSurface;
  /// @deprecated Use [onSurfaceVariant] instead
  static const Color textSecondary     = onSurfaceVariant;
  /// @deprecated Use [outline] instead
  static const Color textMuted         = outline;
  static const Color textPrimaryLight  = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight    = Color(0xFF94A3B8);

  /// @deprecated — use tonal shifts instead of borders
  static const Color borderColor      = outlineVariant;
  static const Color borderColorLight = Color(0xFFE2E8F0);

  // ── Context-aware helpers ─────────────────────────────────────────────────
  static Color bg(bool dark)       => dark ? surface : bgLight;
  static Color card(bool dark)     => dark ? surfaceContainer : bgCardLight;
  static Color elevated(bool dark) => dark ? surfaceContainerHigh : bgElevatedLight;
  static Color sfc(bool dark)      => dark ? surfaceContainerHighest : bgSurfaceLight;
  // Keep old name for compat
  static Color surface_(bool dark) => sfc(dark);
  static Color textPrim(bool dark) => dark ? onSurface : textPrimaryLight;
  static Color textSec(bool dark)  => dark ? onSurfaceVariant : textSecondaryLight;
  static Color textMut(bool dark)  => dark ? outline : textMutedLight;
  static Color border(bool dark)   => dark ? outlineVariant : borderColorLight;

  // ── Gradients ─────────────────────────────────────────────────────────────

  /// Stitch Signature CTA Gradient — primary → primaryContainer at 135°
  static const LinearGradient ctaGradient = LinearGradient(
    colors: [Color(0xFFADC6FF), Color(0xFF4D8EFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Deep midnight gradient for event banners
  static const LinearGradient eventBannerGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient   = LinearGradient(
    colors: [Color(0xFFADC6FF), Color(0xFF4D8EFF)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient greenGradient  = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient amberGradient  = LinearGradient(
    colors: [Color(0xFFFFB786), Color(0xFFDF7412)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient redGradient    = LinearGradient(
    colors: [Color(0xFFFFB4AB), Color(0xFF93000A)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradient   = LinearGradient(
    colors: [Color(0xFF1B1F2C), Color(0xFF0F131F)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  // ── Glassmorphism ─────────────────────────────────────────────────────────

  /// Stitch Signature GlassCard decoration.
  /// Wrap with ClipRRect + BackdropFilter for full effect.
  static BoxDecoration glassDecoration({double borderRadius = 4}) =>
      BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: outlineVariant.withOpacity(0.15),
          width: 1,
        ),
      );

  /// Ambient "tinted glow-under" shadow — use for popovers/tooltips only
  static List<BoxShadow> ambientShadow() => [
    BoxShadow(
      color: surfaceLowest.withOpacity(0.6),
      blurRadius: 40,
      spreadRadius: -5,
    ),
  ];

  // ── Label text style ──────────────────────────────────────────────────────

  /// Stitch label-sm: UPPERCASE + 0.05em tracking — for status chips & readouts
  static TextStyle labelSmStyle({Color? color}) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05 * 10,
    color: color ?? onSurfaceVariant,
  );

  // ── Material Themes ───────────────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: surface,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surfaceContainer,
      onSurface: onSurface,
      error: error,
      tertiary: tertiary,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgLight,
    colorScheme: const ColorScheme.light(
      primary: accentBlue,
      secondary: accentCyan,
      surface: bgCardLight,
      onSurface: textPrimaryLight,
    ),
  );
}
