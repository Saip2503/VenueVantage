import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';

import '../data/mock_data.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  POIType? _filterType;

  static const Map<POIType, _POIStyle> _styles = {
    POIType.food: _POIStyle(
      icon: Icons.fastfood_rounded,
      color: Color(0xFFF59E0B),
      label: 'Food',
    ),
    POIType.restroom: _POIStyle(
      icon: Icons.wc_rounded,
      color: Color(0xFF3B82F6),
      label: 'Restroom',
    ),
    POIType.merch: _POIStyle(
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF8B5CF6),
      label: 'Merch',
    ),
    POIType.exit: _POIStyle(
      icon: Icons.exit_to_app_rounded,
      color: Color(0xFF10B981),
      label: 'Exit',
    ),
    POIType.medical: _POIStyle(
      icon: Icons.local_hospital_rounded,
      color: Color(0xFFEF4444),
      label: 'Medical',
    ),
    POIType.parking: _POIStyle(
      icon: Icons.local_parking_rounded,
      color: Color(0xFF06B6D4),
      label: 'Parking',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildFilterBar(),
          Expanded(child: Stack(children: [_buildMapArea(context)])),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Text(
            'Venue Map',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.accentGreen.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Live Data',
                  style: GoogleFonts.inter(
                    color: AppTheme.accentGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final types = [null, ...POIType.values];
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: types.length,
        itemBuilder: (ctx, i) {
          final type = types[i];
          final label = type == null ? 'All' : _styles[type]!.label;
          final isSelected = _filterType == type;
          final color = type == null
              ? AppTheme.accentBlue
              : _styles[type]!.color;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () => setState(() => _filterType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.2)
                        : AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color : AppTheme.borderColor,
                    ),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? color : AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapArea(BuildContext context) {
    return Consumer<AppState>(
      builder: (ctx, state, _) {
        final pois = _filterType == null
            ? state.pointsOfInterest
            : state.pointsOfInterest
                  .where((p) => p.type == _filterType)
                  .toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              // The Navigable Map Container
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: LayoutBuilder(
                    builder: (ctx, constraints) {
                      return InteractiveViewer(
                        maxScale: 3.0,
                        minScale: 1.0,
                        boundaryMargin: const EdgeInsets.symmetric(
                          vertical: 50,
                          horizontal: 100,
                        ),
                        child: AspectRatio(
                          aspectRatio:
                              2.0, // Matching the schematic's aspect ratio
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 1. Blueprint Background
                              _buildStadiumBackground(constraints),

                              // 2. Dynamic POI Markers
                              ...pois.map(
                                (poi) => Positioned(
                                  left: poi.x * constraints.maxWidth - 18,
                                  top: poi.y * constraints.maxHeight - 18,
                                  child: _POIMarker(
                                    poi: poi,
                                    style: _styles[poi.type]!,
                                    isSelected: state.selectedPOI?.id == poi.id,
                                    onTap: () => state.selectPOI(
                                      state.selectedPOI?.id == poi.id
                                          ? null
                                          : poi,
                                    ),
                                  ),
                                ),
                              ),

                              // 4. "You Are Here" Marker (Static for demo)
                              Positioned(
                                left: constraints.maxWidth * 0.48,
                                top: constraints.maxHeight * 0.85,
                                child: _YouAreHereMarker(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 5. Selected POI Details (Floats OVER the interactive map)
              _buildPOIDetailsSheet(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStadiumBackground(BoxConstraints constraints) {
    return Container(
      color: const Color(0xFF0a0e1a),
      child: Image.asset(
        'images/stadium.png',
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
      ),
    );
  }

  Widget _buildPOIDetailsSheet(BuildContext context) {
    return Consumer<AppState>(
      builder: (ctx, state, _) {
        final poi = state.selectedPOI;
        if (poi == null) return const SizedBox.shrink();

        final style = _styles[poi.type]!;
        final crowdColor = poi.crowdLevel > 65
            ? AppTheme.accentRed
            : poi.crowdLevel > 35
            ? AppTheme.accentAmber
            : AppTheme.accentGreen;

        return Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.bgCard, // ✅ solid background (NO BLUR)
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF424754).withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE NAVIGATION',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: style.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(style.icon, color: style.color, size: 22),
                        ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                poi.name,
                                style: GoogleFonts.inter(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                style.label,
                                style: GoogleFonts.inter(
                                  color: style.color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        GestureDetector(
                          onTap: () => state.selectPOI(null),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.bgSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppTheme.textMuted,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        _POIStatChip(
                          label: 'Wait Time',
                          value: poi.waitTime,
                          icon: Icons.timer_rounded,
                          color: AppTheme.accentBlue,
                        ),
                        const SizedBox(width: 10),
                        _POIStatChip(
                          label: 'Crowd Level',
                          value: '${poi.crowdLevel}%',
                          icon: Icons.people_rounded,
                          color: crowdColor,
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.navigation_rounded,
                              size: 14,
                            ),
                            label: Text(
                              'Navigate',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: style.color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Crowd bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Crowd Density',
                              style: GoogleFonts.inter(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '${poi.crowdLevel}%',
                              style: GoogleFonts.inter(
                                color: crowdColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: poi.crowdLevel / 100,
                            minHeight: 6,
                            backgroundColor: AppTheme.bgSurface,
                            valueColor: AlwaysStoppedAnimation(crowdColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _POIStatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _POIStatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppTheme.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _POIMarker extends StatefulWidget {
  final PointOfInterest poi;
  final _POIStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  const _POIMarker({
    required this.poi,
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_POIMarker> createState() => _POIMarkerState();
}

class _POIMarkerState extends State<_POIMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    Color getGlowColor() {
      if (widget.poi.crowdLevel > 65) return const Color(0xFFf87171); // Red
      if (widget.poi.crowdLevel > 35) return const Color(0xFFfbbf24); // Amber
      return const Color(0xFF4ade80); // Green
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.isSelected ? 48 : 40,
        height: widget.isSelected ? 48 : 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: getGlowColor().withOpacity(widget.isSelected ? 0.8 : 0.4),
              blurRadius: widget.isSelected ? 24 : 16,
              spreadRadius: widget.isSelected ? 6 : 2,
            ),
          ],
          border: Border.all(color: getGlowColor().withOpacity(0.3), width: 2),
        ),
        child: Icon(
          widget.style.icon,
          color: getGlowColor(),
          size: widget.isSelected ? 24 : 20,
        ),
      ),
    );
  }
}

class _YouAreHereMarker extends StatefulWidget {
  @override
  State<_YouAreHereMarker> createState() => _YouAreHereMarkerState();
}

class _YouAreHereMarkerState extends State<_YouAreHereMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _pulse,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 3,
            ),
          ],
          border: Border.all(color: AppTheme.accentBlue, width: 3),
        ),
      ),
    );
  }
}

class _POIStyle {
  final IconData icon;
  final Color color;
  final String label;
  const _POIStyle({
    required this.icon,
    required this.color,
    required this.label,
  });
}
