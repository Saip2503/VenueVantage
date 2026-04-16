import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Stitch-aligned stat card.
///
/// Surface: [AppTheme.surfaceContainer] sitting on a [AppTheme.surfaceContainerLow]
/// parent — creates tonal lift without any borders.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final LinearGradient gradient;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), // min 24px per card spec; 16 for compact stat
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
        // No border — tonal separation from parent background handles depth
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, color: AppTheme.onPrimaryContainer, size: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Display value — tight letter-spacing per "Display" scale
          Text(
            value,
            style: GoogleFonts.inter(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.02 * 22,
            ),
          ),
          const SizedBox(height: 2),
          // Label — UPPERCASE + 0.05em tracking per "label-sm" spec
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              color: AppTheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              letterSpacing: 0.05 * 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.inter(
              color: AppTheme.outline,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
