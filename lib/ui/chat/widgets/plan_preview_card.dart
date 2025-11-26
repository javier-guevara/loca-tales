import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/travel_plan.dart';
import '../../../routing/route_names.dart';
import 'package:intl/intl.dart';

class PlanPreviewCard extends StatelessWidget {
  final TravelPlan travelPlan;

  const PlanPreviewCard({
    super.key,
    required this.travelPlan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use simple date formatting without locale to avoid initialization issues
    final dateFormat = DateFormat('dd MMM');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    travelPlan.city,
                    style: theme.textTheme.headlineMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${dateFormat.format(travelPlan.startDate)} - ${dateFormat.format(travelPlan.endDate)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${travelPlan.numberOfPlaces} lugares · ${travelPlan.totalDays} días',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            // Categories chips
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: travelPlan.places
                  .map((place) => place.category)
                  .toSet()
                  .take(4)
                  .map((category) => Chip(
                        label: Text(
                          _categoryName(category),
                          style: const TextStyle(fontSize: 10),
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push(RouteNames.map, extra: travelPlan);
                    },
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text('Mapa'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push(RouteNames.planDetail, extra: travelPlan);
                    },
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Detalles'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _categoryName(dynamic category) {
    final categoryStr = category.toString().split('.').last;
    switch (categoryStr) {
      case 'attraction':
        return 'Atracción';
      case 'restaurant':
        return 'Restaurante';
      case 'hotel':
        return 'Hotel';
      case 'nature':
        return 'Naturaleza';
      case 'culture':
        return 'Cultura';
      case 'shopping':
        return 'Compras';
      case 'entertainment':
        return 'Entretenimiento';
      default:
        return categoryStr;
    }
  }
}


