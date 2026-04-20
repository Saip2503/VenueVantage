import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../providers/auth_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'assistant_screen.dart';

/// The main entry point for the VenueVantage dashboard.
/// This screen aggregates data from [AppState] including dynamic POIs,
/// AI assistant navigation, and live crowd density stats to provide
/// a unified stadium experience for the user.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppState>().fetchDynamicData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDarkMode;
    final isLoading = state.isLoading;

    return SafeArea(
      child: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.surfaceContainer,
        onRefresh: () => context.read<AppState>().refreshData(),
        child: isLoading
            ? _buildShimmer()
            : CustomScrollView(
                slivers: [
                  _buildHeader(context, isDark),
                  _buildEventBanner(context),
                  _buildLiveStats(context, state),
                  _buildCrowdTrendChart(context, state),
                  _buildAssistantSection(context),
                  _buildQuickActions(context, isDark),
                  _buildRouteRecommendation(context, state),
                  _buildExitCountdown(context, state),
                ],
              ),
      ),
    );
  }

  // ── Shimmer ──────────────────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceContainerHigh,
      highlightColor: AppTheme.surfaceContainerHighest,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _shimmerBox(height: 60, radius: 4),
            const SizedBox(height: 16),
            _shimmerBox(height: 160, radius: 4),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _shimmerBox(height: 100, radius: 4)),
                const SizedBox(width: 12),
                Expanded(child: _shimmerBox(height: 100, radius: 4)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _shimmerBox(height: 100, radius: 4)),
                const SizedBox(width: 12),
                Expanded(child: _shimmerBox(height: 100, radius: 4)),
              ],
            ),
            const SizedBox(height: 16),
            _shimmerBox(height: 160, radius: 4),
            const SizedBox(height: 16),
            _shimmerBox(height: 80, radius: 4),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({required double height, required double radius}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Consumer<AuthStateProvider>(
      builder: (context, auth, _) {
        final name = auth.isAnonymous
            ? 'Guest'
            : (auth.user?.displayName?.split(' ').first ?? 'Member');
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, $name 👋',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.outline,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.ctaGradient.createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        'VenueVantage',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Semantics(
                  label: 'User profile: ${auth.initials}',
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.ctaGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: auth.photoUrl != null && !auth.isAnonymous
                          ? ClipOval(
                              child: Image.network(
                                auth.photoUrl!,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _initials(auth.initials),
                              ),
                            )
                          : _initials(auth.initials),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _initials(String text) => Text(
    text,
    style: GoogleFonts.inter(
      color: AppTheme.onPrimary,
      fontWeight: FontWeight.w700,
      fontSize: 14,
    ),
  );

  // ── Event Banner ──────────────────────────────────────────────────────────────
  Widget _buildEventBanner(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: AppTheme.eventBannerGradient,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryContainer.withOpacity(0.20),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _LiveBadge(),
                        const SizedBox(width: 10),
                        Text(
                          'Q3 · 7:24',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.84),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'City Hawks vs. Raptors FC',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: -0.02 * 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Consumer<AppState>(
                          builder: (_, state, __) => Text(
                            '🏟️ Apex Arena · ${state.seatLabel}',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '87',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: -0.02 * 48,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '–',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      Text(
                        '74',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: -0.02 * 48,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Live Stats ────────────────────────────────────────────────────────────────
  Widget _buildLiveStats(BuildContext context, AppState state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Live Venue Stats'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _RadialStatCard(
                      value: 0.89,
                      label: 'Capacity',
                      display: '89%',
                      color: AppTheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _RadialStatCard(
                      value: 0.53,
                      label: 'Avg Wait',
                      display: '8 min',
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _RadialStatCard(
                      value: 0.15,
                      label: 'Best Exit',
                      display: state.bestExit.split(' ').last,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _RadialStatCard(
                      value: 0.75,
                      label: 'Weather',
                      display: state.temperature,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Crowd Trend Chart ─────────────────────────────────────────────────────────
  Widget _buildCrowdTrendChart(BuildContext context, AppState state) {
    final spots = state.crowdTrend
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _SectionTitle('Crowd Trend – 30 min'),
                  const Spacer(),
                  // Venue Status Chip — pill shape, low-opacity bg
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '↑ RISING',
                      style: GoogleFonts.inter(
                        color: AppTheme.error,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.05 * 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppTheme.outlineVariant.withOpacity(0.30),
                        strokeWidth: 0.5,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (v, _) => Text(
                            '${v.toInt()}%',
                            style: GoogleFonts.inter(
                              color: AppTheme.outline,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitlesWidget: (v, _) {
                            final labels = state.crowdTrendLabels;
                            final i = v.toInt();
                            if (i < 0 || i >= labels.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              labels[i],
                              style: GoogleFonts.inter(
                                color: AppTheme.outline,
                                fontSize: 9,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        gradient: AppTheme.ctaGradient,
                        barWidth: 2.5,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryContainer.withOpacity(0.25),
                              AppTheme.primaryContainer.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    minY: 0,
                    maxY: 100,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // ── AI Assistant Section ───────────────────────────────────────────────────
  Widget _buildAssistantSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Your Stadium Guide'),
            const SizedBox(height: 12),
            Semantics(
              label: 'Open Venue AI Assistant for help with food, wait times, or directions',
              button: true,
              child: GestureDetector(
                onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AssistantScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.15),
                      AppTheme.accentBlue.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chat with Venue AI',
                            style: GoogleFonts.inter(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ask about food, wait times, or directions.',
                            style: GoogleFonts.inter(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.textMuted,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick Actions ──────────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Quick Actions'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.fastfood_rounded,
                    label: 'Order\nFood',
                    gradient: AppTheme.ctaGradient,
                    onTap: () => context.read<AppState>().setSelectedIndex(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.wc_rounded,
                    label: 'Find\nRestroom',
                    isGhost: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.local_hospital_rounded,
                    label: 'Medical\nAid',
                    gradient: AppTheme.redGradient,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.local_parking_rounded,
                    label: 'My\nParking',
                    isGhost: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Route Recommendation (GlassCard) ─────────────────────────────────────────
  Widget _buildRouteRecommendation(BuildContext context, AppState state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Smart Exit Routing'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(20),
              blurSigma: 14,
              tint: AppTheme.accentGreen,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.directions_walk_rounded,
                      color: AppTheme.accentGreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommended: ${state.bestExit}',
                          style: GoogleFonts.inter(
                            color: AppTheme.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Turn left at Section 12 → follow green signs → Est. ${state.eta}.',
                          style: GoogleFonts.inter(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppTheme.accentGreen,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Exit Countdown ────────────────────────────────────────────────────────────
  Widget _buildExitCountdown(BuildContext context, AppState state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // Intentional opaque gradient — an alert "pulse" element
            gradient: const LinearGradient(
              colors: [Color(0xFF3D1A00), Color(0xFF6B3000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppTheme.tertiary.withOpacity(0.20),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.tertiary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  color: AppTheme.tertiary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Game Ends in ~14 min',
                      style: GoogleFonts.inter(
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Head to ${state.bestExit} now to beat the rush. Other exits are becoming congested.',
                      style: GoogleFonts.inter(
                        color: AppTheme.tertiary.withOpacity(0.80),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '14:00',
                style: GoogleFonts.inter(
                  color: AppTheme.tertiary,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: -0.02 * 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Supporting Widgets ─────────────────────────────────────────────────────────

class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween(begin: 0.5, end: 1.0).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.error.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _pulse,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppTheme.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'LIVE',
            style: GoogleFonts.inter(
              color: AppTheme.error,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.05 * 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.inter(
      color: AppTheme.onSurface,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.01 * 17,
    ),
  );
}

/// Primary action button — uses Stitch CTA gradient.
/// Ghost action — uses outline at 20% opacity.
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient? gradient;
  final bool isGhost;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    this.gradient,
    this.isGhost = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label.replaceAll('\n', ' '),
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isGhost ? null : gradient,
            color: isGhost ? Colors.transparent : null,
            borderRadius: BorderRadius.circular(4),
            border: isGhost
                ? Border.all(color: AppTheme.outline.withOpacity(0.20))
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isGhost ? AppTheme.onSurfaceVariant : AppTheme.onPrimary,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: isGhost
                      ? AppTheme.onSurfaceVariant
                      : AppTheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadialStatCard extends StatelessWidget {
  final double value;
  final String label, display;
  final Color color;

  const _RadialStatCard({
    required this.value,
    required this.label,
    required this.display,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
        // No border — parent surfaceContainerLow creates lift
      ),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            width: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        value: value,
                        color: color,
                        radius: 6,
                        title: '',
                      ),
                      PieChartSectionData(
                        value: 1 - value,
                        color: AppTheme.surfaceContainerHigh,
                        radius: 6,
                        title: '',
                      ),
                    ],
                    centerSpaceRadius: 22,
                  ),
                ),
                Text(
                  display,
                  style: GoogleFonts.inter(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // label-sm style: UPPERCASE + tracking
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              color: AppTheme.onSurfaceVariant,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05 * 9,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
