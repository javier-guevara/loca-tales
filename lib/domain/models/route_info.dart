import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_info.freezed.dart';

enum TransportMode {
  walking,
  driving,
  cycling,
  transit,
}

@freezed
class RouteInfo with _$RouteInfo {
  const factory RouteInfo({
    required double distance, // in kilometers
    required Duration duration,
    required TransportMode transportMode,
    required String polyline, // encoded polyline
    List<String>? steps,
  }) = _RouteInfo;

  const RouteInfo._();

  double get distanceInMeters => distance * 1000;

  int get durationInMinutes => duration.inMinutes;
}


