// Simplified version - will be updated when Mapbox API is properly configured
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/models/travel_plan.dart';
import '../../../domain/models/place.dart';
import '../../../domain/models/location.dart';
import '../../../domain/models/route_info.dart';
import '../../../domain/repositories/i_map_repository.dart';
import '../../../data/providers/providers.dart';
import 'map_state.dart';

part 'map_view_model_simplified.g.dart';

@riverpod
class MapViewModel extends _$MapViewModel {
  @override
  MapState build() {
    return const MapState();
  }

  IMapRepository get _mapRepository => ref.read(mapRepositoryProvider);

  void initializeMap(dynamic mapboxMap) {
    // Initialize map - simplified for now
  }

  Future<void> displayTravelPlan(TravelPlan plan) async {
    final places = plan.places;
    if (places.isEmpty) return;

    state = state.copyWith(places: places);

    // Calculate routes if more than 1 place
    if (places.length > 1) {
      await calculateRouteForPlan(plan);
    }
  }

  Future<void> calculateRouteForPlan(TravelPlan plan) async {
    if (plan.places.length < 2) return;

    state = state.copyWith(isCalculatingRoute: true);

    try {
      final places = plan.places;
      final routes = <RouteInfo>[];

      // Calculate route between consecutive places
      for (int i = 0; i < places.length - 1; i++) {
        final route = await _mapRepository.calculateRoute(
          origin: places[i].location,
          destination: places[i + 1].location,
          transportMode: state.transportMode,
        );
        routes.add(route);
      }

      // Combine routes
      final combinedRoute = routes.isNotEmpty
          ? RouteInfo(
              distance: routes.fold(0.0, (sum, r) => sum + r.distance),
              duration: routes.fold(
                Duration.zero,
                (sum, r) => sum + r.duration,
              ),
              transportMode: state.transportMode,
              polyline: routes.map((r) => r.polyline).join(';'),
            )
          : null;

      state = state.copyWith(
        currentRoute: combinedRoute,
        isCalculatingRoute: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error al calcular ruta: ${e.toString()}',
        isCalculatingRoute: false,
      );
    }
  }

  Future<void> calculateRouteBetweenPlaces(
    Place origin,
    Place destination,
  ) async {
    state = state.copyWith(isCalculatingRoute: true);

    try {
      final route = await _mapRepository.calculateRoute(
        origin: origin.location,
        destination: destination.location,
        transportMode: state.transportMode,
      );

      state = state.copyWith(
        currentRoute: route,
        isCalculatingRoute: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error al calcular ruta: ${e.toString()}',
        isCalculatingRoute: false,
      );
    }
  }

  Future<void> onMarkerTapped(Place place) async {
    state = state.copyWith(selectedPlace: place);
  }

  Future<void> centerOnPlace(Place place, {double zoom = 15.0}) async {
    // Center camera on place - simplified
  }

  Future<void> changeTransportMode(TransportMode mode) async {
    state = state.copyWith(transportMode: mode);
  }

  Future<void> clearRoute() async {
    state = state.copyWith(currentRoute: null);
  }

  Future<void> getUserLocation() async {
    // Get user location - requires geolocator
  }

  void toggleTraffic() {
    state = state.copyWith(showTraffic: !state.showTraffic);
  }

  Future<void> changeMapStyle(String styleUri) async {
    state = state.copyWith(mapStyle: styleUri);
  }
}


