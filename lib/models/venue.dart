class Venue {
  final String name;
  final double lat;
  final double lng;
  final String placeId;

  final List<Map<String, dynamic>> exits;

  Venue({
    required this.name,
    required this.lat,
    required this.lng,
    required this.placeId,
    required this.exits,
  });
}
