import 'package:equatable/equatable.dart';

class Location extends Equatable {
  const Location({
    this.id = 0,
    this.name = '',
    required this.latitude,
    required this.longitude,
    this.countryCode = '',
    this.country = '',
    this.province = '',
  });

  factory Location.fromJson(Map<String, Object?> json) {
    final Object? id = json['id'];
    final Object? name = json['name'];
    final Object? latitude = json['latitude'];
    final Object? longitude = json['longitude'];
    final Object? countryCode = json['country_code'];
    final Object? country = json['country'];
    final Object? province = json['admin1'];

    return Location(
      id: id is int ? id : 0,
      name: name is String ? name : 'Unknown',
      latitude: latitude is double ? latitude : 0.0,
      longitude: longitude is double ? longitude : 0.0,
      countryCode: countryCode is String ? countryCode : '',
      country: country is String ? country : 'Unknown',
      province: province is String ? province : '',
    );
  }

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String countryCode;
  final String country;
  final String province;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country_code': countryCode,
      'country': country,
      'province': province,
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        latitude,
        longitude,
        countryCode,
        country,
        province,
      ];

  @override
  String toString() {
    return 'Location{'
        'id: $id, '
        'name: $name, '
        'latitude: $latitude, '
        'longitude: $longitude, '
        'countryCode: $countryCode, '
        'country: $country, '
        'province: $province,'
        '}';
  }
}
