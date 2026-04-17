import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../providers/auth_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppTheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<AppState, AuthStateProvider>(
        builder: (ctx, state, auth, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              _buildAccountHeader(auth),
              const SizedBox(height: 32),
              _SectionLabel('PREFERENCES'),
              const SizedBox(height: 12),
              _buildPrefsCard(state),
              const SizedBox(height: 32),
              _SectionLabel('SECURITY'),
              const SizedBox(height: 12),
              _buildSecurityCard(),
              const SizedBox(height: 32),
              _SectionLabel('SUPPORT & LEGAL'),
              const SizedBox(height: 12),
              _buildSupportCard(context),
              const SizedBox(height: 40),
              _buildSignOutButton(context, auth),
              const SizedBox(height: 48),
              _buildVersionInfo(),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  // ── Account Header ────────────────────────────────────────────────────────
  Widget _buildAccountHeader(AuthStateProvider auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: AppTheme.ctaGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                auth.initials,
                style: GoogleFonts.inter(
                  color: AppTheme.onPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.displayName,
                  style: GoogleFonts.inter(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                Text(
                  auth.email ?? (auth.isAnonymous ? 'Guest Account' : 'Member'),
                  style: GoogleFonts.inter(
                    color: AppTheme.outline,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _ActionChip(label: 'EDIT', onTap: () {}),
        ],
      ),
    );
  }

  // ── Preferences Card ──────────────────────────────────────────────────────
  Widget _buildPrefsCard(AppState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _ToggleTile(
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            subtitle: 'OLED optimized appearance',
            value: state.isDarkMode,
            onChanged: (_) => state.toggleTheme(),
          ),
          _divider(),
          _ToggleTile(
            icon: Icons.notifications_active_rounded,
            title: 'Push Notifications',
            subtitle: 'Crowd and event alerts',
            value: state.notificationsEnabled,
            onChanged: (v) => state.toggleNotifications(v),
          ),
          _divider(),
          _ToggleTile(
            icon: Icons.vibration_rounded,
            title: 'Haptic Feedback',
            subtitle: 'Tactile app responses',
            value: state.hapticsEnabled,
            onChanged: (v) => state.toggleHaptics(v),
          ),
        ],
      ),
    );
  }

  // ── Security Card ─────────────────────────────────────────────────────────
  Widget _buildSecurityCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Lock',
            subtitle: 'Require FaceID/Fingerprint',
            trailing: Switch(
              value: false,
              onChanged: (_) {},
              activeColor: AppTheme.primary,
            ),
          ),
          _divider(),
          _MenuTile(
            icon: Icons.lock_outline_rounded,
            title: 'Privacy Settings',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ── Support Card ──────────────────────────────────────────────────────────
  Widget _buildSupportCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.help_outline_rounded,
            title: 'Help Center',
            onTap: () {},
          ),
          _divider(),
          _MenuTile(
            icon: Icons.contact_support_outlined,
            title: 'Contact Support',
            onTap: () {},
          ),
          _divider(),
          _MenuTile(
            icon: Icons.policy_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, AuthStateProvider auth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextButton(
        onPressed: () async {
          await auth.signOut();
          if (context.mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppTheme.error.withOpacity(0.2)),
          ),
        ),
        child: Text(
          auth.isAnonymous ? 'Exit Guest Mode' : 'Sign Out',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        Text(
          'VenueVantage Pro',
          style: GoogleFonts.inter(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version 1.0.4 • Made for Stadium Enthusiasts',
          style: GoogleFonts.inter(color: AppTheme.outline, fontSize: 11),
        ),
      ],
    );
  }

  Widget _divider() => Divider(
    height: 1,
    color: AppTheme.outlineVariant.withOpacity(0.05),
    indent: 56,
  );
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

class _ActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: AppTheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: GoogleFonts.inter(color: AppTheme.outline, fontSize: 11),
            )
          : null,
      trailing:
          trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.outlineVariant,
            size: 20,
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
