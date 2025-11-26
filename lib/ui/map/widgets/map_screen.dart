import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../../domain/models/travel_plan.dart';
import '../../../domain/models/place.dart';
import '../view_model/map_view_model.dart';
import 'map_controls.dart';
import 'route_overlay.dart';
import 'bottom_sheet_place_info.dart';
import 'directions_panel.dart';

class MapScreen extends ConsumerStatefulWidget {
  final TravelPlan? travelPlan;
  final Place? focusedPlace;

  const MapScreen({
    super.key,
    this.travelPlan,
    this.focusedPlace,
  });

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapboxMap? _mapboxMap;
  CameraOptions? _initialCamera;

  @override
  void initState() {
    super.initState();
    
    // Calculate initial camera position
    // Priority: focusedPlace > first place in plan > default
    if (widget.focusedPlace != null) {
      _initialCamera = CameraOptions(
        center: Point(
          coordinates: Position(
            widget.focusedPlace!.location.longitude,
            widget.focusedPlace!.location.latitude,
          ),
        ),
        zoom: 15.0, // Closer zoom for focused place
      );
    } else if (widget.travelPlan != null && widget.travelPlan!.places.isNotEmpty) {
      final firstPlace = widget.travelPlan!.places.first;
      _initialCamera = CameraOptions(
        center: Point(
          coordinates: Position(
            firstPlace.location.longitude,
            firstPlace.location.latitude,
          ),
        ),
        zoom: 13.0,
      );
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(mapViewModelProvider.notifier);
      
      if (widget.travelPlan != null) {
        viewModel.displayTravelPlan(widget.travelPlan!);
      }
      
      // Focus on specific place if provided
      if (widget.focusedPlace != null) {
        Future.delayed(const Duration(milliseconds: 800), () {
          viewModel.focusOnPlace(widget.focusedPlace!, zoom: 17.0);
        });
      }
    });
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    final viewModel = ref.read(mapViewModelProvider.notifier);
    viewModel.initializeMap(mapboxMap);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapViewModelProvider);
    final viewModel = ref.read(mapViewModelProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map Widget
          MapWidget(
            key: const ValueKey('mapWidget'),
            cameraOptions: _initialCamera ?? CameraOptions(
              center: Point(
                coordinates: Position(-74.006, 40.7128), // Default NYC (fallback)
              ),
              zoom: 13.0,
            ),
            styleUri: state.mapStyle,
            textureView: true,
            onMapCreated: _onMapCreated,
          ),
          // Route Overlay
          if (state.currentRoute != null)
            RouteOverlay(
              route: state.currentRoute!,
              onClose: () => viewModel.clearRoute(),
              onChangeMode: (mode) => viewModel.changeTransportMode(mode),
            ),
          // Map Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            right: 16,
            child: MapControls(
              onZoomIn: () async {
                if (_mapboxMap != null) {
                  try {
                    final currentZoom = await _mapboxMap!.getCameraState();
                    await _mapboxMap!.setCamera(
                      CameraOptions(
                        zoom: (currentZoom.zoom ?? 13.0) + 1,
                      ),
                    );
                  } catch (e) {
                    // Handle error
                  }
                }
              },
              onZoomOut: () async {
                if (_mapboxMap != null) {
                  try {
                    final currentZoom = await _mapboxMap!.getCameraState();
                    await _mapboxMap!.setCamera(
                      CameraOptions(
                        zoom: (currentZoom.zoom ?? 13.0) - 1,
                      ),
                    );
                  } catch (e) {
                    // Handle error
                  }
                }
              },
              onCenterUser: () => viewModel.getUserLocation(),
              onChangeTransportMode: (mode) =>
                  viewModel.changeTransportMode(mode),
              currentTransportMode: state.transportMode,
              onToggleTraffic: () => viewModel.toggleTraffic(),
              showTraffic: state.showTraffic,
            ),
          ),
          // Bottom Sheet for Place Info (only show if no route)
          if (state.selectedPlace != null && state.currentRoute == null)
            BottomSheetPlaceInfo(
              place: state.selectedPlace!,
              onClose: () {
                print('[MapScreen] Closing place info sheet');
                viewModel.clearSelectedPlace();
              },
              onGetDirections: () async {
                print('🗺️ [MapScreen] onGetDirections button clicked');
                final currentState = ref.read(mapViewModelProvider);
                print('[MapScreen] Selected place: ${currentState.selectedPlace?.name}');
                print('[MapScreen] User location: ${currentState.userLocation}');
                
                if (currentState.selectedPlace != null) {
                  print('[MapScreen] Calling getDirectionsToPlace...');
                  await viewModel.getDirectionsToPlace(currentState.selectedPlace!);
                } else {
                  print('[MapScreen] ❌ No selected place');
                }
              },
            ),
          // Directions Panel (show when route is calculated)
          if (state.currentRoute != null && state.selectedPlace != null)
            DirectionsPanel(
              route: state.currentRoute!,
              destination: state.selectedPlace!,
              onClose: () {
                viewModel.clearRoute();
              },
              onChangeMode: (mode) async {
                await viewModel.changeTransportMode(mode);
                // Recalculate route with new mode
                if (state.selectedPlace != null) {
                  await viewModel.getDirectionsToPlace(state.selectedPlace!);
                }
              },
            ),
          // Error Banner
          if (state.errorMessage != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        viewModel.clearError();
                      },
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await viewModel.getUserLocation();
        },
        tooltip: 'Mi ubicación',
        child: state.isLoadingLocation
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.my_location),
      ),
    );
  }
}
