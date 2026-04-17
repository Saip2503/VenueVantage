class Venue {
  final String name;
  final double lat;
  final double lng;
  final String placeId;
  final List<Map<String, dynamic>> exits;
  final String imagePath;
  final double nwLat; // North-West corner for overlay
  final double nwLng;
  final double seLat; // South-East corner for overlay
  final double seLng;

  Venue({
    required this.name,
    required this.lat,
    required this.lng,
    required this.placeId,
    required this.exits,
    required this.imagePath,
    required this.nwLat,
    required this.nwLng,
    required this.seLat,
    required this.seLng,
  });
}
