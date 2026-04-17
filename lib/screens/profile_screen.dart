import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../providers/auth_state.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';
import 'settings_screen.dart';
import 'onboarding_screen.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, AuthStateProvider>(
      builder: (ctx, state, auth, _) {
        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, auth),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildUserInfo(auth),
                      const SizedBox(height: 24),
                      _buildStatsRow(),
                      const SizedBox(height: 24),
                      _buildSeatCard(context, state),
                      const SizedBox(height: 24),
                      _buildMenuSection(context),
                      const SizedBox(height: 32),
                      _buildSignOutButton(context, auth),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Header/AppBar ────────────────────────────────────────────────────────
  SliverAppBar _buildSliverAppBar(BuildContext context, AuthStateProvider auth) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppTheme.surface,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: AppTheme.onSurface),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Dark gradient cover
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F131F),
                    Color(0xFF161E33),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Decorative stadium watermark
            Positioned(
              right: -30,
              bottom: -40,
              child: Icon(
                Icons.stadium_rounded,
                size: 160,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
            // Avatar positioned at the bottom overlapping the content gracefully
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: auth.photoUrl != null && !auth.isAnonymous
                    ? ClipOval(
                        child: Image.network(
                          auth.photoUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _initialsAvatar(auth.initials),
                        ),
                      )
                    : _initialsAvatar(auth.initials),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initialsAvatar(String initials) {
    return Container(
      width: 80,
      height: 80,
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
            fontSize: 28,
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }

  // ── User Info ─────────────────────────────────────────────────────────────
  Widget _buildUserInfo(AuthStateProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              auth.displayName,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 12),
            if (auth.isAnonymous)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.tertiary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'GUEST',
                  style: GoogleFonts.inter(
                    color: AppTheme.tertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          auth.isAnonymous ? 'Sign in to save your preferences' : (auth.email ?? 'Member'),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.outline,
          ),
        ),
      ],
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Events\nAttended',
            value: '4',
            icon: Icons.confirmation_num_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Vantage\nPoints',
            value: '1,250',
            icon: Icons.stars_rounded,
            isHighlight: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Loyalty\nTier',
            value: 'Gold',
            icon: Icons.shield_rounded,
          ),
        ),
      ],
    );
  }

  // ── Seat Card ─────────────────────────────────────────────────────────────
  Widget _buildSeatCard(BuildContext context, AppState state) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chair_rounded, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Seat',
                  style: GoogleFonts.inter(
                    color: AppTheme.outline,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.seatLabel.isEmpty ? 'Not Selected' : state.seatLabel,
                  style: GoogleFonts.inter(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'Change your seat selection',
            button: true,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Text(
                'Change',
                style: GoogleFonts.inter(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  // ── Menu Section ──────────────────────────────────────────────────────────
  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _MenuItem(
          icon: Icons.history_rounded,
          title: 'Order History',
          subtitle: 'View past food and drink orders',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
            );
          },
        ),
        _MenuItem(
          icon: Icons.payment_rounded,
          title: 'Payment Methods',
          subtitle: 'Manage cards and Apple/Google Pay',
          onTap: () {},
        ),
        _MenuItem(
          icon: Icons.favorite_rounded,
          title: 'Favourites',
          subtitle: 'Your saved dishes and locations',
          onTap: () {},
        ),
      ],
    );
  }

  // ── Sign Out Button ───────────────────────────────────────────────────────
  Widget _buildSignOutButton(BuildContext context, AuthStateProvider auth) {
    final isGuest = auth.isAnonymous;
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: () async {
          if (isGuest) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(pageBuilder: (_, __, ___) => const LoginScreen()),
            );
          } else {
            await auth.signOut();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(pageBuilder: (_, __, ___) => const LoginScreen()),
                (route) => false,
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isGuest ? AppTheme.primary.withOpacity(0.3) : AppTheme.error.withOpacity(0.3),
            ),
            color: isGuest ? AppTheme.primary.withOpacity(0.05) : AppTheme.error.withOpacity(0.05),
          ),
          child: Text(
            isGuest ? 'Sign In / Create Account' : 'Sign Out',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: isGuest ? AppTheme.primary : AppTheme.error,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Components ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlight;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isHighlight ? AppTheme.primary.withOpacity(0.1) : AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight ? AppTheme.primary.withOpacity(0.2) : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isHighlight ? AppTheme.primary : AppTheme.outline,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.onSurfaceVariant,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.onSurface, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.outline, size: 20),
          ],
        ),
      ),
    );
  }
}
