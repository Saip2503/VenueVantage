import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapsService {
  final String? _apiKey = dotenv.env['General_API_KEY'];

  Future<Map<String, dynamic>> getDirections(String origin, String destination) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      // Return mock data if no API key
      return {
        'status': 'OK',
        'duration': '12 mins',
        'distance': '1.2 km',
        'points': [],
      };
    }

    final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$_apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final leg = data['routes'][0]['legs'][0];
          return {
            'status': 'OK',
            'duration': leg['duration']['text'],
            'distance': leg['distance']['text'],
            'points': data['routes'][0]['overview_polyline']['points'],
          };
        }
      }
    } catch (e) {
      print('Maps API Error: $e');
    }

    return {
      'status': 'ERROR',
      'duration': 'N/A',
      'distance': 'N/A',
    };
  }
}
