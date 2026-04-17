import 'maps_service.dart';
import 'places_service.dart';
import 'weather_service.dart';

class ApiRepository {
  final MapsService _maps = MapsService();
  final PlacesService _places = PlacesService();
  final WeatherService _weather = WeatherService();

  Future<Map<String, dynamic>> getBestExitData() async {
    return await _maps.getBestExit();
  }

  Future<List<dynamic>> getNearbyPlaces() async {
    return await _places.getNearby("stadium");
  }

  Future<Map<String, dynamic>> getWeather() async {
    return await _weather.getWeather();
  }
}
