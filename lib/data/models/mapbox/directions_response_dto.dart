import 'package:json_annotation/json_annotation.dart';

part 'directions_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DirectionsResponseDto {
  final List<Route>? routes;
  final String? code;

  DirectionsResponseDto({
    this.routes,
    this.code,
  });

  factory DirectionsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DirectionsResponseDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class Route {
  final Geometry? geometry;
  final double? distance; // in meters
  final double? duration; // in seconds
  final List<Leg>? legs;

  Route({
    this.geometry,
    this.distance,
    this.duration,
    this.legs,
  });

  factory Route.fromJson(Map<String, dynamic> json) =>
      _$RouteFromJson(json);
}

@JsonSerializable(createToJson: false)
class Geometry {
  final String? type;
  final List<List<double>>? coordinates;

  Geometry({
    this.type,
    this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) =>
      _$GeometryFromJson(json);
}

@JsonSerializable(createToJson: false)
class Leg {
  final double? distance;
  final double? duration;
  final List<Step>? steps;

  Leg({
    this.distance,
    this.duration,
    this.steps,
  });

  factory Leg.fromJson(Map<String, dynamic> json) => _$LegFromJson(json);
}

@JsonSerializable(createToJson: false)
class Step {
  final Maneuver? maneuver;
  final double? distance;
  final double? duration;
  final String? name;

  Step({
    this.maneuver,
    this.distance,
    this.duration,
    this.name,
  });

  factory Step.fromJson(Map<String, dynamic> json) => _$StepFromJson(json);
}

@JsonSerializable(createToJson: false)
class Maneuver {
  final String? instruction;
  final String? type;
  @JsonKey(name: 'bearing_after')
  final double? bearingAfter;
  final List<double>? location;

  Maneuver({
    this.instruction,
    this.type,
    this.bearingAfter,
    this.location,
  });

  factory Maneuver.fromJson(Map<String, dynamic> json) => _$ManeuverFromJson(json);
}

