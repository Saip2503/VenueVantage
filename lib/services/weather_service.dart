import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  final String? _apiKey = dotenv.env['General_API_KEY'];

  Future<Map<String, dynamic>> getWeather() async {
    if (_apiKey == null || _apiKey.isEmpty) {
      // Return mock data if no API key
      return {'temp': 24, 'condition': 'Sunny'};
    }

    // Example coordinates for a stadium
    const lat = 34.0522;
    const lon = -118.2437;
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temp': data['main']['temp'].round(),
          'condition': data['weather'][0]['main'],
        };
      }
    } catch (e) {
      debugPrint('Weather API Error: $e');
      return {'temp': '--', 'condition': 'Unknown'};
    }

    return {'temp': '--', 'condition': 'Unknown'};
  }
}
