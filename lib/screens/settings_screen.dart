import 'package:flutter/foundation.dart';
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
    final state = context.watch<AppState>();
    final auth = context.watch<AuthStateProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18,
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(context, auth),
            const SizedBox(height: 32),
            _sectionTitle('Preferences'),
            _buildPrefsCard(state),
            const SizedBox(height: 24),
            _sectionTitle('Security'),
            _buildSecurityCard(),
            const SizedBox(height: 24),
            _sectionTitle('Support & Legal'),
            _buildSupportCard(),
            const SizedBox(height: 48),
            _buildSignOutButton(context, auth),
            const SizedBox(height: 32),
            _buildVersionInfo(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          color: AppTheme.outline,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, AuthStateProvider auth) {
    return Row(
      children: [
        _buildAvatar(auth),
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
                style: GoogleFonts.inter(color: AppTheme.outline, fontSize: 13),
              ),
            ],
          ),
        ),
        _ActionChip(
          label: 'EDIT',
          onTap: () => _showEditProfileDialog(context, auth),
        ),
      ],
    );
  }

  Widget _buildAvatar(AuthStateProvider auth) {
    return Container(
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
    );
  }

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
            subtitle: 'Live game alerts & food updates',
            value: state.notificationsEnabled,
            onChanged: state.toggleNotifications,
          ),
          _divider(),
          _ToggleTile(
            icon: Icons.vibration_rounded,
            title: 'Haptic Feedback',
            subtitle: 'Tactile response on interaction',
            value: state.hapticsEnabled,
            onChanged: state.toggleHaptics,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _ToggleTile(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Lock',
            subtitle: 'Secure app with FaceID/TouchID',
            value: false,
            onChanged: (v) {},
          ),
          _divider(),
          const _MenuTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Settings',
            subtitle: 'Manage data sharing & tracking',
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const _MenuTile(
            icon: Icons.help_center_rounded,
            title: 'Help Center',
            subtitle: 'FAQs and venue guides',
          ),
          _divider(),
          const _MenuTile(
            icon: Icons.chat_bubble_rounded,
            title: 'Contact Concierge',
            subtitle: 'Direct support for elite members',
          ),
          _divider(),
          const _MenuTile(
            icon: Icons.description_rounded,
            title: 'Legal & Privacy',
            subtitle: 'Terms of service and policies',
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
          style: GoogleFonts.inter(
            color: AppTheme.error,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        Center(
          child: Text(
            'VENUEVANTAGE',
            style: GoogleFonts.inter(
              color: AppTheme.onSurface.withOpacity(0.3),
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 2.0,
            ),
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

  void _showEditProfileDialog(BuildContext context, AuthStateProvider auth) {
    if (auth.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to edit your profile.')),
      );
      return;
    }

    final controller = TextEditingController(text: auth.displayName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainer,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(color: AppTheme.onSurface),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.inter(color: AppTheme.onSurface),
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Display Name',
            labelStyle: TextStyle(color: AppTheme.outline),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.outlineVariant),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                // Security: validate name format
                final nameRegex = RegExp(r"^[a-zA-Z\s']{2,30}$");
                if (!nameRegex.hasMatch(name)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid name. Use 2-30 letters only.'),
                    ),
                  );
                  return;
                }

                await auth.updateDisplayName(name);
                if (context.mounted) Navigator.pop(ctx);
              } catch (e) {
                debugPrint("Error updating profile: $e");
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(color: AppTheme.outline, fontSize: 11),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primary,
      ),
    );
  }
}
