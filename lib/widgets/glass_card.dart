import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Stitch Signature GlassCard.
///
/// Renders the "Atmospheric Depth" panel used for primary cards and modals:
///   - 5 % white opacity fill
///   - BackdropFilter blur (12–20 px)
///   - Ghost border: outlineVariant @ 15 % opacity
///   - Minimum 24 px content padding (per Stitch spec)
class GlassCard extends StatelessWidget {
  final Widget child;

  /// Inner content padding — spec minimum is 24 px.
  final EdgeInsetsGeometry padding;

  /// Corner radius. Stitch default = 4px (ROUND_FOUR).
  final double borderRadius;

  /// Backdrop blur sigma. Spec range: 12–20 px.
  final double blurSigma;

  /// Optional extra tint color (e.g. accent) applied at very low opacity.
  final Color? tint;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 4,
    this.blurSigma = 14,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint != null
                ? tint!.withOpacity(0.07)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppTheme.outlineVariant.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
