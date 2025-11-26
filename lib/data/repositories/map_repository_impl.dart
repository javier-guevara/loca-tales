import 'dart:developer' as developer;
import '../../domain/repositories/i_map_repository.dart';
import '../../domain/models/location.dart';
import '../../domain/models/route_info.dart';
import '../../domain/models/place.dart';
import '../services/mapbox/mapbox_directions_service.dart';
import '../services/mapbox/mapbox_geocoding_service.dart';
import '../services/mapbox/mapbox_places_service.dart';
import '../models/mappers/route_mapper.dart';
import '../models/mappers/place_mapper.dart';

class MapRepositoryImpl implements IMapRepository {
  final MapboxDirectionsService _directionsService;
  final MapboxGeocodingService _geocodingService;
  final MapboxPlacesService _placesService;

  MapRepositoryImpl({
    required MapboxDirectionsService directionsService,
    required MapboxGeocodingService geocodingService,
    required MapboxPlacesService placesService,
  })  : _directionsService = directionsService,
        _geocodingService = geocodingService,
        _placesService = placesService;

  @override
  Future<RouteInfo> calculateRoute({
    required Location origin,
    required Location destination,
    required TransportMode transportMode,
  }) async {
    print('[MapRepositoryImpl] 📍 calculateRoute called');
    print('[MapRepositoryImpl] Origin: lat=${origin.latitude}, lon=${origin.longitude}');
    print('[MapRepositoryImpl] Destination: lat=${destination.latitude}, lon=${destination.longitude}');
    print('[MapRepositoryImpl] Transport mode: $transportMode');
    
    if (origin.latitude == destination.latitude &&
        origin.longitude == destination.longitude) {
      throw ArgumentError('El origen y destino no pueden ser iguales');
    }

    final profile = _transportModeToProfile(transportMode);
    print('[MapRepositoryImpl] Profile: $profile');

    try {
      final response = await _directionsService.getDirections(
        originLat: origin.latitude,
        originLon: origin.longitude,
        destLat: destination.latitude,
        destLon: destination.longitude,
        profile: profile,
      );

      print('[MapRepositoryImpl] ✅ Route calculated successfully');
      
      return RouteMapper.fromMapboxDirections(
        response: response,
        transportMode: transportMode,
      );
    } catch (e) {
      print('[MapRepositoryImpl] ❌ Error in calculateRoute: $e');
      
      if (e.toString().contains('no encontrada')) {
        throw Exception('Ruta no encontrada entre los puntos seleccionados');
      }
      throw Exception('Error al calcular ruta: ${e.toString()}');
    }
  }

  @override
  Future<List<Location>> geocodeAddress(String address) async {
    if (address.trim().isEmpty) {
      throw ArgumentError('La dirección no puede estar vacía');
    }

    try {
      final response = await _geocodingService.geocode(address);
      final features = response.features ?? [];

      return features.map((feature) {
        final center = feature.center;
        if (center != null && center.length >= 2) {
          return Location(
            latitude: center[1],
            longitude: center[0],
            address: feature.placeName,
          );
        }
        return Location(latitude: 0.0, longitude: 0.0);
      }).where((loc) => loc.isValid).toList();
    } catch (e) {
      throw Exception('Error al geocodificar dirección: ${e.toString()}');
    }
  }

  @override
  Future<String> reverseGeocode(Location location) async {
    try {
      return await _geocodingService.reverseGeocode(
        location.latitude,
        location.longitude,
      );
    } catch (e) {
      throw Exception('Error en geocodificación inversa: ${e.toString()}');
    }
  }

  @override
  Future<List<Place>> searchNearbyPlaces({
    required Location location,
    required double radiusInKm,
    PlaceCategory? category,
  }) async {
    try {
      // Convert radius from km to meters for Mapbox
      final radiusInMeters = (radiusInKm * 1000).toInt();

      // Search places (simplified - Mapbox Search API usage)
      final results = await _placesService.searchPlaces(
        query: '', // Empty query for nearby search
        proximityLat: location.latitude,
        proximityLon: location.longitude,
      );

      // Convert to Place domain models
      final places = results
          .map((feature) => PlaceMapper.fromMapboxFeature(feature))
          .where((place) {
            // Filter by category if specified
            if (category != null && place.category != category) {
              return false;
            }
            return true;
          })
          .toList();

      return places;
    } catch (e) {
      throw Exception('Error al buscar lugares cercanos: ${e.toString()}');
    }
  }

  String _transportModeToProfile(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking:
        return 'walking';
      case TransportMode.driving:
        return 'driving';
      case TransportMode.cycling:
        return 'cycling';
      case TransportMode.transit:
        return 'driving'; // Mapbox doesn't have transit profile in Directions API v5
    }
  }
}


