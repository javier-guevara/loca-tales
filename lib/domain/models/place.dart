import 'package:freezed_annotation/freezed_annotation.dart';
import 'location.dart';

part 'place.freezed.dart';

enum PlaceCategory {
  attraction,
  restaurant,
  hotel,
  transport,
  shopping,
  entertainment,
  nature,
  culture,
}

@freezed
class Place with _$Place {
  const factory Place({
    required String id,
    required String name,
    required String description,
    required Location location,
    required PlaceCategory category,
    double? rating,
    String? imageUrl,
    String? openingHours,
    String? estimatedDuration,
    int? priceLevel, // 1-4
  }) = _Place;

  const Place._();

  bool get isOpenNow {
    // TODO: Implement logic to check if place is open based on openingHours
    return true;
  }
}


