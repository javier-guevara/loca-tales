import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;
import '../../../domain/models/location.dart';

class LocationService {
  /// Check and request location permissions
  Future<bool> checkPermissions() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log(
          'Location services are disabled',
          name: 'LocationService',
          level: 900,
        );
        return false;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          developer.log(
            'Location permissions are denied',
            name: 'LocationService',
            level: 900,
          );
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        developer.log(
          'Location permissions are permanently denied',
          name: 'LocationService',
          level: 900,
        );
        return false;
      }

      developer.log(
        'Location permissions granted',
        name: 'LocationService',
      );
      return true;
    } catch (e) {
      developer.log(
        'Error checking permissions',
        name: 'LocationService',
        error: e,
      );
      return false;
    }
  }

  /// Get current user location
  Future<Location?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        throw Exception('Permisos de ubicación denegados');
      }

      developer.log(
        'Getting current location...',
        name: 'LocationService',
      );

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      developer.log(
        'Location obtained: ${position.latitude}, ${position.longitude}',
        name: 'LocationService',
      );

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      developer.log(
        'Error getting location',
        name: 'LocationService',
        error: e,
      );
      return null;
    }
  }

  /// Watch location changes (stream)
  Stream<Location> watchLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).map((position) {
      developer.log(
        'Location updated: ${position.latitude}, ${position.longitude}',
        name: 'LocationService',
      );
      
      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    });
  }

  /// Calculate distance between two locations in meters
  double calculateDistance(Location from, Location to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Format distance for display
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }
}
