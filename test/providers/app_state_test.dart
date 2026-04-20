import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venue_vantage/providers/app_state.dart';
import 'package:venue_vantage/services/api_repository.dart';
import 'package:venue_vantage/services/firestore_service.dart';

class MockApiRepository implements ApiRepository {
  @override
  Future<Map<String, dynamic>> getBestExitData() async => {
    'exit': 'A',
    'durationText': '2 min',
  };
  @override
  Future<List<dynamic>> getNearbyPlaces() async => [];
  @override
  Future<Map<String, dynamic>> getWeather() async => {'temp': 24};
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockFirestoreService implements FirestoreService {
  @override
  Stream<List<MenuItem>> menuStream() => const Stream.empty();
  @override
  Stream<List<Alert>> alertsStream() => const Stream.empty();
  @override
  Stream<VenueStats> statsStream() => Stream.value(VenueStats.defaults());
  @override
  Stream<List<PointOfInterest>> poisStream() => const Stream.empty();
  @override
  Future<void> seedVenueData() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockApiRepository mockApi;
  late MockFirestoreService mockFs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await dotenv.load(fileName: '.env');
    mockApi = MockApiRepository();
    mockFs = MockFirestoreService();
  });

  group('AppState Tests', () {
    test('initial values', () {
      final state = AppState(apiRepository: mockApi, firestoreService: mockFs);
      expect(state.selectedIndex, 0);
      expect(state.isDarkMode, true);
    });

    test('update navigation index', () {
      final state = AppState(apiRepository: mockApi, firestoreService: mockFs);
      state.setSelectedIndex(2);
      expect(state.selectedIndex, 2);
    });

    test('toggle theme', () {
      final state = AppState(apiRepository: mockApi, firestoreService: mockFs);
      final initialTheme = state.isDarkMode;
      state.toggleTheme();
      expect(state.isDarkMode, !initialTheme);
    });

    test('cart operations', () {
      final state = AppState(apiRepository: mockApi, firestoreService: mockFs);

      final item = CartItem(
        id: '1',
        name: 'Hot Dog',
        price: 5.0,
        quantity: 1,
        emoji: '🌭',
      );

      state.addToCart(item);
      expect(state.cartItemCount, 1);

      state.removeFromCart('1');
      expect(state.cartItemCount, 0);
    });

    test('preference toggles', () {
      final state = AppState(apiRepository: mockApi, firestoreService: mockFs);
      state.toggleNotifications(false);
      expect(state.notificationsEnabled, false);
      state.toggleHaptics(false);
      expect(state.hapticsEnabled, false);
    });

    test('fetch dynamic data', () async {
      final state = AppState(apiRepository: mockApi, firestoreService: mockFs);
      await state.fetchDynamicData();
      expect(state.bestExit, 'A');
      expect(state.temperature, '24°C');
    });
  });
}
