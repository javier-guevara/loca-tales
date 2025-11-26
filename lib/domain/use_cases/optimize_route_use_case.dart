import '../models/place.dart';
import '../models/location.dart';
import '../models/route_info.dart';
import '../repositories/i_map_repository.dart';

class OptimizeRouteUseCase {
  final IMapRepository _repository;

  OptimizeRouteUseCase(this._repository);

  Future<({List<Place> optimizedPlaces, List<RouteInfo> routes})> call({
    required List<Place> places,
    required Location startLocation,
    required TransportMode transportMode,
  }) async {
    if (places.isEmpty) {
      throw ArgumentError('La lista de lugares no puede estar vacía');
    }

    if (places.length == 1) {
      return (
        optimizedPlaces: places,
        routes: <RouteInfo>[],
      );
    }

    // Simple nearest neighbor algorithm
    final optimizedPlaces = <Place>[];
    final routes = <RouteInfo>[];
    final unvisited = List<Place>.from(places);
    Location currentLocation = startLocation;

    while (unvisited.isNotEmpty) {
      // Find nearest unvisited place
      Place? nearest;
      double minDistance = double.infinity;

      for (final place in unvisited) {
        final route = await _repository.calculateRoute(
          origin: currentLocation,
          destination: place.location,
          transportMode: transportMode,
        );

        if (route.distance < minDistance) {
          minDistance = route.distance;
          nearest = place;
        }
      }

      if (nearest != null) {
        optimizedPlaces.add(nearest);
        unvisited.remove(nearest);

        // Calculate route to nearest place
        final route = await _repository.calculateRoute(
          origin: currentLocation,
          destination: nearest.location,
          transportMode: transportMode,
        );
        routes.add(route);

        currentLocation = nearest.location;
      }
    }

    return (
      optimizedPlaces: optimizedPlaces,
      routes: routes,
    );
  }
}

