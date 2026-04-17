import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venue_vantage/providers/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppState Tests', () {
    test('initial values', () {
      final state = AppState();
      expect(state.selectedIndex, 0);
      expect(state.isDarkMode, true);
      expect(state.isLoading, true);
    });

    test('update navigation index', () {
      final state = AppState();
      state.setSelectedIndex(2);
      expect(state.selectedIndex, 2);
    });

    test('toggle theme', () {
      final state = AppState();
      final initialTheme = state.isDarkMode;
      state.toggleTheme();
      expect(state.isDarkMode, !initialTheme);
    });

    test('cart operations', () {
      final state = AppState();
      
      final item = CartItem(
        id: '1',
        name: 'Hot Dog',
        price: 5.0,
        quantity: 1,
        emoji: '🌭',
      );
      
      state.addToCart(item);
      expect(state.cartItemCount, 1);
      expect(state.cartTotal, 5.0);

      state.addToCart(item); // Should increase quantity
      expect(state.cartItemCount, 2);
      expect(state.cartTotal, 10.0);

      state.removeFromCart('1');
      expect(state.cartItemCount, 1);

      state.clearCart();
      expect(state.cartItemCount, 0);
    });

    test('seat info sync', () {
      final state = AppState();
      state.setSeatInfo('A', '10', '5');
      expect(state.section, 'A');
      expect(state.row, '10');
      expect(state.seat, '5');
      expect(state.seatLabel, 'Section A, Row 10, Seat 5');
    });
  });
}
