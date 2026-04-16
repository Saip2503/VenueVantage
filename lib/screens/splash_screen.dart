import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

    _logoScale = Tween(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)));
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));
    _taglineOpacity = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 0.85, curve: Curves.easeIn)));
    _taglineSlide = Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 0.85, curve: Curves.easeOut)));

    _ctrl.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      final state = context.read<AppState>();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) =>
              state.onboardingDone ? const MainShell() : const OnboardingScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ScaleTransition(
            scale: _logoScale,
            child: FadeTransition(
              opacity: _logoOpacity,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  gradient: AppTheme.blueGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: AppTheme.accentBlue.withAlpha(100), blurRadius: 40, spreadRadius: 5)],
                ),
                child: const Icon(Icons.stadium_rounded, color: Colors.white, size: 52),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _logoOpacity,
            child: Text('VenueVantage',
              style: GoogleFonts.inter(
                fontSize: 30, fontWeight: FontWeight.w900,
                foreground: Paint()..shader = AppTheme.blueGradient.createShader(const Rect.fromLTWH(0, 0, 250, 40)),
              )),
          ),
          const SizedBox(height: 12),
          SlideTransition(
            position: _taglineSlide,
            child: FadeTransition(
              opacity: _taglineOpacity,
              child: Text('Your smart stadium companion',
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 60),
          FadeTransition(
            opacity: _taglineOpacity,
            child: const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentBlue),
            ),
          ),
        ]),
      ),
    );
  }
}
