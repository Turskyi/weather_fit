import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:test/test.dart';

void main() {
  group('Location', () {
    group('fromJson', () {
      test('returns correct Location object', () {
        expect(
          LocationResponse.fromJson(
            <String, Object?>{
              'id': 4887398,
              'name': 'Chicago',
              'latitude': 41.85003,
              'longitude': -87.65005,
              'country_code': 'US',
              'country': 'United States',
              'admin1': 'Illinois',
            },
          ),
          isA<LocationResponse>()
              .having((LocationResponse w) => w.id, 'id', 4887398)
              .having((LocationResponse w) => w.name, 'name', 'Chicago')
              .having((LocationResponse w) => w.latitude, 'latitude', 41.85003)
              .having(
                (LocationResponse w) => w.longitude,
                'longitude',
                -87.65005,
              ),
        );
      });
    });
  });
}
