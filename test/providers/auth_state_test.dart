import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:venue_vantage/providers/auth_state.dart';
import 'package:venue_vantage/services/auth_service.dart';

class MockAuthService implements AuthService {
  @override
  Stream<User?> get userStream => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AuthStateProvider Tests', () {
    test('initial state is loading', () {
      final state = AuthStateProvider(authService: MockAuthService());
      expect(state.isLoading, true);
      expect(state.isAuthenticated, false);
      expect(state.isAnonymous, false);
      expect(state.isLoggedOut, false);
    });

    test('clear error works', () {
      final state = AuthStateProvider(authService: MockAuthService());
      expect(state.errorMessage, null);
      state.clearError();
      expect(state.errorMessage, null);
    });

    test('display name fallback', () {
      final state = AuthStateProvider(authService: MockAuthService());
      expect(state.displayName, 'Guest');
      expect(state.initials, 'G');
    });
  });
}
