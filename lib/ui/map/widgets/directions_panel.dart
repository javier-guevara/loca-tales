import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/models/place.dart';
import '../../../domain/models/route_info.dart';

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
                      Expanded(
                        child: _TransportModeChip(
                          icon: Icons.directions_walk,
                          label: 'Caminar',
                          mode: TransportMode.walking,
                          currentMode: route.transportMode,
                          onTap: () => onChangeMode(TransportMode.walking),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TransportModeChip(
                          icon: Icons.directions_car,
                          label: 'Conducir',
                          mode: TransportMode.driving,
                          currentMode: route.transportMode,
                          onTap: () => onChangeMode(TransportMode.driving),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TransportModeChip(
                          icon: Icons.directions_bike,
                          label: 'Bicicleta',
                          mode: TransportMode.cycling,
                          currentMode: route.transportMode,
                          onTap: () => onChangeMode(TransportMode.cycling),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Start navigation button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openInExternalMaps(destination),
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
    final lat = destination.location.latitude;
    final lon = destination.location.longitude;
    final name = Uri.encodeComponent(destination.name);
    
    // Try Mapbox Navigation first (if installed)
    final mapboxUrl = Uri.parse('mapbox://navigation?destination=$lon,$lat&name=$name');
    
    // Fallback URLs
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon');
    final appleMapsUrl = Uri.parse('http://maps.apple.com/?daddr=$lat,$lon&dirflg=d');
    
    // Try Mapbox first
    if (await canLaunchUrl(mapboxUrl)) {
      await launchUrl(mapboxUrl, mode: LaunchMode.externalApplication);
      return;
    }
    
    // Try Google Maps
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      return;
    }
    
    // Fallback to Apple Maps on iOS
    if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      return;
    }
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
    
    return InkWell(
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
    );
  }
}
