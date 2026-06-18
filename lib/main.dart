import 'dart:ui';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/home.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'auth_wrapper.dart';

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// ============================================================================
// TRAVEL AGENCY APP - MAIN ENTRY POINT
// ============================================================================
//
// PROJECT COMPLETION STATUS: Items 1-5 COMPLETED ✓
//
// COMPLETED FEATURES:
// ✓ Item 1: SRS - Functional Requirements, Diagrams, Formatting
// ✓ Item 2: User Login & Registration (Design UI - Flutter)
// ✓ Item 3: Authentication System (Implement Login & Registration with Firebase)
// ✓ Item 4: Travel Package Catalog (Explore Screen)
//    - Search functionality for destinations
//    - Category filtering (8 categories)
//    - 12 sample destinations with images, ratings, prices
//    - Save/favorite functionality with Firebase
//    - Navigation to detail screens
// ✓ Item 5: Package Details Page
//    - place_detail_screen.dart - Generic place details
//    - hotel_detail_screen.dart - Hotels/Restaurants/Cafes
//    - tourist_spots.dart - Tourist attractions
//    - Full-screen images, ratings, reviews, save functionality
//
// BONUS FEATURE:
// ✓ Featured Destinations on Home Screen
//    - Paris, France (4.8★) - Eiffel Tower
//    - Tokyo, Japan (4.9★) - Neon city streets
//    - Dubai, UAE (4.7★) - Modern skyline
//    - Beautiful gradient overlays, rating badges, location pins
//
// APP STRUCTURE:
// Splash → Onboarding → Login/Register → Home (Featured Destinations)
//                                          ↓
//                                    Explore Screen (Catalog)
//                                          ↓
//                                    Detail Screens (Hotels/Restaurants/Attractions)
//
// FIREBASE COLLECTIONS:
// - users: User profiles with savedPlaces array
// - places: All travel destinations/packages
//
// DESIGN SYSTEM:
// - Theme: Dark (#061024, #0A1628, #1A2642)
// - Accents: Blue (#2196F3), Amber (ratings)
// - Typography: Bold headers, clean body text
// - Spacing: 20px padding, 20px border radius
//
// FILES STRUCTURE:
// lib/
//   models/
//     place.dart - Place data model
//   screens/
//     home.dart - Home with Featured Destinations
//     explore_screen.dart - Travel Package Catalog (Item 4)
//     place_detail_screen.dart - Place details (Item 5)
//     hotel_detail_screen.dart - Hotel/Restaurant details (Item 5)
//     tourist_spots.dart - Tourist attraction details (Item 5)
//   services/
//     firestore_service.dart - Firebase operations
//     auth_service.dart - Authentication
//
// READY FOR PRESENTATION: YES ✓
// APP STATUS: Fully Functional
// ============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PlatformDispatcher.instance.onError = (error, stack) {
    final errorString = error.toString();
    if (errorString.contains('ext.flutter.activeDevToolsServerAddress') ||
        errorString.contains('ext.flutter.connectedVmServiceUri')) {
      return true;
    }
    return false;
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    final errorString = details.exception.toString();
    if (errorString.contains('ext.flutter.activeDevToolsServerAddress') ||
        errorString.contains('ext.flutter.connectedVmServiceUri')) {
      return;
    }

    FlutterError.presentError(details);
    if (kDebugMode) {
      print('FLUTTER ERROR: ${details.exception}');
    }
  };

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print('FIREBASE INITIALIZATION ERROR: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Agency',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        datePickerTheme: const DatePickerThemeData(
          backgroundColor: Color(0xFF1A2642),
          headerBackgroundColor: Color(0xFF0A1628),
          headerForegroundColor: Colors.white,
          dayForegroundColor: WidgetStatePropertyAll(Colors.white),
          yearForegroundColor: WidgetStatePropertyAll(Colors.white),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      },
    );
  }
}
