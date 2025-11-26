import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/models/place.dart';

class BottomSheetPlaceInfo extends StatelessWidget {
  final Place place;
  final VoidCallback onClose;
  final VoidCallback onGetDirections;

  const BottomSheetPlaceInfo({
    super.key,
    required this.place,
    required this.onClose,
    required this.onGetDirections,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.name,
                                style: theme.textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    _getCategoryIcon(place.category),
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getCategoryName(place.category),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  if (place.rating != null) ...[
                                    const SizedBox(width: 12),
                                    ...List.generate(
                                      5,
                                      (index) => Icon(
                                        index < place.rating!.round()
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ],
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
                    // Image
                    if (place.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: place.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_not_supported,
                              color: theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      place.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    // Additional Info
                    if (place.openingHours != null) ...[
                      _InfoRow(
                        icon: Icons.access_time,
                        label: 'Horario',
                        value: place.openingHours!,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (place.estimatedDuration != null) ...[
                      _InfoRow(
                        icon: Icons.timer,
                        label: 'Duración estimada',
                        value: place.estimatedDuration!,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (place.priceLevel != null) ...[
                      _InfoRow(
                        icon: Icons.attach_money,
                        label: 'Precio',
                        value: '\$' * place.priceLevel!,
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onGetDirections,
                            icon: const Icon(Icons.directions),
                            label: const Text('Cómo llegar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Add to favorites
                          },
                          icon: const Icon(Icons.favorite_border),
                          label: const Text('Favorito'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(PlaceCategory category) {
    switch (category) {
      case PlaceCategory.attraction:
        return Icons.place;
      case PlaceCategory.restaurant:
        return Icons.restaurant;
      case PlaceCategory.hotel:
        return Icons.hotel;
      case PlaceCategory.nature:
        return Icons.nature;
      case PlaceCategory.culture:
        return Icons.museum;
      case PlaceCategory.shopping:
        return Icons.shopping_bag;
      case PlaceCategory.entertainment:
        return Icons.movie;
      default:
        return Icons.location_on;
    }
  }

  String _getCategoryName(PlaceCategory category) {
    switch (category) {
      case PlaceCategory.attraction:
        return 'Atracción';
      case PlaceCategory.restaurant:
        return 'Restaurante';
      case PlaceCategory.hotel:
        return 'Hotel';
      case PlaceCategory.nature:
        return 'Naturaleza';
      case PlaceCategory.culture:
        return 'Cultura';
      case PlaceCategory.shopping:
        return 'Compras';
      case PlaceCategory.entertainment:
        return 'Entretenimiento';
      default:
        return 'Lugar';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}


