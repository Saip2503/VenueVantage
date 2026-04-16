// lib/data/mock_data.dart
// Centralised mock data layer – easy to swap with real API responses later.

import '../providers/app_state.dart';

// ── Menu ──────────────────────────────────────────────────────────────────────
const List<MenuItem> kMenuItems = [
  MenuItem(id: 'm1', name: 'Loaded Nachos', description: 'Tortilla chips, cheddar, jalapeños, sour cream', price: 12.99, emoji: '🧀', category: 'Snacks'),
  MenuItem(id: 'm2', name: 'Stadium Hot Dog', description: 'Grilled beef dog in brioche bun with mustard', price: 8.49, emoji: '🌭', category: 'Snacks'),
  MenuItem(id: 'm3', name: 'BBQ Chicken Wings', description: '6 wings with smoky BBQ sauce & ranch', price: 14.99, emoji: '🍗', category: 'Mains'),
  MenuItem(id: 'm4', name: 'Spicy Chicken Sandwich', description: 'Crispy fried chicken, spicy mayo, coleslaw', price: 13.49, emoji: '🥪', category: 'Mains'),
  MenuItem(id: 'm5', name: 'Beer (Pint)', description: 'Draft lager, served ice cold', price: 9.00, emoji: '🍺', category: 'Drinks'),
  MenuItem(id: 'm6', name: 'Soft Drink (Large)', description: 'Choice of Coke, Sprite, or Fanta', price: 5.50, emoji: '🥤', category: 'Drinks'),
  MenuItem(id: 'm7', name: 'Mineral Water', description: 'Still or sparkling, 500ml', price: 3.00, emoji: '💧', category: 'Drinks'),
  MenuItem(id: 'm8', name: 'Brownie Sundae', description: 'Warm chocolate brownie with vanilla ice cream', price: 7.99, emoji: '🍫', category: 'Desserts'),
  MenuItem(id: 'm9', name: 'Churros', description: 'Golden fried dough with cinnamon sugar & dip', price: 6.99, emoji: '🍩', category: 'Desserts'),
  MenuItem(id: 'm10', name: 'Veggie Wrap', description: 'Grilled veggies, hummus, feta in a whole wheat wrap', price: 10.99, emoji: '🌯', category: 'Mains'),
];

// ── Alerts ────────────────────────────────────────────────────────────────────
List<Alert> buildMockAlerts() => [
  Alert(id: 'a1', title: '🏟️ Gates Open', body: 'Gates A, B, and C are now open. Enjoy the pre-show activities!', type: AlertType.info, time: DateTime.now().subtract(const Duration(minutes: 45))),
  Alert(id: 'a2', title: '⚠️ Section D Congestion', body: 'High crowd density detected near Section D concessions. Consider using Section F instead.', type: AlertType.warning, time: DateTime.now().subtract(const Duration(minutes: 20))),
  Alert(id: 'a3', title: '🍕 Your Order is Ready!', body: 'Order #VV-4521 – Nacho Platter & Drinks are on their way to your seat.', type: AlertType.success, time: DateTime.now().subtract(const Duration(minutes: 8)), isRead: false),
  Alert(id: 'a4', title: '🚨 Emergency Drill', body: 'A scheduled emergency evacuation drill will take place at Entrance 2 at 7:30 PM. Please remain calm.', type: AlertType.urgent, time: DateTime.now().subtract(const Duration(minutes: 2)), isRead: false),
];

// ── Live Alerts (injected periodically) ───────────────────────────────────────
List<Alert> kLiveAlertPool = [
  Alert(id: 'live1', title: '⚡ Flash Deal – 20% Off Nachos', body: 'Limited time: 20% off Loaded Nachos for the next 10 minutes via in-app order!', type: AlertType.info, time: DateTime.now()),
  Alert(id: 'live2', title: '🚽 Restroom – South Wing Clear', body: 'Restrooms near South Exit now have minimal wait. Best time to go!', type: AlertType.success, time: DateTime.now()),
  Alert(id: 'live3', title: '🎵 Halftime Show Starting', body: 'The halftime performance begins in 2 minutes at the centre stage.', type: AlertType.info, time: DateTime.now()),
  Alert(id: 'live4', title: '⚠️ Gate B Closing Early', body: 'Gate B will close in 15 minutes. Please use Gate A or Gate C for exit.', type: AlertType.warning, time: DateTime.now()),
];

// ── Points of Interest ────────────────────────────────────────────────────────
const List<PointOfInterest> kPointsOfInterest = [
  PointOfInterest(id: 'p1', name: 'Main Concessions', type: POIType.food, x: 0.3, y: 0.25, crowdLevel: 72, waitTime: '12 min'),
  PointOfInterest(id: 'p2', name: 'East Food Court', type: POIType.food, x: 0.72, y: 0.3, crowdLevel: 35, waitTime: '4 min'),
  PointOfInterest(id: 'p3', name: 'Restrooms – North', type: POIType.restroom, x: 0.45, y: 0.12, crowdLevel: 55, waitTime: '7 min'),
  PointOfInterest(id: 'p4', name: 'Restrooms – South', type: POIType.restroom, x: 0.5, y: 0.85, crowdLevel: 20, waitTime: '2 min'),
  PointOfInterest(id: 'p5', name: 'Merch Store', type: POIType.merch, x: 0.2, y: 0.55, crowdLevel: 60, waitTime: '9 min'),
  PointOfInterest(id: 'p6', name: 'Exit A – Optimal', type: POIType.exit, x: 0.08, y: 0.5, crowdLevel: 15, waitTime: '3 min'),
  PointOfInterest(id: 'p7', name: 'Exit B', type: POIType.exit, x: 0.92, y: 0.5, crowdLevel: 80, waitTime: '18 min'),
  PointOfInterest(id: 'p8', name: 'Medical Station', type: POIType.medical, x: 0.55, y: 0.5, crowdLevel: 10, waitTime: 'Immediate'),
  PointOfInterest(id: 'p9', name: 'Parking Shuttle', type: POIType.parking, x: 0.8, y: 0.8, crowdLevel: 45, waitTime: '6 min'),
];

// ── Crowd Trend Data (last 30 minutes, 6 data points) ────────────────────────
const List<double> kCrowdTrendData = [45, 58, 63, 71, 78, 85];
const List<String> kCrowdTrendLabels = ['-30m', '-24m', '-18m', '-12m', '-6m', 'Now'];

// ── Section crowd breakdown ───────────────────────────────────────────────────
const List<Map<String, dynamic>> kSectionData = [
  {'section': 'A', 'crowd': 92.0, 'color': 0xFFEF4444},
  {'section': 'B', 'crowd': 78.0, 'color': 0xFFF59E0B},
  {'section': 'C', 'crowd': 65.0, 'color': 0xFFF59E0B},
  {'section': 'D', 'crowd': 88.0, 'color': 0xFFEF4444},
  {'section': 'E', 'crowd': 45.0, 'color': 0xFF10B981},
  {'section': 'F', 'crowd': 30.0, 'color': 0xFF10B981},
];
