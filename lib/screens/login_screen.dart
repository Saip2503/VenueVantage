import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_state.dart';
import '../theme/app_theme.dart';

/// Premium Google Sign-In screen following the Stitch "Stadium Elite" design.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _logoScale;
  late Animation<double> _fadeIn;

  bool _signingIn = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = Tween(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fadeIn = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _ctrl, curve: const Interval(0.3, 1.0, curve: Curves.easeIn)));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _signingIn = true);
    final auth = context.read<AuthStateProvider>();
    auth.clearError();
    await auth.signInWithGoogle();
    if (mounted) setState(() => _signingIn = false);
    // Navigation handled by SplashScreen auth-state listener
  }

  Future<void> _handleGuestSignIn() async {
    setState(() => _signingIn = true);
    final auth = context.read<AuthStateProvider>();
    auth.clearError();
    await auth.signInAsGuest();
    if (mounted) setState(() => _signingIn = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStateProvider>();
    final error = auth.errorMessage;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: FadeTransition(
            opacity: _fadeIn,
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Logo ──────────────────────────────────────────────────
                ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppTheme.ctaGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryContainer.withOpacity(0.30),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.stadium_rounded,
                        color: AppTheme.onPrimary, size: 52),
                  ),
                ),
                const SizedBox(height: 28),

                // ── App name ──────────────────────────────────────────────
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.ctaGradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    'VenueVantage',
                    style: GoogleFonts.inter(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.02 * 34,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your smart stadium companion',
                  style: GoogleFonts.inter(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),

                const Spacer(flex: 2),

                // ── Feature pill chips ────────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: const [
                    _FeatureChip(icon: Icons.map_rounded, label: 'Wayfinding'),
                    _FeatureChip(
                        icon: Icons.fastfood_rounded, label: 'In-Seat Orders'),
                    _FeatureChip(
                        icon: Icons.notifications_active_rounded,
                        label: 'Live Alerts'),
                    _FeatureChip(
                        icon: Icons.people_alt_rounded,
                        label: 'Crowd Density'),
                  ],
                ),

                const Spacer(flex: 1),

                // ── Error banner ──────────────────────────────────────────
                if (error != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      error,
                      style: GoogleFonts.inter(
                        color: AppTheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ),

                // ── Google Sign-In CTA ────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: Semantics(
                    button: true,
                    label: 'Sign in with Google',
                    child: GestureDetector(
                      onTap: _signingIn ? null : _handleGoogleSignIn,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: _signingIn
                            ? null
                            : AppTheme.ctaGradient,
                        color: _signingIn
                            ? AppTheme.surfaceContainerHigh
                            : null,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: _signingIn
                            ? null
                            : [
                                BoxShadow(
                                  color: AppTheme.primaryContainer
                                      .withOpacity(0.30),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: _signingIn
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.onPrimary,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Google "G" logo badge
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'G',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: Color(0xFF4285F4),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: GoogleFonts.inter(
                                    color: AppTheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ), // closes AnimatedContainer
                  ), // closes GestureDetector
                ), // closes Semantics
                ), // closes SizedBox
                const SizedBox(height: 14),

                // ── Guest ghost button ────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: Semantics(
                    button: true,
                    label: 'Continue as Guest',
                    child: GestureDetector(
                      onTap: _signingIn ? null : _handleGuestSignIn,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.outline.withOpacity(0.20),
                        ),
                      ),
                      child: Text(
                        'Continue as Guest',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: AppTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ), // closes Container
                  ), // closes GestureDetector
                ), // closes Semantics
                ), // closes SizedBox

                const Spacer(flex: 1),

                // ── Privacy note ──────────────────────────────────────────
                Text(
                  'By continuing you agree to our Terms & Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppTheme.outline.withOpacity(0.60),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.primary.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primary, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
