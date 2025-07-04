import 'package:nominatim_api/nominatim_api.dart';
import 'package:test/test.dart';

void main() {
  group('NominatimLocationResponse', () {
    group('fromJson', () {
      test('returns correct NominatimLocationResponse object', () {
        final Map<String, Object?> json = <String, Object?>{
          'place_id': 178260985,
          'lat': '50.4500336',
          'lon': '30.5241361',
          'display_name': 'Київ, Україна',
          'address': <String, String>{
            'country': 'Україна',
            'country_code': 'uk',
          },
        };

        final NominatimLocationResponse location =
            NominatimLocationResponse.fromJson(json);

        expect(location, isA<NominatimLocationResponse>());
        expect(location.placeId, 178260985);
        expect(location.lat, '50.4500336');
        expect(location.lon, '30.5241361');
        expect(location.displayName, 'Київ, Україна');
        expect(location.name, 'Київ');
      });
    });
  });
}
