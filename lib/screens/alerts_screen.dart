import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  static const Map<AlertType, _AlertStyle> _styles = {
    AlertType.info: _AlertStyle(
      icon: Icons.info_rounded,
      color: AppTheme.primary,
      label: 'INFO',
    ),
    AlertType.warning: _AlertStyle(
      icon: Icons.warning_amber_rounded,
      color: AppTheme.tertiary,
      label: 'WARNING',
    ),
    AlertType.urgent: _AlertStyle(
      icon: Icons.error_rounded,
      color: AppTheme.error,
      label: 'URGENT',
    ),
    AlertType.success: _AlertStyle(
      icon: Icons.check_circle_rounded,
      color: AppTheme.accentGreen,
      label: 'UPDATE',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<AppState>(
        builder: (ctx, state, _) {
          return Column(
            children: [
              _buildHeader(state),
              Expanded(
                child: state.alerts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: state.alerts.length,
                        itemBuilder: (ctx, i) {
                          final alert =
                              state.alerts[state.alerts.length - 1 - i];
                          return _AlertCard(
                            alert: alert,
                            style: _styles[alert.type]!,
                            onTap: () => state.markAlertRead(alert.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppState state) {
    final unread = state.alerts.where((a) => !a.isRead).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.02 * 24,
                ),
              ),
              if (unread > 0)
                Text(
                  '$unread unread',
                  style: GoogleFonts.inter(
                    color: AppTheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.05 * 12,
                  ),
                ),
            ],
          ),
          const Spacer(),
          // Ghost style button — no fill, outline at 20% opacity
          if (unread > 0)
            GestureDetector(
              onTap: state.markAllRead,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppTheme.outline.withOpacity(0.20),
                  ),
                ),
                child: Text(
                  'Mark all read',
                  style: GoogleFonts.inter(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_off_rounded,
              size: 60, color: AppTheme.outline),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: GoogleFonts.inter(
              color: AppTheme.outline,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  final _AlertStyle style;
  final VoidCallback onTap;

  const _AlertCard({
    required this.alert,
    required this.style,
    required this.onTap,
  });

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Tonal shift only — no borders per "No-Line" rule
          // Unread: surfaceContainerHigh  |  Read: surfaceContainer
          color: alert.isRead
              ? AppTheme.surfaceContainer
              : AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(4),
          // Ambient shadow for unread (glow-under style, not floating)
          boxShadow: alert.isRead
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.surfaceLowest.withOpacity(0.60),
                    blurRadius: 40,
                    spreadRadius: -5,
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: style.color
                    .withOpacity(alert.isRead ? 0.08 : 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                style.icon,
                color: style.color
                    .withOpacity(alert.isRead ? 0.50 : 1.0),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: GoogleFonts.inter(
                            color: alert.isRead
                                ? AppTheme.onSurfaceVariant
                                : AppTheme.onSurface,
                            fontWeight: alert.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!alert.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: style.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    alert.body,
                    style: GoogleFonts.inter(
                      color: alert.isRead
                          ? AppTheme.outline
                          : AppTheme.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Venue Status Chip — pill shape, 15% opacity bg
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: style.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          style.label,
                          style: GoogleFonts.inter(
                            color: style.color,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.05 * 9,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timeAgo(alert.time),
                        style: GoogleFonts.inter(
                          color: AppTheme.outline,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertStyle {
  final IconData icon;
  final Color color;
  final String label;
  const _AlertStyle(
      {required this.icon, required this.color, required this.label});
}
