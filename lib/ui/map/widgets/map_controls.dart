import 'package:flutter/material.dart';
import '../../../domain/models/route_info.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCenterUser;
  final Function(TransportMode) onChangeTransportMode;
  final TransportMode currentTransportMode;
  final VoidCallback onToggleTraffic;
  final bool showTraffic;

  const MapControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCenterUser,
    required this.onChangeTransportMode,
    required this.currentTransportMode,
    required this.onToggleTraffic,
    required this.showTraffic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Zoom In
        _ControlButton(
          icon: Icons.add,
          onPressed: onZoomIn,
          backgroundColor: theme.colorScheme.surface,
        ),
        const SizedBox(height: 8),
        // Zoom Out
        _ControlButton(
          icon: Icons.remove,
          onPressed: onZoomOut,
          backgroundColor: theme.colorScheme.surface,
        ),
        const SizedBox(height: 8),
        // Center on User
        _ControlButton(
          icon: Icons.my_location,
          onPressed: onCenterUser,
          backgroundColor: theme.colorScheme.surface,
        ),
        const SizedBox(height: 8),
        // Transport Mode
        _ControlButton(
          icon: _getTransportModeIcon(currentTransportMode),
          onPressed: () => _showTransportModeMenu(context),
          backgroundColor: theme.colorScheme.primary,
          iconColor: theme.colorScheme.onPrimary,
        ),
        const SizedBox(height: 8),
        // Traffic Toggle
        _ControlButton(
          icon: Icons.traffic,
          onPressed: onToggleTraffic,
          backgroundColor: showTraffic
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          iconColor: showTraffic
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
        ),
      ],
    );
  }

  void _showTransportModeMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.directions_walk),
              title: const Text('Caminando'),
              onTap: () {
                onChangeTransportMode(TransportMode.walking);
                Navigator.pop(context);
              },
              selected: currentTransportMode == TransportMode.walking,
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('En auto'),
              onTap: () {
                onChangeTransportMode(TransportMode.driving);
                Navigator.pop(context);
              },
              selected: currentTransportMode == TransportMode.driving,
            ),
            ListTile(
              leading: const Icon(Icons.directions_bike),
              title: const Text('En bicicleta'),
              onTap: () {
                onChangeTransportMode(TransportMode.cycling);
                Navigator.pop(context);
              },
              selected: currentTransportMode == TransportMode.cycling,
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
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color? iconColor;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}


