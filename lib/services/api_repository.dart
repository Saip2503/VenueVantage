import 'maps_service.dart';
import 'places_service.dart';
import 'weather_service.dart';
import '../data/venue_data.dart';

/// Repository layer coordinating all external Google Cloud API services.
/// It abstracts away direct [MapsService], [PlacesService], and [WeatherService]
/// invocations, providing a clean surface for [AppState] to fetch dynamic stadium data.
class ApiRepository {
  final MapsService _maps = MapsService();
  final PlacesService _places = PlacesService();
  final WeatherService _weather = WeatherService();

  Future<Map<String, dynamic>> getBestExitData() async {
    return await _maps.getBestExit();
  }

  Future<List<dynamic>> getNearbyPlaces() async {
    return await _places.getNearby("${currentVenue.lat},${currentVenue.lng}");
  }

  Future<Map<String, dynamic>> getWeather() async {
    return await _weather.getWeather();
  }
}
