import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../providers/auth_state.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer2<AppState, AuthStateProvider>(
        builder: (ctx, state, auth, _) {
          return CustomScrollView(
            slivers: [
              _buildHeader(auth),
              _buildAccountSection(context, auth),
              _buildSeatSection(state),
              _buildPrefsSection(state),
              _buildAboutSection(context, auth),
            ],
          );
        },
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildHeader(AuthStateProvider auth) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.ctaGradient.createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text(
              'Settings',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.02 * 28,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Personalise your VenueVantage experience',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.outline,
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  // ── Account Section ───────────────────────────────────────────────────────
  SliverToBoxAdapter _buildAccountSection(
      BuildContext context, AuthStateProvider auth) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          _SectionLabel('ACCOUNT'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              // Avatar — Google photo or initials circle
              if (auth.photoUrl != null && !auth.isAnonymous)
                ClipOval(
                  child: Image.network(
                    auth.photoUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _initialsAvatar(auth.initials),
                  ),
                )
              else
                _initialsAvatar(auth.initials),

              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.displayName,
                      style: GoogleFonts.inter(
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (auth.isAnonymous)
                      _guestChip()
                    else
                      Text(
                        auth.email ?? '',
                        style: GoogleFonts.inter(
                          color: AppTheme.outline,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              // Sign-out ghost button
              GestureDetector(
                onTap: () => _signOut(context, auth),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppTheme.error.withOpacity(0.30),
                    ),
                  ),
                  child: Text(
                    auth.isAnonymous ? 'Sign In' : 'Sign Out',
                    style: GoogleFonts.inter(
                      color: AppTheme.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _initialsAvatar(String initials) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        gradient: AppTheme.ctaGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.inter(
            color: AppTheme.onPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _guestChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.tertiary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'GUEST MODE',
        style: GoogleFonts.inter(
          color: AppTheme.tertiary,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.05 * 9,
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, AuthStateProvider auth) async {
    if (auth.isAnonymous) {
      // Show login screen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
      return;
    }
    await auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    }
  }

  // ── Seat / Profile section ─────────────────────────────────────────────────
  SliverToBoxAdapter _buildSeatSection(AppState state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          _SectionLabel('MY LOCATION'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  gradient: AppTheme.ctaGradient,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: const Icon(Icons.chair_rounded,
                    color: AppTheme.onPrimary, size: 20),
              ),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Current Seat',
                  style: GoogleFonts.inter(
                    color: AppTheme.outline,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.05 * 11,
                  ),
                ),
                Text(
                  state.seatLabel.isEmpty ? '—' : state.seatLabel,
                  style: GoogleFonts.inter(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ]),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppTheme.outline.withOpacity(0.20),
                  ),
                ),
                child: Text(
                  'Change',
                  style: GoogleFonts.inter(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  // ── Preferences ────────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildPrefsSection(AppState state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          _SectionLabel('PREFERENCES'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(children: [
              _ToggleTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                subtitle: 'Toggle light / dark appearance',
                value: state.isDarkMode,
                onChanged: (_) => state.toggleTheme(),
              ),
              Container(
                  height: 1,
                  color: AppTheme.outlineVariant.withOpacity(0.10)),
              _ToggleTile(
                icon: Icons.notifications_active_rounded,
                title: 'Push Notifications',
                subtitle: 'Receive crowd and event alerts',
                value: true,
                onChanged: (_) {},
              ),
              Container(
                  height: 1,
                  color: AppTheme.outlineVariant.withOpacity(0.10)),
              _ToggleTile(
                icon: Icons.vibration_rounded,
                title: 'Haptic Feedback',
                subtitle: 'Vibrate on key interactions',
                value: false,
                onChanged: (_) {},
              ),
            ]),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  // ── About ──────────────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildAboutSection(
      BuildContext context, AuthStateProvider auth) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(children: [
          _SectionLabel('ABOUT'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppTheme.ctaGradient.createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      'VenueVantage',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'v1.0.0',
                      style: GoogleFonts.inter(
                        color: AppTheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.05 * 10,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(
                  'The Digital Executive Box for premium sporting events. Wayfinding, crowd intelligence, and in-seat ordering — all in one.',
                  style: GoogleFonts.inter(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: AppTheme.outline,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.05 * 10,
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppTheme.outline,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryContainer,
            activeTrackColor: AppTheme.primary.withOpacity(0.35),
            inactiveThumbColor: AppTheme.outline,
            inactiveTrackColor: AppTheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }
}
