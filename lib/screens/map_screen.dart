import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../data/venue_data.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  POIType? _filterType;
  GoogleMapController? _mapController;

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
    final state = context.watch<AppState>();
    final pois = _filterType == null
        ? state.pointsOfInterest
        : state.pointsOfInterest
              .where((p) => p.type == _filterType)
              .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
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
                child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(currentVenue.lat, currentVenue.lng),
                  zoom: 17.5,
                ),
                onMapCreated: (controller) => _mapController = controller,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                style: _darkMapStyle,
                markers: _buildMarkers(pois, state),
              ),
            ),
          ),
          _buildPOIDetailsSheet(context),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(List<PointOfInterest> pois, AppState state) {
    return pois.map((poi) {
      return Marker(
        markerId: MarkerId(poi.id),
        position: LatLng(poi.lat, poi.lng),
        infoWindow: InfoWindow(title: poi.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          poi.type == POIType.food ? BitmapDescriptor.hueOrange :
          poi.type == POIType.exit ? BitmapDescriptor.hueGreen :
          poi.type == POIType.medical ? BitmapDescriptor.hueRed :
          BitmapDescriptor.hueCyan
        ),
        onTap: () => state.selectPOI(poi),
      );
    }).toSet();
  }

  Widget _buildPOIDetailsSheet(BuildContext context) {
    final state = context.watch<AppState>();
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
            color: AppTheme.bgCard,
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
                        icon: const Icon(Icons.navigation_rounded, size: 14),
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
  }

  final String _darkMapStyle = '[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}]';
}

class _POIStatChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _POIStatChip({required this.label, required this.value, required this.icon, required this.color});
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
            Text(label, style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value, style: GoogleFonts.inter(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _POIStyle {
  final IconData icon;
  final Color color;
  final String label;
  const _POIStyle({required this.icon, required this.color, required this.label});
}
