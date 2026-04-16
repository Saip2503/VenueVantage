import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/app_state.dart';
import 'firestore_service.dart';

/// FCM background message handler — must be top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handling: Flutter handles notification display automatically.
  // Add any data-only background processing here if needed.
}

/// Firebase Cloud Messaging service.
/// Registers for push notifications and routes messages into [AppState].
class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirestoreService _db;

  FcmService(this._db);

  // ── Initialise ────────────────────────────────────────────────────────────
  Future<void> initialise(String uid) async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request notification permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Get APNS token first on iOS
      if (!kIsWeb) {
        await _messaging.getAPNSToken();
      }

      // Get FCM token and save to Firestore
      final token = await _messaging.getToken(
        // Required for web — this is the VAPID key from Firebase console
        // For now leave null; add VAPID key after enabling web push in Firebase
        // vapidKey: 'YOUR_VAPID_KEY',
      );
      if (token != null) {
        await _db.registerFcmToken(uid, token);
      }

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen((newToken) {
        _db.registerFcmToken(uid, newToken);
      });
    }
  }

  // ── Foreground message handler ────────────────────────────────────────────
  /// Call after [AppState] is ready. Routes foreground FCM messages
  /// directly into the in-app alerts feed.
  void listenForMessages(AppState appState) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      // Determine alert type from custom data payload
      final typeStr = message.data['type'] as String? ?? 'info';
      final alertType = AlertType.values.firstWhere(
        (t) => t.name == typeStr,
        orElse: () => AlertType.info,
      );

      appState.injectAlert(Alert(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: notification.title ?? 'VenueVantage Update',
        body: notification.body ?? '',
        type: alertType,
        time: DateTime.now(),
      ));
    });

    // Handle notification taps when app is in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Could navigate to Alerts screen — handled via AppState flag
    });
  }

  // ── Get initial message (app opened from terminated state via notification) ─
  Future<RemoteMessage?> getInitialMessage() =>
      _messaging.getInitialMessage();
}
