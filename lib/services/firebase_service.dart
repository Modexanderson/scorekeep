// services/firebase_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;

  static FirebaseAnalytics get analytics => _analytics!;
  static FirebaseCrashlytics get crashlytics => _crashlytics!;

  static Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Enable crashlytics collection
      await _crashlytics!.setCrashlyticsCollectionEnabled(!kDebugMode);

      // Set custom keys for better crash analysis
      await _crashlytics!.setCustomKey('app_version', '1.0.0');

      print('Firebase services initialized successfully');
    } catch (e) {
      print('Failed to initialize Firebase: $e');
    }
  }

  // Analytics Events
  static Future<void> logAppOpen() async {
    await _analytics?.logAppOpen();
  }

  static Future<void> logGameCreated({
    required String gameName,
    required int playerCount,
  }) async {
    await _analytics?.logEvent(
      name: 'game_created',
      parameters: {
        'game_name': gameName,
        'player_count': playerCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logScoreAdded({
    required String gameId,
    required String playerName,
    required int scoreChange,
    required String method, // 'increment', 'decrement', 'custom'
  }) async {
    await _analytics?.logEvent(
      name: 'score_added',
      parameters: {
        'game_id': gameId,
        'player_name': playerName,
        'score_change': scoreChange,
        'method': method,
      },
    );
  }

  static Future<void> logGameSessionEnd({
    required String gameId,
    required int sessionDurationMinutes,
    required int totalScoreChanges,
  }) async {
    await _analytics?.logEvent(
      name: 'game_session_end',
      parameters: {
        'game_id': gameId,
        'session_duration_minutes': sessionDurationMinutes,
        'total_score_changes': totalScoreChanges,
      },
    );
  }

  static Future<void> logFeatureUsed(String featureName) async {
    await _analytics?.logEvent(
      name: 'feature_used',
      parameters: {
        'feature_name': featureName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logScreenView(String screenName) async {
    await _analytics?.logScreenView(screenName: screenName);
  }

  static Future<void> logAdClicked(String adType) async {
    await _analytics?.logEvent(
      name: 'ad_clicked',
      parameters: {
        'ad_type': adType,
      },
    );
  }

  static Future<void> logPurchaseAttempt(String productId) async {
    await _analytics?.logEvent(
      name: 'purchase_attempt',
      parameters: {
        'product_id': productId,
      },
    );
  }

  static Future<void> logPurchaseSuccess(String productId, double price) async {
    await _analytics?.logPurchase(
      currency: 'USD',
      value: price,
      parameters: {
        'product_id': productId,
      },
    );
  }

  // Crashlytics Methods
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics?.recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  static Future<void> log(String message) async {
    await _crashlytics?.log(message);
  }

  static Future<void> setUserIdentifier(String identifier) async {
    await _crashlytics?.setUserIdentifier(identifier);
    await _analytics?.setUserId(id: identifier);
  }

  static Future<void> setCustomKey(String key, Object value) async {
    await _crashlytics?.setCustomKey(key, value);
  }
}
