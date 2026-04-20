import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../providers/app_state.dart';
import '../data/mock_data.dart';

/// Venue ID used for all venue-scoped Firestore reads.
/// Change this to support multi-venue in the future.
const String kDefaultVenueId = 'apex-arena';

/// Central Firestore data access layer.
///
/// All reads are real-time streams. Writes are fire-and-forget Futures.
/// Falls back to mock data if Firestore is unavailable (offline mode).
class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  // ── Venue collection refs ──────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> _venue(String sub) =>
      _db.collection('venues').doc(kDefaultVenueId).collection(sub);

  // ── Menu Items — real-time stream ─────────────────────────────────────────
  Stream<List<MenuItem>> menuStream() {
    return _venue('menuItems')
        .orderBy('category')
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docToMenuItem(d)).toList())
        .handleError((_) => kMenuItems); // offline fallback
  }

  MenuItem _docToMenuItem(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    return MenuItem(
      id: d.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      emoji: data['emoji'] ?? '🍴',
      category: data['category'] ?? 'Other',
    );
  }

  // ── Alerts — real-time stream ──────────────────────────────────────────────
  Stream<List<Alert>> alertsStream() {
    return _venue('alerts')
        .orderBy('time', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docToAlert(d)).toList())
        .handleError((_) => buildMockAlerts());
  }

  Alert _docToAlert(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    final typeStr = data['type'] as String? ?? 'info';
    return Alert(
      id: d.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: AlertType.values.firstWhere(
        (t) => t.name == typeStr,
        orElse: () => AlertType.info,
      ),
      time: (data['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  // ── Venue Stats — real-time stream ────────────────────────────────────────
  Stream<VenueStats> statsStream() {
    return _db
        .collection('venues')
        .doc(kDefaultVenueId)
        .collection('stats')
        .doc('live')
        .snapshots()
        .map((snap) {
          if (!snap.exists) return VenueStats.defaults();
          final data = snap.data()!;
          return VenueStats(
            capacityPct: (data['capacityPct'] as num?)?.toDouble() ?? 89,
            avgWaitMin: (data['avgWaitMin'] as num?)?.toInt() ?? 8,
            bestExit: data['bestExit'] as String? ?? 'A',
            tempCelsius: (data['tempCelsius'] as num?)?.toDouble() ?? 24,
            crowdTrend: List<double>.from(
              (data['crowdTrend'] as List? ?? kCrowdTrendData)
                  .map((e) => (e as num).toDouble()),
            ),
            sectionData: List<Map<String, dynamic>>.from(
              data['sectionData'] as List? ?? kSectionData,
            ),
          );
        })
        .handleError((_) => VenueStats.defaults());
  }

  // ── Points of Interest — real-time stream ─────────────────────────────────
  Stream<List<PointOfInterest>> poisStream() {
    return _venue('pois')
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docToPoi(d)).toList())
        .handleError((_) => kPointsOfInterest.toList());
  }

  PointOfInterest _docToPoi(
      QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    final typeStr = data['type'] as String? ?? 'food';
    return PointOfInterest(
      id: d.id,
      name: data['name'] ?? '',
      type: POIType.values.firstWhere(
        (t) => t.name == typeStr,
        orElse: () => POIType.food,
      ),
      x: (data['x'] as num?)?.toDouble() ?? 0.5,
      y: (data['y'] as num?)?.toDouble() ?? 0.5,
      lat: (data['lat'] as num?)?.toDouble() ?? 19.0424,
      lng: (data['lng'] as num?)?.toDouble() ?? 73.0265,
      crowdLevel: (data['crowdLevel'] as num?)?.toInt() ?? 50,
      waitTime: data['waitTime'] as String? ?? '—',
    );
  }

  // ── User Profile ───────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserProfile(String uid, {
    required String section,
    required String row,
    required String seat,
  }) async {
    await _db.collection('users').doc(uid).set({
      'section': section,
      'row': row,
      'seat': seat,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── FCM Token ──────────────────────────────────────────────────────────────
  Future<void> registerFcmToken(String uid, String token) async {
    await _db.collection('users').doc(uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Orders ─────────────────────────────────────────────────────────────────
  Future<String> placeOrder(String uid, List<CartItem> cart, double total) async {
    final ref = await _db.collection('users').doc(uid).collection('orders').add({
      'items': cart.map((item) => {
        'id': item.id,
        'name': item.name,
        'emoji': item.emoji,
        'price': item.price,
        'quantity': item.quantity,
      }).toList(),
      'total': total,
      'status': 'placed',
      'placedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Stream<List<OrderModel>> ordersStream(String uid) {
    return _db.collection('users').doc(uid).collection('orders')
        .orderBy('placedAt', descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs.map((d) {
            try {
              return _docToOrder(d);
            } catch (e) {
              debugPrint("Error converting order ${d.id}: $e");
              return null;
            }
          }).whereType<OrderModel>().toList();
        });
  }

  OrderModel _docToOrder(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    final itemsList = (data['items'] as List? ?? []);
    
    // Ensure we handle potential nulls or type mismatches from Firestore
    return OrderModel(
      id: d.id,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: data['status']?.toString() ?? 'placed',
      time: (data['placedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: itemsList.map((i) {
        final itemMap = i as Map<String, dynamic>;
        return OrderItem(
          name: itemMap['name']?.toString() ?? 'Item',
          emoji: itemMap['emoji']?.toString() ?? '🍴',
          quantity: (itemMap['quantity'] as num?)?.toInt() ?? 1,
        );
      }).toList(),
    );
  }

  // ── Venue Stats seeding (run once) ────────────────────────────────────────
  /// Seeds Firestore with mock data if collections are empty.
  /// Call from a one-time admin action or the Firebase console.
  Future<void> seedVenueData() async {
    final batch = _db.batch();
    final venueRef = _db.collection('venues').doc(kDefaultVenueId);

    // Menu items
    for (final item in kMenuItems) {
      final ref = venueRef.collection('menuItems').doc(item.id);
      batch.set(ref, {
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'emoji': item.emoji,
        'category': item.category,
      });
    }

    // POIs
    for (final poi in kPointsOfInterest) {
      final ref = venueRef.collection('pois').doc(poi.id);
      batch.set(ref, {
        'name': poi.name,
        'type': poi.type.name,
        'x': poi.x,
        'y': poi.y,
        'lat': poi.lat,
        'lng': poi.lng,
        'crowdLevel': poi.crowdLevel,
        'waitTime': poi.waitTime,
      });
    }

    // Live stats doc
    batch.set(venueRef.collection('stats').doc('live'), {
      'capacityPct': 89,
      'avgWaitMin': 8,
      'bestExit': 'A',
      'tempCelsius': 24,
      'crowdTrend': kCrowdTrendData,
      'sectionData': kSectionData,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Initial alerts
    for (final alert in buildMockAlerts()) {
      final ref = venueRef.collection('alerts').doc(alert.id);
      batch.set(ref, {
        'title': alert.title,
        'body': alert.body,
        'type': alert.type.name,
        'time': Timestamp.fromDate(alert.time),
        'isRead': alert.isRead,
      });
    }

    await batch.commit();
  }
}

// ── VenueStats model ────────────────────────────────────────────────────────

class VenueStats {
  final double capacityPct;
  final int avgWaitMin;
  final String bestExit;
  final double tempCelsius;
  final List<double> crowdTrend;
  final List<Map<String, dynamic>> sectionData;

  const VenueStats({
    required this.capacityPct,
    required this.avgWaitMin,
    required this.bestExit,
    required this.tempCelsius,
    required this.crowdTrend,
    required this.sectionData,
  });

  factory VenueStats.defaults() => VenueStats(
        capacityPct: 89,
        avgWaitMin: 8,
        bestExit: 'A',
        tempCelsius: 24,
        crowdTrend: kCrowdTrendData,
        sectionData: kSectionData,
      );
}

// ── Order models ────────────────────────────────────────────────────────────

class OrderModel {
  final String id;
  final double total;
  final String status;
  final DateTime time;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.total,
    required this.status,
    required this.time,
    required this.items,
  });
}

class OrderItem {
  final String name;
  final String emoji;
  final int quantity;
  OrderItem({required this.name, required this.emoji, required this.quantity});
}
