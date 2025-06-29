import 'package:equatable/equatable.dart';

class Location extends Equatable {
  const Location({
    required this.latitude,
    required this.longitude,
    required this.locale,
    this.id = 0,
    this.name = '',
    this.countryCode = '',
    this.country = '',
    this.province = '',
  });

  const Location.empty()
      : this(
          id: 0,
          name: '',
          latitude: 0.0,
          longitude: 0.0,
          countryCode: '',
          country: '',
          province: '',
          locale: '',
        );

  factory Location.fromJson(Map<String, Object?> json) {
    final Object? id = json['id'];
    final Object? name = json['name'];
    final Object? latitude = json['latitude'];
    final Object? longitude = json['longitude'];
    final Object? countryCode = json['country_code'];
    final Object? country = json['country'];
    final Object? province = json['admin1'];
    final Object? locale = json['locale'];

    return Location(
      id: id is int ? id : 0,
      name: name is String ? name : '',
      latitude: latitude is double ? latitude : 0.0,
      longitude: longitude is double ? longitude : 0.0,
      countryCode: countryCode is String ? countryCode : '',
      country: country is String ? country : '',
      province: province is String ? province : '',
      locale: locale is String ? locale : '',
    );
  }

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String countryCode;
  final String country;
  final String province;
  final String locale;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country_code': countryCode,
      'country': country,
      'province': province,
      'locale': locale,
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
        locale,
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
        'locale: $locale'
        '}';
  }

  bool get isEmpty =>
      id == 0 &&
      name.isEmpty &&
      latitude == 0.0 &&
      longitude == 0.0 &&
      countryCode.isEmpty &&
      country.isEmpty &&
      province.isEmpty;

  String get locationName => name.isEmpty
      ? 'Lat: ${latitude.toStringAsFixed(2)}, '
          'Lon: ${longitude.toStringAsFixed(2)}'
      : name;
}
