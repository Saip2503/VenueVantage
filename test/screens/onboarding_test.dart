import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:venue_vantage/screens/onboarding_screen.dart';
import 'package:venue_vantage/providers/app_state.dart';
import 'package:venue_vantage/providers/auth_state.dart';
import 'package:venue_vantage/services/firestore_service.dart';
import 'package:venue_vantage/services/api_repository.dart';
import 'package:venue_vantage/services/auth_service.dart';

class MockAppState extends AppState {
  MockAppState()
    : super(
        firestoreService: MockFirestoreService(),
        apiRepository: MockApiRepository(),
      );

  @override
  bool get isLoading => false;

  @override
  Future<void> _init() async {
    // No-op to avoid async state changes during tests
  }

  @override
  Future<void> refreshData() async {}

  @override
  Future<void> seedIfNeeded() async {}

  @override
  Future<void> fetchDynamicData() async {}

  @override
  void _subscribeToFirestore() {
    // No-op for tests
  }
}

class MockAuthState extends AuthStateProvider {
  MockAuthState() : super(authService: MockAuthService());
}

class MockFirestoreService implements FirestoreService {
  @override
  Future<void> seedVenueData() async {}
  @override
  Future<void> saveUserProfile(
    String uid, {
    required String section,
    required String row,
    required String seat,
  }) async {}
  @override
  Stream<List<MenuItem>> menuStream() => const Stream.empty();
  @override
  Stream<List<Alert>> alertsStream() => const Stream.empty();
  @override
  Stream<VenueStats> statsStream() => Stream.value(VenueStats.defaults());
  @override
  Stream<List<PointOfInterest>> poisStream() => const Stream.empty();
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockApiRepository implements ApiRepository {
  @override
  Future<Map<String, dynamic>> getBestExitData() async => {
    'exit': 'A',
    'durationText': '2 min',
  };
  @override
  Future<Map<String, dynamic>> getWeather() async => {'temp': 24};
  @override
  Future<List<dynamic>> getNearbyPlaces() async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockAuthService implements AuthService {
  @override
  Stream<User?> get userStream => const Stream.empty();
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  testWidgets('Onboarding seat validation test', (WidgetTester tester) async {
    final mockAppState = MockAppState();
    final mockAuthState = MockAuthState();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>.value(value: mockAppState),
          ChangeNotifierProvider<AuthStateProvider>.value(value: mockAuthState),
        ],
        child: const MaterialApp(home: SeatSelectionScreen()),
      ),
    );

    // Initial state check
    expect(find.text('Where are you sitting?'), findsOneWidget);

    // Try to enter invalid characters in section
    await tester.enterText(find.byType(TextField).at(0), '14@!');
    await tester.tap(find.text('Confirm Seat'));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify error snackbar appears
    expect(
      find.text('Use only letters and numbers for seat info.'),
      findsOneWidget,
    );

    // 2. Test valid input (should navigate)
    await tester.enterText(find.byType(TextField).at(0), '15');
    await tester.enterText(find.byType(TextField).at(1), 'A');
    await tester.enterText(find.byType(TextField).at(2), '7');

    final confirmBtn = find.byType(ElevatedButton);
    await tester.ensureVisible(confirmBtn);
    await tester.tap(confirmBtn);

    // With all async loops in AppState/HomeScreen mocked out, pumpAndSettle should now work
    // Instead of pumpAndSettle:
    await tester.pump();
    await tester.pump(
      const Duration(milliseconds: 100),
    ); // Give it time to start transition
    await tester.pump(
      const Duration(seconds: 1),
    ); // Give it time to finish transition

    // Verify navigation occurred
    expect(find.byType(SeatSelectionScreen), findsNothing);
  });
}
