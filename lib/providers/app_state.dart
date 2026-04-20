import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venue_vantage/services/api_repository.dart';
import '../data/mock_data.dart';
import '../services/firestore_service.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class MenuItem {
  final String id, name, description, emoji, category;
  final double price;
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.emoji,
    required this.category,
  });
}

class CartItem {
  final String id, name, emoji;
  final double price;
  int quantity;
  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.emoji,
  });
}

class Alert {
  final String id, title, body;
  final AlertType type;
  final DateTime time;
  bool isRead;
  Alert({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    this.isRead = false,
  });
}

enum AlertType { info, warning, urgent, success }

class PointOfInterest {
  final String id, name, waitTime;
  final POIType type;
  final double x, y;
  final double lat, lng;
  final int crowdLevel;
  const PointOfInterest({
    required this.id,
    required this.name,
    required this.type,
    required this.x,
    required this.y,
    required this.lat,
    required this.lng,
    required this.crowdLevel,
    required this.waitTime,
  });
}

enum POIType { restroom, food, merch, exit, medical, parking }

enum OrderTrackingStep { placed, preparing, onTheWay, delivered }

// ── AppState ──────────────────────────────────────────────────────────────────

class AppState extends ChangeNotifier {
  final FirestoreService _fs;
  final ApiRepository _api;

  AppState({
    FirestoreService? firestoreService,
    ApiRepository? apiRepository,
  }) : _fs = firestoreService ?? FirestoreService(),
       _api = apiRepository ?? ApiRepository() {
    _loadPrefs();
    // Wrap in try-catch in case Firestore isn't initialized during tests
    try {
      _subscribeToFirestore();
    } catch (_) {}
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    if (index != _selectedIndex) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  // ── Theme ──────────────────────────────────────────────────────────────────
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs?.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  // ── Preferences ────────────────────────────────────────────────────────────
  bool _notificationsEnabled = true;
  bool _hapticsEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    _prefs?.setBool('notifications_enabled', value);
    notifyListeners();
  }

  void toggleHaptics(bool value) {
    _hapticsEnabled = value;
    _prefs?.setBool('haptics_enabled', value);
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
    _section = section;
    _row = row;
    _seat = seat;
    _prefs?.setString('section', section);
    _prefs?.setString('row', row);
    _prefs?.setString('seat', seat);
    notifyListeners();
  }

  /// Saves seat to both SharedPreferences (offline) and Firestore (cloud sync).
  Future<void> setSeatInfoWithSync(
    String uid,
    String section,
    String row,
    String seat,
  ) async {
    setSeatInfo(section, row, seat);
    await _fs.saveUserProfile(uid, section: section, row: row, seat: seat);
  }

  void completeOnboarding() {
    _onboardingDone = true;
    _prefs?.setBool('onboarding_done', true);
    notifyListeners();
  }

  // ── SharedPreferences ──────────────────────────────────────────────────────
  SharedPreferences? _prefs;

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool('dark_mode') ?? true;
    _onboardingDone = _prefs?.getBool('onboarding_done') ?? false;
    _section = _prefs?.getString('section') ?? '14';
    _row = _prefs?.getString('row') ?? 'C';
    _seat = _prefs?.getString('seat') ?? '3';
    _notificationsEnabled = _prefs?.getBool('notifications_enabled') ?? true;
    _hapticsEnabled = _prefs?.getBool('haptics_enabled') ?? true;
    _favourites = Set.from(_prefs?.getStringList('favourites') ?? []);
    notifyListeners();
  }

  // ── Firestore Subscriptions ────────────────────────────────────────────────
  StreamSubscription<List<MenuItem>>? _menuSub;
  StreamSubscription<List<Alert>>? _alertsSub;
  StreamSubscription<VenueStats>? _statsSub;
  StreamSubscription<List<PointOfInterest>>? _poisSub;

  void _subscribeToFirestore() {
    _isLoading = true;

    // Menu items
    _menuSub = _fs.menuStream().listen(
      (items) {
        _menuItems = items;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _menuItems = kMenuItems;
        _isLoading = false;
        notifyListeners();
      },
    );

    // Alerts
    _alertsSub = _fs.alertsStream().listen(
      (items) {
        // Merge: keep local read-state so marking read isn't overwritten
        final readIds = _alerts.where((a) => a.isRead).map((a) => a.id).toSet();
        _alerts = items.map((a) {
          if (readIds.contains(a.id)) {
            return Alert(
              id: a.id,
              title: a.title,
              body: a.body,
              type: a.type,
              time: a.time,
              isRead: true,
            );
          }
          return a;
        }).toList();
        notifyListeners();
      },
      onError: (_) {
        _alerts = buildMockAlerts();
        notifyListeners();
      },
    );

    // Live stats
    _statsSub = _fs.statsStream().listen(
      (stats) {
        _venueStats = stats;
        notifyListeners();
      },
      onError: (_) {
        _venueStats = VenueStats.defaults();
        notifyListeners();
      },
    );

    // POIs
    _poisSub = _fs.poisStream().listen(
      (pois) {
        _pois = pois;
        notifyListeners();
      },
      onError: (_) {
        _pois = kPointsOfInterest.toList();
        notifyListeners();
      },
    );
  }

  // ── Firestore: seed venue data on first run ────────────────────────────────
  bool _seeded = false;
  Future<void> seedIfNeeded() async {
    if (_seeded) return;
    _seeded = true;
    await _fs.seedVenueData();
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
    if (existing != null) {
      existing.quantity++;
    } else {
      _cart.add(
        CartItem(
          id: item.id,
          name: item.name,
          price: item.price,
          quantity: 1,
          emoji: item.emoji,
        ),
      );
    }
    notifyListeners();
  }

  void removeFromCart(String id) {
    final existing = _cart.where((i) => i.id == id).firstOrNull;
    if (existing != null) {
      if (existing.quantity > 1) {
        existing.quantity--;
      } else {
        _cart.removeWhere((i) => i.id == id);
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ── Order Tracking ─────────────────────────────────────────────────────────
  OrderTrackingStep _orderStep = OrderTrackingStep.placed;
  Timer? _orderTimer;
  String? _activeOrderId;

  OrderTrackingStep get orderStep => _orderStep;
  String? get activeOrderId => _activeOrderId;

  Future<void> placeOrder(String? uid) async {
    String orderId = 'VV-${DateTime.now().millisecondsSinceEpoch % 10000}';
    // Persist to Firestore if user is authenticated
    if (uid != null) {
      try {
        final fsId = await _fs.placeOrder(uid, _cart, cartTotal);
        orderId = fsId;
      } catch (e) {
        debugPrint("Order Checkout Error: $e");
        // Fall through with local ID
      }
    }
    _activeOrderId = orderId;
    _orderStep = OrderTrackingStep.placed;
    clearCart();
    _orderTimer?.cancel();
    _orderTimer = Timer.periodic(const Duration(seconds: 8), (t) {
      if (_orderStep == OrderTrackingStep.delivered) {
        t.cancel();
        return;
      }
      _orderStep = OrderTrackingStep.values[_orderStep.index + 1];
      notifyListeners();
    });
    notifyListeners();
  }

  void resetOrder() {
    _activeOrderId = null;
    _orderStep = OrderTrackingStep.placed;
    notifyListeners();
  }

  // ── Alerts ─────────────────────────────────────────────────────────────────
  List<Alert> _alerts = [];
  List<Alert> get alerts => List.unmodifiable(_alerts);
  bool get hasUnreadAlerts => _alerts.any((a) => !a.isRead);

  void markAlertRead(String id) {
    final a = _alerts.where((a) => a.id == id).firstOrNull;
    if (a != null && !a.isRead) {
      a.isRead = true;
      notifyListeners();
    }
  }

  void markAllRead() {
    for (final a in _alerts) {
      a.isRead = true;
    }
    notifyListeners();
  }

  void dismissAlert(String id) {
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  /// Called by FcmService when a foreground push notification arrives.
  void injectAlert(Alert alert) {
    _alerts.insert(0, alert);
    notifyListeners();
  }

  // ── Map / POIs ─────────────────────────────────────────────────────────────
  List<PointOfInterest> _pois = kPointsOfInterest.toList();
  List<PointOfInterest> get pointsOfInterest => _pois;

  PointOfInterest? _selectedPOI;
  PointOfInterest? get selectedPOI => _selectedPOI;
  void selectPOI(PointOfInterest? poi) {
    _selectedPOI = poi;
    notifyListeners();
  }

  bool _showSeatPath = false;
  bool get showSeatPath => _showSeatPath;
  void toggleSeatPath() {
    _showSeatPath = !_showSeatPath;
    notifyListeners();
  }

  // ── Menu ───────────────────────────────────────────────────────────────────
  List<MenuItem> _menuItems = kMenuItems;
  List<MenuItem> get menuItems => _menuItems;

  // ── Venue Stats ────────────────────────────────────────────────────────────
  VenueStats _venueStats = VenueStats.defaults();
  VenueStats get venueStats => _venueStats;

  List<double> get crowdTrend => _venueStats.crowdTrend;
  List<String> get crowdTrendLabels => kCrowdTrendLabels;

  // ── Loading / Refresh ──────────────────────────────────────────────────────
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String _bestExit = "Loading...";
  String _eta = "--";
  String _temperature = "--";
  List<dynamic> _places = [];

  String get bestExit => _bestExit;
  String get eta => _eta;
  String get temperature => _temperature;
  List<dynamic> get places => _places;


  bool _isFetchingDynamic = false;
  Future<void> fetchDynamicData() async {
    if (_isFetchingDynamic) return;
    _isFetchingDynamic = true;

    try {
      // Don't set _isLoading = true here to avoid flickering if we already have data
      // but if it's the first time, it might be beneficial.
      // For now, let's keep the user's loading logic if they want it.

      final results = await Future.wait([
        _api.getBestExitData(),
        _api.getWeather(),
        _api.getNearbyPlaces(),
      ]);

      // Smart Exit selection
      final bestExitResult = results[0] as Map<String, dynamic>;
      _bestExit = bestExitResult['exit'];
      _eta = bestExitResult['durationText'];

      // Weather
      _temperature = "${(results[1] as Map<String, dynamic>)['temp']}°C";

      // Places
      _places = results[2] as List<dynamic>;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("API Error: $e");
    } finally {
      _isFetchingDynamic = false;
    }
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    await fetchDynamicData();
    // Re-subscribe — Firestore streams auto-refresh
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _menuSub?.cancel();
    _alertsSub?.cancel();
    _statsSub?.cancel();
    _poisSub?.cancel();
    _orderTimer?.cancel();
    super.dispose();
  }
}
