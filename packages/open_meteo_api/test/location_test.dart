import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:test/test.dart';

void main() {
  group('Location', () {
    group('fromJson', () {
      test('returns correct Location object', () {
        expect(
          LocationResponse.fromJson(
            <String, dynamic>{
              'id': 4887398,
              'name': 'Chicago',
              'latitude': 41.85003,
              'longitude': -87.65005,
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
