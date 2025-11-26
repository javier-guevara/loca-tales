import 'package:flutter/material.dart';
import '../../../domain/models/travel_plan.dart';
import '../../../domain/models/place.dart';
import 'package:intl/intl.dart';

class ItineraryTimeline extends StatelessWidget {
  final TravelPlan plan;

  const ItineraryTimeline({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = plan.totalDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: days,
        itemBuilder: (context, dayIndex) {
          final day = dayIndex + 1;
          final dayPlaces = _getPlacesForDay(day);

          return _TimelineDay(
            day: day,
            places: dayPlaces,
            isLast: day == days,
            theme: theme,
          );
        },
      ),
    );
  }

  List<Place> _getPlacesForDay(int day) {
    // Simple distribution - in production, use dailyItinerary from plan
    final placesPerDay = (plan.places.length / plan.totalDays).ceil();
    final startIndex = (day - 1) * placesPerDay;
    final endIndex = (startIndex + placesPerDay).clamp(0, plan.places.length);

    return plan.places.sublist(
      startIndex,
      endIndex,
    );
  }
}

class _TimelineDay extends StatelessWidget {
  final int day;
  final List<Place> places;
  final bool isLast;
  final ThemeData theme;

  const _TimelineDay({
    required this.day,
    required this.places,
    required this.isLast,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 80,
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Day content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Día $day',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...places.map((place) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _getCategoryIcon(place.category),
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              place.name,
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          if (place.estimatedDuration != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              _formatDuration(place.estimatedDuration!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(String duration) {
    // Format ISO 8601 duration to readable format
    // PT2H30M -> 2h 30m
    try {
      final cleaned = duration.replaceAll('PT', '');
      final hours = RegExp(r'(\d+)H').firstMatch(cleaned)?.group(1);
      final minutes = RegExp(r'(\d+)M').firstMatch(cleaned)?.group(1);
      
      final parts = <String>[];
      if (hours != null) parts.add('${hours}h');
      if (minutes != null) parts.add('${minutes}m');
      
      return parts.isNotEmpty ? parts.join(' ') : duration;
    } catch (e) {
      return duration;
    }
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
}


