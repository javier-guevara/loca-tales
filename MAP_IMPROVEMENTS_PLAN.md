# 🗺️ Plan de Mejoras para el Mapa - Travel AI Planner

## 📋 Objetivos

1. **Mayor zoom/focus al seleccionar un lugar**
2. **Planear ruta desde ubicación actual**
3. **Agregar puntos de referencia cercanos**

---

## 🎯 Funcionalidad 1: Mayor Focus al Lugar

### Descripción
Cuando el usuario selecciona un lugar (desde la lista de detalles o desde el mapa), hacer un zoom más cercano y centrado en ese lugar específico.

### Implementación Sugerida

#### 1.1 Modificar `MapViewModel`
```dart
// En map_view_model.dart

Future<void> focusOnPlace(Place place, {double zoom = 16.0}) async {
  if (_mapboxMap == null) return;

  state = state.copyWith(selectedPlace: place);

  // Animación suave hacia el lugar
  final cameraOptions = CameraOptions(
    center: Point(
      coordinates: Position(
        place.location.longitude,
        place.location.latitude,
      ),
    ),
    zoom: zoom,
    pitch: 45.0, // Vista en ángulo para mejor perspectiva
    bearing: 0.0,
  );

  // Usar flyTo para animación suave (si está disponible)
  try {
    await _mapboxMap!.flyTo(
      cameraOptions,
      MapAnimationOptions(duration: 1500), // 1.5 segundos
    );
  } catch (e) {
    // Fallback a setCamera si flyTo no está disponible
    await _mapboxMap!.setCamera(cameraOptions);
  }
}
```

#### 1.2 Actualizar navegación desde PlanDetailScreen
```dart
// En plan_detail_screen.dart

PlaceCard(
  place: place,
  onTap: () {
    // Navegar al mapa con el lugar seleccionado
    context.push(
      RouteNames.map,
      extra: {
        'plan': plan,
        'focusedPlace': place, // Pasar el lugar específico
      },
    );
  },
  onRemove: () => viewModel.removePlaceFromPlan(place.id),
)
```

#### 1.3 Modificar MapScreen para recibir lugar específico
```dart
// En map_screen.dart

class MapScreen extends ConsumerStatefulWidget {
  final TravelPlan? travelPlan;
  final Place? focusedPlace; // Nuevo parámetro

  const MapScreen({
    super.key,
    this.travelPlan,
    this.focusedPlace,
  });
}

@override
void initState() {
  super.initState();
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final viewModel = ref.read(mapViewModelProvider.notifier);
    
    if (widget.travelPlan != null) {
      viewModel.displayTravelPlan(widget.travelPlan!);
      
      // Si hay un lugar específico, hacer focus en él
      if (widget.focusedPlace != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          viewModel.focusOnPlace(widget.focusedPlace!, zoom: 17.0);
        });
      }
    }
  });
}
```

---

## 🧭 Funcionalidad 2: Planear Ruta desde Ubicación Actual

### Descripción
Permitir al usuario obtener direcciones desde su ubicación actual hasta un lugar seleccionado.

### Implementación Sugerida

#### 2.1 Agregar Geolocalización

**Dependencias necesarias:**
```yaml
# pubspec.yaml
dependencies:
  geolocator: ^11.0.0
  permission_handler: ^11.0.0
```

**Configuración de permisos:**

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para mostrarte direcciones a los lugares</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Necesitamos tu ubicación para mostrarte direcciones a los lugares</string>
```

#### 2.2 Servicio de Geolocalización

```dart
// lib/data/services/location/location_service.dart

import 'package:geolocator/geolocator.dart';
import '../../../domain/models/location.dart';

class LocationService {
  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Location?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        throw Exception('Permisos de ubicación denegados');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Stream<Location> watchLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Actualizar cada 10 metros
      ),
    ).map((position) => Location(
      latitude: position.latitude,
      longitude: position.longitude,
    ));
  }
}
```

#### 2.3 Actualizar MapViewModel

```dart
// En map_view_model.dart

Future<void> getUserLocation() async {
  try {
    final locationService = ref.read(locationServiceProvider);
    final location = await locationService.getCurrentLocation();
    
    if (location != null) {
      state = state.copyWith(userLocation: location);
      
      // Centrar en la ubicación del usuario
      await centerOnLocation(location, zoom: 15.0);
      
      // Agregar marcador de ubicación del usuario
      await _addUserLocationMarker(location);
    } else {
      state = state.copyWith(
        errorMessage: 'No se pudo obtener tu ubicación. Verifica los permisos.',
      );
    }
  } catch (e) {
    state = state.copyWith(
      errorMessage: 'Error al obtener ubicación: ${e.toString()}',
    );
  }
}

Future<void> _addUserLocationMarker(Location location) async {
  if (_annotationManager == null) return;
  
  try {
    // Crear marcador especial para el usuario
    final userMarker = PointAnnotationOptions(
      geometry: Point(
        coordinates: Position(location.longitude, location.latitude),
      ),
      iconImage: 'user-location-icon', // Icono personalizado
      iconSize: 1.5,
      iconColor: 0xFF2196F3, // Azul
    );
    
    final created = await _annotationManager!.create(userMarker);
    state = state.copyWith(userLocationMarker: created);
  } catch (e) {
    print('Error adding user marker: $e');
  }
}

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

  state = state.copyWith(isCalculatingRoute: true);

  try {
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
    
    // Ajustar la cámara para mostrar toda la ruta
    await _fitRouteInView(state.userLocation!, destination.location);
  } catch (e) {
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

  // Calcular zoom apropiado
  final latDiff = maxLat - minLat;
  final lonDiff = maxLon - minLon;
  final zoom = 14.0 - ((latDiff + lonDiff) * 10);

  await _mapboxMap!.setCamera(
    CameraOptions(
      center: Point(coordinates: Position(centerLon, centerLat)),
      zoom: zoom.clamp(10.0, 16.0),
      padding: MbxEdgeInsets(
        top: 100, bottom: 300, left: 50, right: 50,
      ),
    ),
  );
}
```

#### 2.4 UI para Direcciones

```dart
// lib/ui/map/widgets/directions_panel.dart

class DirectionsPanel extends StatelessWidget {
  final RouteInfo route;
  final Place destination;
  final VoidCallback onClose;
  final Function(TransportMode) onChangeMode;

  const DirectionsPanel({
    super.key,
    required this.route,
    required this.destination,
    required this.onClose,
    required this.onChangeMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Direcciones a',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              destination.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Route info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getTransportIcon(route.transportMode),
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDuration(route.duration),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                '${(route.distance / 1000).toStringAsFixed(1)} km',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Transport mode selector
                  Text(
                    'Modo de transporte',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _TransportModeChip(
                        icon: Icons.directions_walk,
                        label: 'Caminar',
                        mode: TransportMode.walking,
                        currentMode: route.transportMode,
                        onTap: () => onChangeMode(TransportMode.walking),
                      ),
                      const SizedBox(width: 8),
                      _TransportModeChip(
                        icon: Icons.directions_car,
                        label: 'Conducir',
                        mode: TransportMode.driving,
                        currentMode: route.transportMode,
                        onTap: () => onChangeMode(TransportMode.driving),
                      ),
                      const SizedBox(width: 8),
                      _TransportModeChip(
                        icon: Icons.directions_bike,
                        label: 'Bicicleta',
                        mode: TransportMode.cycling,
                        currentMode: route.transportMode,
                        onTap: () => onChangeMode(TransportMode.cycling),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Start navigation button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Abrir en app de mapas externa
                        _openInExternalMaps(destination);
                      },
                      icon: const Icon(Icons.navigation),
                      label: const Text('Iniciar Navegación'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransportIcon(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking:
        return Icons.directions_walk;
      case TransportMode.driving:
        return Icons.directions_car;
      case TransportMode.cycling:
        return Icons.directions_bike;
      default:
        return Icons.directions;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hours h $minutes min';
    }
    return '$minutes min';
  }

  Future<void> _openInExternalMaps(Place destination) async {
    // Usar url_launcher para abrir en Google Maps o Apple Maps
    final lat = destination.location.latitude;
    final lon = destination.location.longitude;
    final name = Uri.encodeComponent(destination.name);
    
    // iOS: Apple Maps
    // final url = 'maps://?q=$name&ll=$lat,$lon';
    
    // Android/iOS: Google Maps
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon';
    
    // Implementar con url_launcher
  }
}

class _TransportModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final TransportMode mode;
  final TransportMode currentMode;
  final VoidCallback onTap;

  const _TransportModeChip({
    required this.icon,
    required this.label,
    required this.mode,
    required this.currentMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = mode == currentMode;
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.onSurface,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 📍 Funcionalidad 3: Puntos de Referencia Cercanos

### Descripción
Mostrar puntos de interés cercanos (restaurantes, cafés, estaciones de metro, etc.) para ayudar al usuario a orientarse.

### Implementación Sugerida

#### 3.1 Servicio de Lugares Cercanos (Mapbox)

```dart
// En mapbox_places_service.dart - Agregar método

Future<List<Place>> getNearbyPlaces({
  required Location location,
  required String category, // 'restaurant', 'cafe', 'transit', etc.
  int limit = 10,
  double radiusMeters = 500,
}) async {
  try {
    final response = await _dio.get(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$category.json',
      queryParameters: {
        'proximity': '${location.longitude},${location.latitude}',
        'limit': limit,
        'access_token': Env.mapboxAccessToken,
        'types': 'poi', // Points of interest
      },
    );

    final features = response.data['features'] as List;
    return features
        .map((feature) => PlaceMapper.fromMapboxFeature(feature))
        .toList();
  } catch (e) {
    throw Exception('Error fetching nearby places: $e');
  }
}
```

#### 3.2 UI para Puntos de Referencia

```dart
// lib/ui/map/widgets/nearby_places_sheet.dart

class NearbyPlacesSheet extends StatelessWidget {
  final Location centerLocation;
  final Function(String category) onCategorySelected;

  const NearbyPlacesSheet({
    super.key,
    required this.centerLocation,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Puntos de Referencia Cercanos',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CategoryChip(
                icon: Icons.restaurant,
                label: 'Restaurantes',
                onTap: () => onCategorySelected('restaurant'),
              ),
              _CategoryChip(
                icon: Icons.local_cafe,
                label: 'Cafés',
                onTap: () => onCategorySelected('cafe'),
              ),
              _CategoryChip(
                icon: Icons.train,
                label: 'Metro/Tren',
                onTap: () => onCategorySelected('transit'),
              ),
              _CategoryChip(
                icon: Icons.local_gas_station,
                label: 'Gasolineras',
                onTap: () => onCategorySelected('fuel'),
              ),
              _CategoryChip(
                icon: Icons.local_hospital,
                label: 'Hospitales',
                onTap: () => onCategorySelected('hospital'),
              ),
              _CategoryChip(
                icon: Icons.local_pharmacy,
                label: 'Farmacias',
                onTap: () => onCategorySelected('pharmacy'),
              ),
              _CategoryChip(
                icon: Icons.local_atm,
                label: 'Cajeros',
                onTap: () => onCategorySelected('atm'),
              ),
              _CategoryChip(
                icon: Icons.local_parking,
                label: 'Estacionamiento',
                onTap: () => onCategorySelected('parking'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 3.3 Actualizar MapViewModel

```dart
Future<void> showNearbyPlaces(String category) async {
  if (state.selectedPlace == null && state.userLocation == null) {
    state = state.copyWith(
      errorMessage: 'Selecciona un lugar o activa tu ubicación',
    );
    return;
  }

  final centerLocation = state.selectedPlace?.location ?? state.userLocation!;

  try {
    final nearbyPlaces = await _mapRepository.getNearbyPlaces(
      location: centerLocation,
      category: category,
      limit: 15,
      radiusMeters: 1000, // 1 km
    );

    state = state.copyWith(nearbyPlaces: nearbyPlaces);

    // Agregar marcadores temporales para lugares cercanos
    await _addNearbyPlacesMarkers(nearbyPlaces);
  } catch (e) {
    state = state.copyWith(
      errorMessage: 'Error al buscar lugares cercanos: ${e.toString()}',
    );
  }
}

Future<void> _addNearbyPlacesMarkers(List<Place> places) async {
  if (_annotationManager == null) return;

  try {
    // Crear marcadores con estilo diferente (más pequeños, color diferente)
    for (final place in places) {
      final marker = PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            place.location.longitude,
            place.location.latitude,
          ),
        ),
        iconSize: 0.8,
        iconColor: 0xFF9E9E9E, // Gris para diferenciar
        textField: place.name,
        textSize: 10.0,
        textOffset: [0.0, -1.5],
      );
      
      await _annotationManager!.create(marker);
    }
  } catch (e) {
    print('Error adding nearby markers: $e');
  }
}

void clearNearbyPlaces() {
  state = state.copyWith(nearbyPlaces: []);
  // Limpiar marcadores de lugares cercanos
  // (necesitarías trackear estos marcadores por separado)
}
```

---

## 🎨 Mejoras Adicionales de UX

### 1. **Botón Flotante de Ubicación**
```dart
// En map_screen.dart

FloatingActionButton(
  onPressed: () async {
    final viewModel = ref.read(mapViewModelProvider.notifier);
    await viewModel.getUserLocation();
  },
  child: const Icon(Icons.my_location),
  tooltip: 'Mi ubicación',
)
```

### 2. **Indicador de Distancia**
Mostrar la distancia desde la ubicación actual a cada lugar en las cards.

### 3. **Modo Offline**
Cachear tiles del mapa para uso sin conexión usando `mapbox_maps_flutter` con cache.

### 4. **Compartir Ubicación**
Permitir compartir un lugar específico con coordenadas.

---

## 📦 Dependencias Adicionales Necesarias

```yaml
dependencies:
  geolocator: ^11.0.0
  permission_handler: ^11.0.0
  url_launcher: ^6.2.0  # Para abrir mapas externos
  share_plus: ^7.2.0    # Para compartir ubicaciones
```

---

## 🚀 Plan de Implementación Recomendado

### Fase 1: Focus Mejorado (1-2 horas)
1. ✅ Implementar `focusOnPlace` con animación
2. ✅ Actualizar navegación desde detalles
3. ✅ Probar zoom y pitch

### Fase 2: Geolocalización (2-3 horas)
1. ✅ Agregar dependencias y permisos
2. ✅ Crear `LocationService`
3. ✅ Integrar en `MapViewModel`
4. ✅ Agregar marcador de usuario
5. ✅ Probar en dispositivo real

### Fase 3: Direcciones (3-4 horas)
1. ✅ Implementar `getDirectionsToPlace`
2. ✅ Crear `DirectionsPanel` UI
3. ✅ Integrar selector de modo de transporte
4. ✅ Implementar apertura en app externa
5. ✅ Probar rutas

### Fase 4: Puntos de Referencia (2-3 horas)
1. ✅ Implementar `getNearbyPlaces` en servicio
2. ✅ Crear `NearbyPlacesSheet` UI
3. ✅ Agregar marcadores diferenciados
4. ✅ Implementar filtros por categoría
5. ✅ Probar con diferentes categorías

---

## 💡 Notas Importantes

1. **Permisos**: Siempre verificar permisos antes de acceder a ubicación
2. **Batería**: La geolocalización consume batería, usar con moderación
3. **Precisión**: En interiores la precisión puede ser baja
4. **Costos**: Mapbox tiene límites de requests gratuitos, monitorear uso
5. **Testing**: Probar en dispositivos reales, no solo simuladores

---

¿Te gustaría que implemente alguna de estas funcionalidades específicamente?
