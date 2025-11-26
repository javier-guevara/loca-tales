import '../models/location.dart';
import '../models/route_info.dart';
import '../models/place.dart';

abstract class IMapRepository {
  Future<RouteInfo> calculateRoute({
    required Location origin,
    required Location destination,
    required TransportMode transportMode,
  });

  Future<List<Location>> geocodeAddress(String address);

  Future<String> reverseGeocode(Location location);

  Future<List<Place>> searchNearbyPlaces({
    required Location location,
    required double radiusInKm,
    PlaceCategory? category,
  });
}


