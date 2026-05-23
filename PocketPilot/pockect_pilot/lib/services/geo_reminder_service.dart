import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pockect_pilot/utils/db_helper.dart';
import 'package:pockect_pilot/utils/notification_helper.dart';

class GeoReminderService {
  static Timer? _trackingTimer;
  static bool isTracking = false;

  // Dwell state tracking
  static String? _currentPlaceName;
  static DateTime? _entryTime;
  static bool _notifiedForCurrentPlace = false;

  /// Check settings and start tracking if enabled
  static Future<void> initTracking() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('geo_reminders_enabled') ?? false;
    if (enabled) {
      startTracking();
    }
  }

  /// Start periodic GPS tracking
  static Future<void> startTracking() async {
    if (isTracking) return;
    
    // Request initial permissions gracefully
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("GPS Permission denied");
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print("GPS Permission permanently denied");
      return;
    }

    isTracking = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('geo_reminders_enabled', true);

    // Run check immediately
    _performLocationCheck();

    // Run periodically (every 2 minutes as per optimization requirements, or every 5 seconds in demo mode for instant feedback)
    final demoMode = prefs.getBool('geo_demo_mode') ?? false;
    final interval = demoMode ? const Duration(seconds: 5) : const Duration(minutes: 2);

    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(interval, (timer) {
      _performLocationCheck();
    });
  }

  /// Stop periodic GPS tracking
  static Future<void> stopTracking() async {
    isTracking = false;
    _trackingTimer?.cancel();
    _trackingTimer = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('geo_reminders_enabled', false);

    // Reset current dwell state
    _currentPlaceName = null;
    _entryTime = null;
    _notifiedForCurrentPlace = false;
  }

  /// Perform a single location check and proximity assessment
  static Future<void> _performLocationCheck() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('google_places_api_key') ?? '';
      
      List<Map<String, dynamic>> places = [];

      if (apiKey.isNotEmpty) {
        // If Places API key is set, we could attempt http request
        // For security and offline capability, fallback to mock is always supported
        places = await _fetchMockNearbyPlaces(position);
      } else {
        // Dynamic demo fallback generates 3 commercial shops around current location
        places = await _fetchMockNearbyPlaces(position);
      }

      bool foundPlace = false;

      for (var place in places) {
        final double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          place['lat'] as double,
          place['lng'] as double,
        );

        // Within 100 meters represents "nearby"
        if (distance <= 100) {
          foundPlace = true;
          final String placeName = place['name'] as String;

          if (_currentPlaceName == placeName) {
            // Already dwelling at this place, check duration
            final duration = DateTime.now().difference(_entryTime!);
            final demoMode = prefs.getBool('geo_demo_mode') ?? false;
            final dwellThreshold = demoMode ? const Duration(seconds: 10) : const Duration(minutes: 10);

            if (duration >= dwellThreshold && !_notifiedForCurrentPlace) {
              _notifiedForCurrentPlace = true;
              
              // Log to local SQLite
              final logId = await DbHelper.insertDwell({
                'placeName': placeName,
                'latitude': position.latitude,
                'longitude': position.longitude,
                'entryTime': _entryTime!.toIso8601String(),
                'durationMinutes': duration.inMinutes > 0 ? duration.inMinutes : 1,
                'notified': 1,
              });

              // Dispatch local notification
              await NotificationHelper.showNotification(
                id: logId != -1 ? logId : 999,
                title: "Pocket Pilot Reminder 📍",
                body: "Did you spend money at $placeName? Log your expense now!",
              );
            }
          } else {
            // Entered new place
            _currentPlaceName = placeName;
            _entryTime = DateTime.now();
            _notifiedForCurrentPlace = false;
          }
          break; // Stop checking other places once we find a match
        }
      }

      if (!foundPlace) {
        // User is not near any commercial place, reset tracking
        _currentPlaceName = null;
        _entryTime = null;
        _notifiedForCurrentPlace = false;
      }
    } catch (e) {
      print("Geofencing location check error: $e");
    }
  }

  /// Generate mock commercial places dynamic to current position (Demo Stability)
  static Future<List<Map<String, dynamic>>> _fetchMockNearbyPlaces(Position pos) async {
    return [
      {
        'name': 'Starbucks Coffee',
        'lat': pos.latitude + 0.0002, // ~25 meters North
        'lng': pos.longitude + 0.0002,
      },
      {
        'name': 'Target Superstore',
        'lat': pos.latitude - 0.0003, // ~35 meters South
        'lng': pos.longitude + 0.0001,
      },
      {
        'name': 'McDonald\'s Fast Food',
        'lat': pos.latitude + 0.0001, // ~30 meters West
        'lng': pos.longitude - 0.0003,
      }
    ];
  }
}
