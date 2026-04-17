import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/app_state.dart';
import 'providers/auth_state.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/order_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/assistant_screen.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Failed to load .env file: $e");
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthStateProvider()),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const VenueVantageApp(),
    ),
  );
}

class VenueVantageApp extends StatelessWidget {
  const VenueVantageApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppState>().isDarkMode;
    return MaterialApp(
      title: 'VenueVantage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const AuthGate(),
    );
  }
}

/// Dynamic gate that switches screens based on Auth and Onboarding state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStateProvider>();
    final app = context.watch<AppState>();

    // 1. Initial Loading / Splash
    if (auth.isLoading) {
      return const SplashScreen();
    }

    // 2. Unauthenticated
    if (auth.isLoggedOut) {
      return const LoginScreen();
    }

    // 3. Authenticated - Check Onboarding
    if (!app.onboardingDone) {
      return const OnboardingScreen();
    }

    // 4. Fully ready
    return const MainShell();
  }
}

// ── Main Shell ────────────────────────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    OrderScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appState = context.read<AppState>();
      appState.refreshData();
      // Seed Firestore on first launch (idempotent batch.set)
      await appState.seedIfNeeded();
    });
  }

  void _onNavTap(int index) {
    final state = context.read<AppState>();
    if (index == state.selectedIndex) return;
    _fadeController.reverse().then((_) {
      state.setSelectedIndex(index);
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDarkMode;
    final selectedIndex = appState.selectedIndex;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 700) {
          return Scaffold(
            backgroundColor: AppTheme.bg(isDark),
            floatingActionButton: _buildAssistantFab(context),
            body: Row(
              children: [
                _buildSidebar(isDark),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _screens[selectedIndex],
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: AppTheme.bg(isDark),
          floatingActionButton: _buildAssistantFab(context),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: _screens[selectedIndex],
          ),
          bottomNavigationBar: _buildNavBar(isDark),
        );
      },
    );
  }

  Widget _buildAssistantFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AssistantScreen()));
      },
      backgroundColor: AppTheme.primary,
      icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
      label: Text(
        'Venue AI',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  // ── Sidebar ───────────────────────────────────────────────────────────────
  Widget _buildSidebar(bool isDark) {
    return Container(
      width: 200,
      color: AppTheme.surfaceContainerLow,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.ctaGradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    'VenueVantage',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              color: AppTheme.outlineVariant.withOpacity(0.12),
            ),
            const SizedBox(height: 8),
            ...List.generate(_navItems.length, (i) {
              final isSelected = context.watch<AppState>().selectedIndex == i;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                child: GestureDetector(
                  onTap: () => _onNavTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            _navItems[i].icon,
                            size: 20,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _navItems[i].label,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Home'),
    _NavItem(icon: Icons.map_rounded, label: 'Map'),
    _NavItem(icon: Icons.shopping_bag_rounded, label: 'Order'),
    _NavItem(icon: Icons.notifications_rounded, label: 'Alerts'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildNavBar(bool isDark) {
    return Container(
      color: AppTheme.surfaceContainer,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              final hasNotif = i == 3
                  ? context.watch<AppState>().hasUnreadAlerts
                  : false;
              return Semantics(
                label: _navItems[i].label,
                button: true,
                child: _NavBarButton(
                  item: _navItems[i],
                  isSelected: context.watch<AppState>().selectedIndex == i,
                  onTap: () => _onNavTap(i),
                  hasNotification: hasNotif,
                  isDark: isDark,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NavBarButton extends StatelessWidget {
  final _NavItem item;
  final bool isSelected, hasNotification, isDark;
  final VoidCallback onTap;

  const _NavBarButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.hasNotification = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  child: Icon(
                    item.icon,
                    size: 22,
                    color: isSelected ? AppTheme.primary : AppTheme.outline,
                  ),
                ),
                if (hasNotification)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.primary : AppTheme.outline,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
