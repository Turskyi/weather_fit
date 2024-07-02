import 'package:json_annotation/json_annotation.dart';

part 'location_response.g.dart';

@JsonSerializable()
class LocationResponse {
  const LocationResponse({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.countryCode,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) =>
      _$LocationResponseFromJson(json);

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  @JsonKey(name: 'country_code')
  final String countryCode;

  @override
  String toString() {
    return 'LocationResponse{id: $id, name: $name, latitude: $latitude, '
        'longitude: $longitude, countryCode: $countryCode}';
  }
}
