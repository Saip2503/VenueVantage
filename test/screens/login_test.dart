import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:venue_vantage/screens/login_screen.dart';
import 'package:venue_vantage/providers/auth_state.dart';
import 'package:venue_vantage/providers/app_state.dart';
import 'package:venue_vantage/services/firestore_service.dart';
import 'package:venue_vantage/services/api_repository.dart';
import 'package:venue_vantage/services/auth_service.dart';

class MockAuthState extends AuthStateProvider {
  MockAuthState() : super(authService: MockAuthService());
  
  bool signInCalled = false;
  bool guestSignInCalled = false;

  @override
  Future<bool> signInWithGoogle() async {
    signInCalled = true;
    return true;
  }

  @override
  Future<bool> signInAsGuest() async {
    guestSignInCalled = true;
    return true;
  }
}

class MockAppState extends AppState {
  MockAppState() : super(
    firestoreService: MockFirestoreService(),
    apiRepository: MockApiRepository(),
  );

  @override
  void _subscribeToFirestore() {
    // No-op to avoid stream errors in tests
  }
}

class MockFirestoreService implements FirestoreService {
  @override
  Future<void> seedVenueData() async {}
  @override
  Future<void> saveUserProfile(String uid, {required String section, required String row, required String seat}) async {}
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
  Future<UserCredential?> signInWithGoogle() async => null;
  @override
  Future<UserCredential> signInAnonymously() async => throw UnimplementedError();
  @override
  Future<void> signOut() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  testWidgets('LoginScreen initial UI and buttons', (WidgetTester tester) async {
    final mockAuth = MockAuthState();
    final mockApp = MockAppState();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthStateProvider>.value(value: mockAuth),
          ChangeNotifierProvider<AppState>.value(value: mockApp),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Check title
    expect(find.text('VenueVantage'), findsOneWidget);
    
    // Check buttons exist
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);

    // Tap Guest Access
    await tester.tap(find.text('Continue as Guest'));
    await tester.pump();
    
    expect(mockAuth.guestSignInCalled, isTrue);

    // Tap Google SignIn
    await tester.tap(find.text('Continue with Google'));
    await tester.pump(const Duration(milliseconds: 500));
    
    expect(mockAuth.signInCalled, isTrue);
  });
}
