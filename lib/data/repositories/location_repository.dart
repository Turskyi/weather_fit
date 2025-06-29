import 'package:nominatim_api/nominatim_api.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_repository/weather_repository.dart';

class LocationRepository {
  const LocationRepository(
    this._nominatimApiClient,
    this._openMeteoApiClient,
    this._localDataSource,
  );

  final NominatimApiClient _nominatimApiClient;
  final OpenMeteoApiClient _openMeteoApiClient;
  final LocalDataSource _localDataSource;

  static final Map<String, String> _countryNameToCode = <String, String>{
    'Україна': 'UA',
    'Польща': 'PL',
    'Канада': 'CA',
    'Німеччина': 'DE',
    'Болга́рія': 'BG',
  };

  Future<Location> getLocation(String query) async {
    final String locale = _localDataSource.getLanguageIsoCode();
    if (_shouldUseNominatim(query)) {
      final NominatimLocationResponse response =
          await _nominatimApiClient.locationSearch(
        query,
      );

      final List<String> parts = response.displayName
          .split(',')
          .map(
            (String e) => e.trim(),
          )
          .toList();

      final String responseName = response.name;

      final String countryName = response.isCountry
          ? responseName
          : parts.isNotEmpty
              ? parts.last
              : '';

// Try to get oblast or similar.
      final String province = parts.reversed.firstWhere(
        (String part) => part.toLowerCase().contains('область'),
        orElse: () {
          final int middleIndex = (parts.length / 2).floor();
          return parts.length > 2 ? parts[middleIndex] : '';
        },
      );

      final String countryCode = _countryNameToCode[countryName] ?? '';
      return Location(
        id: response.placeId,
        name: responseName,
        latitude: double.parse(response.lat),
        longitude: double.parse(response.lon),
        country: countryName,
        province: province,
        countryCode: countryCode,
        locale: locale,
      );
    } else {
      final LocationResponse response =
          await _openMeteoApiClient.locationSearch(
        query,
      );

      return Location(
        id: response.id,
        name: response.name,
        latitude: response.latitude,
        longitude: response.longitude,
        countryCode: response.countryCode,
        country: response.country,
        province: response.admin1,
        locale: locale,
      );
    }
  }

  /// Use Nominatim if query contains Cyrillic characters.
  bool _shouldUseNominatim(String query) {
    return RegExp(r'[а-яА-ЯіїєІЇЄ]').hasMatch(query);
  }
}
