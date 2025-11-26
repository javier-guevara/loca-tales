import 'package:freezed_annotation/freezed_annotation.dart';
import 'place.dart';
import 'route_info.dart';

part 'travel_plan.freezed.dart';

@freezed
class TravelPlan with _$TravelPlan {
  const factory TravelPlan({
    required String id,
    required String city,
    required DateTime startDate,
    required DateTime endDate,
    required List<Place> places,
    List<RouteInfo>? routes,
    Map<String, dynamic>? budget,
    Map<String, dynamic>? preferences,
    DateTime? generatedAt,
    String? userId,
  }) = _TravelPlan;

  const TravelPlan._();

  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }

  double get totalDistance {
    if (routes == null || routes!.isEmpty) return 0.0;
    return routes!.fold(0.0, (sum, route) => sum + route.distance);
  }

  Duration get totalDuration {
    if (routes == null || routes!.isEmpty) return Duration.zero;
    return routes!.fold(
      Duration.zero,
      (sum, route) => sum + route.duration,
    );
  }

  int get numberOfPlaces => places.length;

  List<Place> getPlacesByCategory(PlaceCategory category) {
    return places.where((place) => place.category == category).toList();
  }
}


