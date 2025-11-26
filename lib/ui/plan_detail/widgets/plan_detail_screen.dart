import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/travel_plan.dart';
import '../../../data/providers/providers.dart';
import 'itinerary_timeline.dart';
import 'place_card.dart';
import '../../../routing/route_names.dart';

class PlanDetailScreen extends ConsumerWidget {
  final TravelPlan travelPlan;

  const PlanDetailScreen({
    super.key,
    required this.travelPlan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(planDetailViewModelProvider(travelPlan).notifier);
    final plan = ref.watch(planDetailViewModelProvider(travelPlan));
    final theme = Theme.of(context);
    // Use simple date formatting without locale to avoid initialization issues
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.city),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => viewModel.sharePlan(),
            tooltip: 'Compartir plan',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => viewModel.savePlan(),
            tooltip: 'Guardar plan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _HeaderCard(plan: plan, dateFormat: dateFormat),
            const SizedBox(height: 16),
            // Itinerary Timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Itinerario',
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 8),
            ItineraryTimeline(plan: plan),
            const SizedBox(height: 16),
            // Places List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Lugares (${plan.numberOfPlaces})',
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 8),
            ...plan.places.map((place) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: PlaceCard(
                    place: place,
                    onTap: () {
                      // Navigate to map with this place focused
                      context.push(
                        RouteNames.map,
                        extra: {
                          'plan': plan,
                          'focusedPlace': place,
                        },
                      );
                    },
                    onRemove: () => viewModel.removePlaceFromPlan(place.id),
                  ),
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final TravelPlan plan;
  final DateFormat dateFormat;

  const _HeaderCard({
    required this.plan,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_city,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plan.city,
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  '${dateFormat.format(plan.startDate)} - ${dateFormat.format(plan.endDate)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.place,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  '${plan.numberOfPlaces} lugares · ${plan.totalDays} días',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            if (plan.budget != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Presupuesto: \$${plan.budget!['min']} - \$${plan.budget!['max']}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
