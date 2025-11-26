import 'package:flutter/material.dart';
import '../../../domain/models/route_info.dart';

class RouteOverlay extends StatelessWidget {
  final RouteInfo route;
  final VoidCallback onClose;
  final Function(TransportMode) onChangeMode;

  const RouteOverlay({
    super.key,
    required this.route,
    required this.onClose,
    required this.onChangeMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 16,
      right: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              _getTransportModeIcon(route.transportMode),
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDistance(route.distance),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatDuration(route.duration),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.swap_horiz,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => _showChangeModeDialog(context),
              tooltip: 'Cambiar modo de transporte',
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
              tooltip: 'Cerrar',
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar modo de transporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.directions_walk),
              title: const Text('Caminando'),
              onTap: () {
                onChangeMode(TransportMode.walking);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('En auto'),
              onTap: () {
                onChangeMode(TransportMode.driving);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_bike),
              title: const Text('En bicicleta'),
              onTap: () {
                onChangeMode(TransportMode.cycling);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransportModeIcon(TransportMode mode) {
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

  String _formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceInKm.toStringAsFixed(1)} km';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}min';
    }
    return '${duration.inMinutes} min';
  }
}


