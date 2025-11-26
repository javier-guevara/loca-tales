import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';

@freezed
class Location with _$Location {
  const factory Location({
    required double latitude,
    required double longitude,
    String? address,
  }) = _Location;

  const Location._();

  bool get isValid => 
      latitude >= -90 && latitude <= 90 && 
      longitude >= -180 && longitude <= 180;
}


