import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/venue.dart';
import '../data/venue_data.dart';

/// Model for clean route output
class DirectionResult {
  final String distanceText;
  final String durationText;
  final int durationValue; // seconds
  final List<Map<String, double>> polylinePoints;

  DirectionResult({
    required this.distanceText,
    required this.durationText,
    required this.durationValue,
    required this.polylinePoints,
  });
}

class MapsService {
  final String? _apiKey = dotenv.env['General_API_KEY'];

  /// Find the fastest exit by checking all defined exits for currentVenue
  Future<Map<String, dynamic>> getBestExit() async {
    final venue = currentVenue;
    List<Map<String, dynamic>> results = [];

    for (var exit in venue.exits) {
      try {
        final route = await getDirections(
          origin: "${venue.lat},${venue.lng}",
          destination: "${exit['lat']},${exit['lng']}",
        );

        results.add({
          "exit": exit['name'],
          "duration": route.durationValue,
          "durationText": route.durationText,
        });
      } catch (e) {
        debugPrint("Error fetching directions for ${exit['name']}: $e");
      }
    }

    if (results.isEmpty) {
      return {
        "exit": venue.exits[0]['name'],
        "duration": 600,
        "durationText": "10 min",
      };
    }

    results.sort((a, b) => a['duration'].compareTo(b['duration']));
    return results.first;
  }

  /// Get directions between two points
  Future<DirectionResult> getDirections({
    required String origin,
    required String destination,
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      // Return mock data if no API key
      return DirectionResult(
        distanceText: '1.2 km',
        durationText: '12 mins',
        durationValue: 720,
        polylinePoints: [],
      );
    }

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json"
      "?origin=$origin"
      "&destination=$destination"
      "&key=$_apiKey",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch directions");
      }

      final data = jsonDecode(response.body);

      if (data['routes'] == null || data['routes'].isEmpty) {
        throw Exception("No routes found");
      }

      final route = data['routes'][0];
      final leg = route['legs'][0];

      return DirectionResult(
        distanceText: leg['distance']['text'],
        durationText: leg['duration']['text'],
        durationValue: leg['duration']['value'],
        polylinePoints: _decodePolyline(route['overview_polyline']['points']),
      );
    } catch (e) {
      // Fallback to mock on error to prevent app crash in demo
      return DirectionResult(
        distanceText: 'N/A',
        durationText: '12 mins',
        durationValue: 720,
        polylinePoints: [],
      );
    }
  }

  /// Decode Google polyline → usable lat/lng list
  List<Map<String, double>> _decodePolyline(String encoded) {
    List<Map<String, double>> points = [];

    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;

      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add({"lat": lat / 1E5, "lng": lng / 1E5});
    }

    return points;
  }
}
