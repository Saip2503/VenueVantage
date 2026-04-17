import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlacesService {
  final String? _apiKey = dotenv.env['General_API_KEY'];

  Future<List<dynamic>> getNearby(String location) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      // Return mock data if no API key
      return [
        {'name': 'Starlight Cafe', 'rating': 4.5, 'type': 'food'},
        {'name': 'Main Restroom', 'rating': 4.0, 'type': 'restroom'},
        {'name': 'Fan Shop', 'rating': 4.8, 'type': 'merch'},
      ];
    }

    // Example location: "latitude,longitude"
    final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$location&radius=500&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] ?? [];
      }
    } catch (e) {
      print('Places API Error: $e');
    }

    return [];
  }
}
