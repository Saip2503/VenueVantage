import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../providers/auth_state.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(
      icon: Icons.map_rounded, gradient: AppTheme.blueGradient,
      title: 'Navigate Effortlessly',
      body: 'Real-time crowd density maps and smart exit routing guide you to the least congested areas so you never miss a moment.',
    ),
    _OnboardPage(
      icon: Icons.fastfood_rounded, gradient: AppTheme.amberGradient,
      title: 'Order From Your Seat',
      body: 'Skip the queues. Order food and drinks directly to your seat and track your order live.',
    ),
    _OnboardPage(
      icon: Icons.notifications_active_rounded, gradient: AppTheme.purpleGradient,
      title: 'Stay Ahead of the Crowd',
      body: 'Receive real-time alerts about crowd hotspots, deals, halftime shows, and important safety information.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(children: [
          // Skip
          Align(
            alignment: Alignment.topRight,
            child: _page < 2
              ? TextButton(
                  onPressed: _goToSeatSelection,
                  child: Text('Skip', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13)),
                )
              : const SizedBox(height: 40),
          ),
          // Pages
          Expanded(
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => _pages[i],
            ),
          ),
          // Dots
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _page == i ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _page == i ? AppTheme.accentBlue : AppTheme.textMuted,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          })),
          const SizedBox(height: 32),
          // Next / Get Started
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_page < 2) {
                    _pageCtrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
                  } else {
                    _goToSeatSelection();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(_page < 2 ? 'Next' : 'Get Started',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  void _goToSeatSelection() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SeatSelectionScreen()));
  }
}

class _OnboardPage extends StatelessWidget {
  final IconData icon;
  final LinearGradient gradient;
  final String title, body;
  const _OnboardPage({required this.icon, required this.gradient, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(gradient: gradient, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: gradient.colors.first.withAlpha(80), blurRadius: 40, spreadRadius: 5)]),
          child: Icon(icon, color: Colors.white, size: 56),
        ),
        const SizedBox(height: 40),
        Text(title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Text(body,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 15, height: 1.6)),
      ]),
    );
  }
}

// ── Seat Selection ─────────────────────────────────────────────────────────────

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({super.key});
  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final _sectionCtrl = TextEditingController(text: '14');
  final _rowCtrl = TextEditingController(text: 'C');
  final _seatCtrl = TextEditingController(text: '3');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(gradient: AppTheme.blueGradient, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.chair_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 24),
            Text('Where are you sitting?',
              style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('We\'ll use this to personalise your navigation and deliver orders direct to your seat.',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14, height: 1.6)),
            const SizedBox(height: 36),
            _SeatField(controller: _sectionCtrl, label: 'Section', hint: 'e.g. 14'),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _SeatField(controller: _rowCtrl, label: 'Row', hint: 'e.g. C')),
              const SizedBox(width: 16),
              Expanded(child: _SeatField(controller: _seatCtrl, label: 'Seat Number', hint: 'e.g. 3')),
            ]),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.accentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Confirm Seat', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _confirm() {
    final sectionRaw = _sectionCtrl.text.trim();
    final rowRaw = _rowCtrl.text.trim();
    final seatRaw = _seatCtrl.text.trim();

    if (sectionRaw.isEmpty || rowRaw.isEmpty || seatRaw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill out all seat fields.', style: GoogleFonts.inter()),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!regex.hasMatch(sectionRaw) || !regex.hasMatch(rowRaw) || !regex.hasMatch(seatRaw)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Use only letters and numbers for seat info.', style: GoogleFonts.inter()),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final state = context.read<AppState>();
    final auth = context.read<AuthStateProvider>();

    if (auth.user != null) {
      state.setSeatInfoWithSync(
        auth.user!.uid,
        sectionRaw,
        rowRaw,
        seatRaw,
      );
    } else {
      state.setSeatInfo(sectionRaw, rowRaw, seatRaw);
    }

    state.completeOnboarding();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
      (route) => false,
    );
  }
}

class _SeatField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  const _SeatField({required this.controller, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
          filled: true, fillColor: AppTheme.bgCard,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.accentBlue, width: 1.5)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ]);
  }
}
