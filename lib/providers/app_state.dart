import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_data.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class MenuItem {
  final String id, name, description, emoji, category;
  final double price;
  const MenuItem({required this.id, required this.name, required this.description, required this.price, required this.emoji, required this.category});
}

class CartItem {
  final String id, name, emoji;
  final double price;
  int quantity;
  CartItem({required this.id, required this.name, required this.price, required this.quantity, required this.emoji});
}

class Alert {
  final String id, title, body;
  final AlertType type;
  final DateTime time;
  bool isRead;
  Alert({required this.id, required this.title, required this.body, required this.type, required this.time, this.isRead = false});
}

enum AlertType { info, warning, urgent, success }

class PointOfInterest {
  final String id, name, waitTime;
  final POIType type;
  final double x, y;
  final int crowdLevel;
  const PointOfInterest({required this.id, required this.name, required this.type, required this.x, required this.y, required this.crowdLevel, required this.waitTime});
}

enum POIType { restroom, food, merch, exit, medical, parking }

enum OrderTrackingStep { placed, preparing, onTheWay, delivered }

// ── AppState ──────────────────────────────────────────────────────────────────

class AppState extends ChangeNotifier {
  AppState() {
    _loadPrefs();
    _startLiveAlertSimulation();
  }

  // ── Theme ──────────────────────────────────────────────────────────────────
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs?.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  // ── Seat Info ──────────────────────────────────────────────────────────────
  String _section = '14';
  String _row = 'C';
  String _seat = '3';
  bool _onboardingDone = false;

  String get section => _section;
  String get row => _row;
  String get seat => _seat;
  bool get onboardingDone => _onboardingDone;
  String get seatLabel => 'Section $_section, Row $_row, Seat $_seat';

  void setSeatInfo(String section, String row, String seat) {
    _section = section; _row = row; _seat = seat;
    _prefs?.setString('section', section);
    _prefs?.setString('row', row);
    _prefs?.setString('seat', seat);
    notifyListeners();
  }

  void completeOnboarding() {
    _onboardingDone = true;
    _prefs?.setBool('onboarding_done', true);
    notifyListeners();
  }

  // ── Prefs ──────────────────────────────────────────────────────────────────
  SharedPreferences? _prefs;
  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool('dark_mode') ?? true;
    _onboardingDone = _prefs?.getBool('onboarding_done') ?? false;
    _section = _prefs?.getString('section') ?? '14';
    _row = _prefs?.getString('row') ?? 'C';
    _seat = _prefs?.getString('seat') ?? '3';
    _favourites = Set.from(_prefs?.getStringList('favourites') ?? []);
    notifyListeners();
  }

  // ── Favourites ─────────────────────────────────────────────────────────────
  Set<String> _favourites = {};
  Set<String> get favourites => _favourites;

  bool isFavourite(String id) => _favourites.contains(id);

  void toggleFavourite(String id) {
    if (_favourites.contains(id)) {
      _favourites.remove(id);
    } else {
      _favourites.add(id);
    }
    _prefs?.setStringList('favourites', _favourites.toList());
    notifyListeners();
  }

  // ── Cart ───────────────────────────────────────────────────────────────────
  final List<CartItem> _cart = [];
  List<CartItem> get cart => List.unmodifiable(_cart);
  double get cartTotal => _cart.fold(0, (s, i) => s + i.price * i.quantity);
  int get cartItemCount => _cart.fold(0, (s, i) => s + i.quantity);

  void addToCart(CartItem item) {
    final existing = _cart.where((i) => i.id == item.id).firstOrNull;
    if (existing != null) { existing.quantity++; } else {
      _cart.add(CartItem(id: item.id, name: item.name, price: item.price, quantity: 1, emoji: item.emoji));
    }
    notifyListeners();
  }

  void removeFromCart(String id) {
    final existing = _cart.where((i) => i.id == id).firstOrNull;
    if (existing != null) {
      if (existing.quantity > 1) { existing.quantity--; } else { _cart.removeWhere((i) => i.id == id); }
    }
    notifyListeners();
  }

  void clearCart() { _cart.clear(); notifyListeners(); }

  // ── Order Tracking ─────────────────────────────────────────────────────────
  OrderTrackingStep _orderStep = OrderTrackingStep.placed;
  Timer? _orderTimer;
  String? _activeOrderId;

  OrderTrackingStep get orderStep => _orderStep;
  String? get activeOrderId => _activeOrderId;

  void placeOrder() {
    _activeOrderId = 'VV-${DateTime.now().millisecondsSinceEpoch % 10000}';
    _orderStep = OrderTrackingStep.placed;
    clearCart();
    _orderTimer?.cancel();
    // Auto-progress through steps
    _orderTimer = Timer.periodic(const Duration(seconds: 8), (t) {
      if (_orderStep == OrderTrackingStep.delivered) { t.cancel(); return; }
      _orderStep = OrderTrackingStep.values[_orderStep.index + 1];
      notifyListeners();
    });
    notifyListeners();
  }

  void resetOrder() { _activeOrderId = null; _orderStep = OrderTrackingStep.placed; notifyListeners(); }

  // ── Alerts ─────────────────────────────────────────────────────────────────
  late List<Alert> _alerts = buildMockAlerts();
  List<Alert> get alerts => List.unmodifiable(_alerts);
  bool get hasUnreadAlerts => _alerts.any((a) => !a.isRead);

  void markAlertRead(String id) {
    final a = _alerts.where((a) => a.id == id).firstOrNull;
    if (a != null && !a.isRead) { a.isRead = true; notifyListeners(); }
  }

  void markAllRead() { for (final a in _alerts) { a.isRead = true; } notifyListeners(); }

  void dismissAlert(String id) { _alerts.removeWhere((a) => a.id == id); notifyListeners(); }

  int _liveAlertIndex = 0;
  Timer? _alertTimer;
  void _startLiveAlertSimulation() {
    _alertTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (_liveAlertIndex >= kLiveAlertPool.length) return;
      final template = kLiveAlertPool[_liveAlertIndex++];
      _alerts.insert(0, Alert(
        id: 'live_${DateTime.now().millisecondsSinceEpoch}',
        title: template.title, body: template.body,
        type: template.type, time: DateTime.now(),
      ));
      notifyListeners();
    });
  }

  // ── Map ────────────────────────────────────────────────────────────────────
  final List<PointOfInterest> pointsOfInterest = kPointsOfInterest;
  PointOfInterest? _selectedPOI;
  PointOfInterest? get selectedPOI => _selectedPOI;
  void selectPOI(PointOfInterest? poi) { _selectedPOI = poi; notifyListeners(); }

  bool _showSeatPath = false;
  bool get showSeatPath => _showSeatPath;
  void toggleSeatPath() { _showSeatPath = !_showSeatPath; notifyListeners(); }

  // ── Crowd Trend ─────────────────────────────────────────────────────────────
  List<double> get crowdTrend => kCrowdTrendData;
  List<String> get crowdTrendLabels => kCrowdTrendLabels;

  // ── Simulated Loading ──────────────────────────────────────────────────────
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1500));
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _orderTimer?.cancel();
    _alertTimer?.cancel();
    super.dispose();
  }
}
