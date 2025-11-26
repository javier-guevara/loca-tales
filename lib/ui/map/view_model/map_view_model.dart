import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:developer' as developer;
import 'dart:math';
import '../../../domain/models/travel_plan.dart';
import '../../../domain/models/place.dart';
import '../../../domain/models/route_info.dart';
import '../../../domain/models/location.dart';
import '../../../domain/repositories/i_map_repository.dart';
import '../../../data/providers/providers.dart';
import '../../../data/services/location/location_service.dart';
import '../../../config/constants/app_constants.dart';
import 'map_state.dart';

part 'map_view_model.g.dart';

@riverpod
class MapViewModel extends _$MapViewModel {
  @override
  MapState build() {
    return const MapState();
  }

  MapboxMap? _mapboxMap;
  PointAnnotationManager? _annotationManager;
  PolylineAnnotationManager? _polylineManager;

  IMapRepository get _mapRepository => ref.read(mapRepositoryProvider);

  void initializeMap(MapboxMap map) {
    _mapboxMap = map;
    _createAnnotationManagers();
    _setupMapListeners();
  }

  Future<void> _createAnnotationManagers() async {
    if (_mapboxMap == null) return;

    try {
      final annotationApi = _mapboxMap!.annotations;
      _annotationManager = await annotationApi.createPointAnnotationManager();
      _polylineManager = await annotationApi.createPolylineAnnotationManager();
    } catch (e) {
      // Handle error - annotation managers may not be available
      print('Error creating annotation managers: $e');
    }
  }

  void _setupMapListeners() {
    // Listeners can be added here for map events
  }

  Future<void> displayTravelPlan(TravelPlan plan) async {
    if (_mapboxMap == null) return;

    final places = plan.places;
    if (places.isEmpty) return;

    // Update state with places
    state = state.copyWith(places: places);

        // Create markers if annotation manager is available
        if (_annotationManager != null) {
          try {
            // Clear existing markers
            await _annotationManager!.deleteAll();

            // Create markers for each place
            final markerOptions = <PointAnnotationOptions>[];
            for (final place in places) {
              markerOptions.add(PointAnnotationOptions(
                geometry: Point(
                  coordinates: Position(
                    place.location.longitude,
                    place.location.latitude,
                  ),
                ),
                textField: place.name,
                textOffset: [0.0, -2.0],
                iconSize: 1.2,
                iconColor: _getCategoryColor(place.category),
              ));
            }

        // Create annotations one by one
        // Note: The exact API may vary - adjust based on Mapbox version
        final annotations = <PointAnnotation>[];
        for (final option in markerOptions) {
          try {
            final created = await _annotationManager!.create(option);
            annotations.add(created);
          } catch (e) {
            print('Error creating marker: $e');
            // Continue with other markers
          }
        }
        state = state.copyWith(markers: annotations);
      } catch (e) {
        print('Error creating markers: $e');
        // Continue without markers
      }
    }

    // Calculate bounds and animate camera
    await _fitBounds(places);

    // Calculate routes if more than 1 place
    if (places.length > 1) {
      await calculateRouteForPlan(plan);
    }
  }


  int _getCategoryColor(PlaceCategory category) {
    // Return color value based on category
    switch (category) {
      case PlaceCategory.attraction:
        return 0xFF9C27B0; // Purple
      case PlaceCategory.restaurant:
        return 0xFFE91E63; // Pink
      case PlaceCategory.hotel:
        return 0xFF3F51B5; // Indigo
      case PlaceCategory.nature:
        return 0xFF4CAF50; // Green
      case PlaceCategory.culture:
        return 0xFFFF9800; // Orange
      case PlaceCategory.shopping:
        return 0xFF00BCD4; // Cyan
      case PlaceCategory.entertainment:
        return 0xFFF44336; // Red
      default:
        return 0xFF2196F3; // Blue
    }
  }

  Future<void> _fitBounds(List<Place> places) async {
    if (_mapboxMap == null || places.isEmpty) return;

    // Simplified bounds calculation
    // In production, use proper Mapbox API methods
    double minLat = places.first.location.latitude;
    double maxLat = places.first.location.latitude;
    double minLon = places.first.location.longitude;
    double maxLon = places.first.location.longitude;

    for (final place in places) {
      minLat = minLat < place.location.latitude ? minLat : place.location.latitude;
      maxLat = maxLat > place.location.latitude ? maxLat : place.location.latitude;
      minLon = minLon < place.location.longitude ? minLon : place.location.longitude;
      maxLon = maxLon > place.location.longitude ? maxLon : place.location.longitude;
    }

    // Center point
    final centerLat = (minLat + maxLat) / 2;
    final centerLon = (minLon + maxLon) / 2;

    // Simple camera update - adjust zoom based on bounds
    final latDiff = maxLat - minLat;
    final lonDiff = maxLon - minLon;
    final zoom = 13.0 - (latDiff + lonDiff) * 5; // Simplified zoom calculation

    final cameraOptions = CameraOptions(
      center: Point(
        coordinates: Position(centerLon, centerLat),
      ),
      zoom: zoom.clamp(10.0, 18.0),
    );

    // Use setCamera instead of flyTo if flyTo doesn't work
    await _mapboxMap!.setCamera(cameraOptions);
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

      // Combine routes (simplified - in production, merge polylines)
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

      if (combinedRoute != null) {
        await drawRouteOnMap(combinedRoute);
      }
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

      await drawRouteOnMap(route);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error al calcular ruta: ${e.toString()}',
        isCalculatingRoute: false,
      );
    }
  }

  Future<void> drawRouteOnMap(RouteInfo route) async {
    if (_polylineManager == null) return;

    // Clear existing polylines
    await _polylineManager!.deleteAll();

    // Decode polyline (simplified - in production use proper polyline decoder)
    final coordinates = _decodePolyline(route.polyline);

    if (coordinates.isEmpty) return;

    // Convert coordinates to Position objects
    final positionList = coordinates.map((pos) => Position(
      (pos['longitude'] as num?)?.toDouble() ?? 0.0,
      (pos['latitude'] as num?)?.toDouble() ?? 0.0,
    )).toList();

    final polylineOptions = PolylineAnnotationOptions(
      geometry: LineString(coordinates: positionList),
      lineColor: _getTransportModeColor(route.transportMode),
      lineWidth: AppConstants.routeLineWidth,
      lineJoin: LineJoin.ROUND,
    );

    // Create polyline - method may accept single or list
    try {
      await _polylineManager!.create(polylineOptions);
    } catch (e) {
      // Try alternative if single create doesn't work
      print('Error creating polyline: $e');
    }
  }

  List<Map<String, num>> _decodePolyline(String encoded) {
    // Simplified polyline decoder
    // In production, use a proper polyline package
    final parts = encoded.split(';');
    return parts
        .where((p) => p.isNotEmpty)
        .map((p) {
          final coords = p.split(',');
          if (coords.length == 2) {
            final lon = double.tryParse(coords[0]) ?? 0.0;
            final lat = double.tryParse(coords[1]) ?? 0.0;
            return <String, num>{'longitude': lon, 'latitude': lat};
          }
          return null;
        })
        .whereType<Map<String, num>>()
        .toList();
  }

  int _getTransportModeColor(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking:
        return 0xFF4CAF50; // Green
      case TransportMode.driving:
        return 0xFF2196F3; // Blue
      case TransportMode.cycling:
        return 0xFFFF9800; // Orange
      default:
        return 0xFF757575; // Grey
    }
  }

  Future<void> onMarkerTapped(Place place) async {
    state = state.copyWith(selectedPlace: place);
    await centerOnPlace(place);
  }

  Future<void> centerOnPlace(Place place, {double zoom = 15.0}) async {
    if (_mapboxMap == null) return;

    final cameraOptions = CameraOptions(
      center: Point(
        coordinates: Position(
          place.location.longitude,
          place.location.latitude,
        ),
      ),
      zoom: zoom,
    );

    await _mapboxMap!.setCamera(cameraOptions);
  }

  Future<void> changeTransportMode(TransportMode mode) async {
    state = state.copyWith(transportMode: mode);

    // Recalculate route if there's a current route
    if (state.currentRoute != null && state.places.length >= 2) {
      // Recalculate with new mode
      // This would need the original plan or places
    }
  }

  Future<void> clearRoute() async {
    print('[MapViewModel] Clearing route');
    if (_polylineManager != null) {
      await _polylineManager!.deleteAll();
    }
    state = state.copyWith(
      currentRoute: null,
      isCalculatingRoute: false,
    );
  }
  
  void clearError() {
    print('[MapViewModel] Clearing error message');
    state = MapState(
      cameraPosition: state.cameraPosition,
      places: state.places,
      markers: state.markers,
      currentRoute: state.currentRoute,
      selectedPlace: state.selectedPlace,
      isCalculatingRoute: state.isCalculatingRoute,
      transportMode: state.transportMode,
      userLocation: state.userLocation,
      userLocationMarker: state.userLocationMarker,
      nearbyPlaces: state.nearbyPlaces,
      nearbyMarkers: state.nearbyMarkers,
      showNearbyPlaces: state.showNearbyPlaces,
      isLoadingLocation: state.isLoadingLocation,
      errorMessage: null, // Clear error
      showTraffic: state.showTraffic,
      mapStyle: state.mapStyle,
    );
  }
  
  void clearSelectedPlace() {
    print('[MapViewModel] Clearing selected place');
    state = state.copyWith(selectedPlace: null);
  }

  // ========== GEOLOCALIZACIÓN ==========
  
  Future<void> getUserLocation() async {
    state = state.copyWith(isLoadingLocation: true);
    
    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation();
      
      if (location != null) {
        developer.log(
          'User location obtained: ${location.latitude}, ${location.longitude}',
          name: 'MapViewModel',
        );
        
        state = state.copyWith(
          userLocation: location,
          isLoadingLocation: false,
        );
        
        // Center on user location
        await _centerOnLocation(location, zoom: 15.0);
        
        // Add user location marker
        await _addUserLocationMarker(location);
      } else {
        state = state.copyWith(
          errorMessage: 'No se pudo obtener tu ubicación. Verifica los permisos.',
          isLoadingLocation: false,
        );
      }
    } catch (e) {
      developer.log(
        'Error getting user location',
        name: 'MapViewModel',
        error: e,
      );
      
      state = state.copyWith(
        errorMessage: 'Error al obtener ubicación: ${e.toString()}',
        isLoadingLocation: false,
      );
    }
  }
  
  Future<void> _centerOnLocation(Location location, {double zoom = 15.0}) async {
    if (_mapboxMap == null) return;

    final cameraOptions = CameraOptions(
      center: Point(
        coordinates: Position(
          location.longitude,
          location.latitude,
        ),
      ),
      zoom: zoom,
    );

    await _mapboxMap!.setCamera(cameraOptions);
  }
  
  Future<void> _addUserLocationMarker(Location location) async {
    if (_annotationManager == null) return;
    
    try {
      // Remove old user marker if exists
      if (state.userLocationMarker != null) {
        await _annotationManager!.delete(state.userLocationMarker!);
      }
      
      // Create user marker
      final userMarker = PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(location.longitude, location.latitude),
        ),
        iconSize: 1.5,
        iconColor: 0xFF2196F3, // Blue
      );
      
      final created = await _annotationManager!.create(userMarker);
      state = state.copyWith(userLocationMarker: created);
      
      developer.log(
        'User location marker added',
        name: 'MapViewModel',
      );
    } catch (e) {
      developer.log(
        'Error adding user marker',
        name: 'MapViewModel',
        error: e,
      );
    }
  }

  void toggleTraffic() {
    state = state.copyWith(showTraffic: !state.showTraffic);
    // Update map style to show/hide traffic
  }

  Future<void> changeMapStyle(String styleUri) async {
    if (_mapboxMap == null) return;

    state = state.copyWith(mapStyle: styleUri);
    // Load style - method may vary by Mapbox version
    // await _mapboxMap!.loadStyleURI(styleUri);
  }
  
  // ========== FOCUS MEJORADO ==========
  
  Future<void> focusOnPlace(Place place, {double zoom = 17.0}) async {
    if (_mapboxMap == null) return;

    developer.log(
      'Focusing on place: ${place.name}',
      name: 'MapViewModel',
    );

    state = state.copyWith(selectedPlace: place);

    final cameraOptions = CameraOptions(
      center: Point(
        coordinates: Position(
          place.location.longitude,
          place.location.latitude,
        ),
      ),
      zoom: zoom,
      pitch: 45.0, // Angled view for better perspective
      bearing: 0.0,
    );

    // Try to use flyTo for smooth animation, fallback to setCamera
    try {
      await _mapboxMap!.setCamera(cameraOptions);
    } catch (e) {
      developer.log(
        'Error focusing on place',
        name: 'MapViewModel',
        error: e,
      );
    }
  }
  
  // ========== DIRECCIONES DESDE UBICACIÓN ACTUAL ==========
  
  Future<void> getDirectionsToPlace(Place destination) async {
    if (state.userLocation == null) {
      await getUserLocation();
      if (state.userLocation == null) {
        state = state.copyWith(
          errorMessage: 'Primero necesitamos tu ubicación',
        );
        return;
      }
    }

    // Validate distance (Mapbox has a ~500km limit for walking/driving routes)
    final distance = _calculateDistance(
      state.userLocation!.latitude,
      state.userLocation!.longitude,
      destination.location.latitude,
      destination.location.longitude,
    );
    
    print('[MapViewModel] Distance to destination: ${distance.toStringAsFixed(2)} km');
    
    if (distance > 500) {
      state = state.copyWith(
        errorMessage: 'El destino está demasiado lejos (${distance.toStringAsFixed(0)} km). '
            'Las rutas están limitadas a 500 km de distancia.',
        isCalculatingRoute: false,
      );
      return;
    }

    state = state.copyWith(isCalculatingRoute: true);

    try {
      print('[MapViewModel] Calculating route to: ${destination.name}');
      
      final route = await _mapRepository.calculateRoute(
        origin: state.userLocation!,
        destination: destination.location,
        transportMode: state.transportMode,
      );

      state = state.copyWith(
        currentRoute: route,
        selectedPlace: destination,
        isCalculatingRoute: false,
      );

      await drawRouteOnMap(route);
      
      // Fit route in view
      await _fitRouteInView(state.userLocation!, destination.location);
    } catch (e) {
      print('[MapViewModel] ❌ Error calculating route: $e');
      
      state = state.copyWith(
        errorMessage: 'Error al calcular ruta: ${e.toString()}',
        isCalculatingRoute: false,
      );
    }
  }
  
  Future<void> _fitRouteInView(Location origin, Location destination) async {
    if (_mapboxMap == null) return;

    final minLat = origin.latitude < destination.latitude 
        ? origin.latitude : destination.latitude;
    final maxLat = origin.latitude > destination.latitude 
        ? origin.latitude : destination.latitude;
    final minLon = origin.longitude < destination.longitude 
        ? origin.longitude : destination.longitude;
    final maxLon = origin.longitude > destination.longitude 
        ? origin.longitude : destination.longitude;

    final centerLat = (minLat + maxLat) / 2;
    final centerLon = (minLon + maxLon) / 2;

    // Calculate appropriate zoom
    final latDiff = maxLat - minLat;
    final lonDiff = maxLon - minLon;
    final zoom = 14.0 - ((latDiff + lonDiff) * 10);

    await _mapboxMap!.setCamera(
      CameraOptions(
        center: Point(coordinates: Position(centerLon, centerLat)),
        zoom: zoom.clamp(10.0, 16.0),
      ),
    );
  }
  
  // ========== PUNTOS DE REFERENCIA CERCANOS ==========
  
  Future<void> showNearbyPlaces(String category) async {
    final centerLocation = state.selectedPlace?.location ?? state.userLocation;
    
    if (centerLocation == null) {
      state = state.copyWith(
        errorMessage: 'Selecciona un lugar o activa tu ubicación',
      );
      return;
    }

    try {
      developer.log(
        'Searching nearby places: $category',
        name: 'MapViewModel',
      );
      
      // This would call mapbox places API
      // For now, placeholder
      state = state.copyWith(
        showNearbyPlaces: true,
        nearbyPlaces: [],
      );
    } catch (e) {
      developer.log(
        'Error searching nearby places',
        name: 'MapViewModel',
        error: e,
      );
      
      state = state.copyWith(
        errorMessage: 'Error al buscar lugares cercanos: ${e.toString()}',
      );
    }
  }
  
  void clearNearbyPlaces() {
    state = state.copyWith(
      nearbyPlaces: [],
      showNearbyPlaces: false,
    );
  }
  
  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371; // km
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}


