import 'package:firebase_analytics/firebase_analytics.dart'; // Fixed import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:score_keep/firebase_options.dart';
import 'package:upgrader/upgrader.dart';
import 'pages/home_page.dart';
import 'services/storage_service.dart';
import 'services/firebase_service.dart';
// import 'services/ad_service.dart';
// import 'services/purchase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with better error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Don't let Firebase failure crash the app
  }

  // Initialize services with better error handling
  await _initializeServices();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Add null check for FirebaseService
    try {
      FirebaseService.recordError(
        details.exception,
        details.stack,
        reason: details.toString(),
        fatal: false,
      );
    } catch (e) {
      print('Failed to record error to Firebase: $e');
    }
  };

  runApp(const ScoreKeepApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize storage first
    await StorageService.initialize();
    print('Storage service initialized');

    // Initialize Firebase services with null check
    try {
      await FirebaseService.initialize();
      print('Firebase service initialized');
    } catch (e) {
      print('Firebase service initialization failed: $e');
    }

    // Initialize ad service
    // await AdService.initialize();

    // Initialize purchase service
    // await PurchaseService.initialize();

    // Log app initialization (with null check)
    try {
      await FirebaseService.logAppOpen();
    } catch (e) {
      print('Failed to log app open: $e');
    }

    print('All services initialized successfully');
  } catch (e) {
    print('Service initialization error: $e');
    // Don't let service initialization crash the app
  }
}

class ScoreKeepApp extends StatefulWidget {
  const ScoreKeepApp({super.key});

  @override
  State<ScoreKeepApp> createState() => _ScoreKeepAppState();
}

class _ScoreKeepAppState extends State<ScoreKeepApp>
    with WidgetsBindingObserver {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadThemePreference();

    // Create banner ad after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      // AdService.createBannerAd();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // AdService.disposeBannerAd();
    // PurchaseService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground
        // FirebaseService.logAppOpen();
        // if (!AdService.isBannerAdReady) {
        //   AdService.createBannerAd();
        // }
        break;
      case AppLifecycleState.paused:
        // App went to background
        try {
          FirebaseService.log('App paused');
        } catch (e) {
          print('Failed to log app pause: $e');
        }
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        try {
          FirebaseService.log('App terminated');
        } catch (e) {
          print('Failed to log app termination: $e');
        }
        break;
      case AppLifecycleState.inactive:
        // App is inactive (iOS)
        break;
      case AppLifecycleState.hidden:
        // App is hidden (desktop)
        break;
    }
  }

  Future<void> _loadThemePreference() async {
    try {
      final settings = await StorageService.loadSettings();
      if (mounted) {
        setState(() {
          _isDarkMode = settings['darkMode'] ?? false;
        });
      }
    } catch (e) {
      print('Failed to load theme preference: $e');
      try {
        await FirebaseService.recordError(e, StackTrace.current);
      } catch (firebaseError) {
        print('Failed to record error to Firebase: $firebaseError');
      }
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });

    try {
      StorageService.saveSettings({'darkMode': _isDarkMode});
      FirebaseService.logFeatureUsed('theme_toggle');
    } catch (e) {
      print('Failed to save theme preference: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScoreKeep',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: UpgradeAlert(
        // Force upgrade settings
        showIgnore: false,
        showLater: false,
        barrierDismissible: false,
        shouldPopScope: () => false,

        upgrader: Upgrader(
          debugDisplayAlways: false, // Set to true for testing
          debugLogging: false,
          countryCode: 'US',
          languageCode: 'en',
        ),

        child: HomePage(
          onThemeToggle: _toggleTheme,
          isDarkMode: _isDarkMode,
        ),
      ),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        // Add Firebase Analytics observer with null check
        if (Firebase.apps.isNotEmpty)
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
    );
  }
}

// Global error handling for async operations
class AsyncErrorHandler {
  static Future<T?> handle<T>(Future<T> future, {String? operation}) async {
    try {
      return await future;
    } catch (e, stackTrace) {
      print('AsyncErrorHandler caught error: $e');
      try {
        await FirebaseService.recordError(
          e,
          stackTrace,
          reason: operation ?? 'Async operation failed',
        );
      } catch (firebaseError) {
        print('Failed to record error to Firebase: $firebaseError');
      }
      return null;
    }
  }
}
