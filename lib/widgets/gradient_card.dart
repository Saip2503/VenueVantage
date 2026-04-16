import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Opaque gradient card — kept for intentional use cases like event banners
/// where a solid rich gradient is required.
///
/// For frosted-glass panels, use [GlassCard] instead.
class GradientCard extends StatelessWidget {
  final Widget child;
  final LinearGradient? gradient;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        // Ghost border only — no solid 1px lines per Stitch "No-Line" rule
        border: Border.all(
          color: AppTheme.outlineVariant.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
