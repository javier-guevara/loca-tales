import 'package:json_annotation/json_annotation.dart';

part 'geocoding_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class GeocodingResponseDto {
  final List<Feature>? features;
  final String? type;

  GeocodingResponseDto({
    this.features,
    this.type,
  });

  factory GeocodingResponseDto.fromJson(Map<String, dynamic> json) =>
      _$GeocodingResponseDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class Feature {
  final String? id;
  final String? type;
  final List<String>? placeType;
  final double? relevance;
  final Properties? properties;
  final String? text;
  final String? placeName;
  final List<double>? center; // [longitude, latitude]
  final Geometry? geometry;

  Feature({
    this.id,
    this.type,
    this.placeType,
    this.relevance,
    this.properties,
    this.text,
    this.placeName,
    this.center,
    this.geometry,
  });

  factory Feature.fromJson(Map<String, dynamic> json) =>
      _$FeatureFromJson(json);
}

@JsonSerializable(createToJson: false)
class Properties {
  final String? accuracy;
  final String? address;
  final String? category;

  Properties({
    this.accuracy,
    this.address,
    this.category,
  });

  factory Properties.fromJson(Map<String, dynamic> json) =>
      _$PropertiesFromJson(json);
}

@JsonSerializable(createToJson: false)
class Geometry {
  final String? type;
  final List<double>? coordinates; // [longitude, latitude]

  Geometry({
    this.type,
    this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) =>
      _$GeometryFromJson(json);
}

