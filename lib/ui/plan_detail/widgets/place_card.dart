import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/models/place.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (place.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: place.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 150,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 150,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (onRemove != null)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onRemove,
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(place.category),
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _getCategoryName(place.category),
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (place.rating != null) ...[
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < place.rating!.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 12,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (place.estimatedDuration != null ||
                      place.priceLevel != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (place.estimatedDuration != null) ...[
                          Icon(
                            Icons.timer,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.estimatedDuration!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                        if (place.priceLevel != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.attach_money,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$' * place.priceLevel!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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


