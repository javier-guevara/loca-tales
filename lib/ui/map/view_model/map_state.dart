import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../domain/models/place.dart';
import '../../../domain/models/route_info.dart';
import '../../../domain/models/location.dart';

part 'map_state.freezed.dart';

@freezed
class MapState with _$MapState {
  const factory MapState({
    CameraOptions? cameraPosition,
    @Default([]) List<Place> places,
    @Default([]) List<PointAnnotation> markers,
    RouteInfo? currentRoute,
    Place? selectedPlace,
    @Default(false) bool isCalculatingRoute,
    @Default(TransportMode.walking) TransportMode transportMode,
    Location? userLocation,
    PointAnnotation? userLocationMarker,
    @Default([]) List<Place> nearbyPlaces,
    @Default([]) List<PointAnnotation> nearbyMarkers,
    @Default(false) bool showNearbyPlaces,
    @Default(false) bool isLoadingLocation,
    String? errorMessage,
    @Default(false) bool showTraffic,
    @Default('mapbox://styles/mapbox/streets-v12') String mapStyle,
  }) = _MapState;
}


