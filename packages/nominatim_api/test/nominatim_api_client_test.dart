import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:nominatim_api/nominatim_api.dart';
import 'package:test/test.dart';

import 'helpers/mocks.dart';

void main() {
  group('NominatimApiClient', () {
    late http.Client httpClient;
    late NominatimApiClient apiClient;

    setUpAll(() {
      registerFallbackValue(FakeUri());
    });

    setUp(() {
      httpClient = MockHttpClient();
      apiClient = NominatimApiClient(httpClient: httpClient);
    });

    group('constructor', () {
      test('does not require an httpClient', () {
        expect(NominatimApiClient(), isNotNull);
      });
    });

    group('locationSearch', () {
      const String query = 'Київ';

      test('makes correct HTTP request', () async {
        final MockResponse response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('''
          [
            {
              "place_id": 178260985,
              "lat": "50.4500336",
              "lon": "30.5241361",
              "display_name": "Київ, Україна",
              "address": {
                "country": "Україна",
                "country_code": "uk"
              }
            }
          ]
          ''');
        when(
          () => httpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => response);

        await apiClient.locationSearch(query);

        verify(
          () => httpClient.get(
            Uri.https(
              'nominatim.openstreetmap.org',
              '/search',
              <String, String>{
                'q': query,
                'format': 'json',
                'limit': '1',
                'accept-language': 'uk,en',
              },
            ),
            headers: any(named: 'headers'),
          ),
        ).called(1);
      });

      test(
        'throws NominatimLocationRequestFailure on non-200 response',
        () async {
          final MockResponse response = MockResponse();
          when(() => response.statusCode).thenReturn(200);
          when(() => response.body).thenReturn('[]');
          when(
            () => httpClient.get(any(), headers: any(named: 'headers')),
          ).thenAnswer((_) async => response);

          expect(
            () => apiClient.locationSearch(query),
            throwsA(isA<NominatimLocationRequestFailure>()),
          );
        },
      );

      test('returns NominatimLocationResponse on valid response', () async {
        final MockResponse response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('''
[
  {
    "place_id": 178260985,
    "lat": "50.4500336",
    "lon": "30.5241361",
    "display_name": "Київ, Україна",
    "name": "Київ",
    "address": {
      "country": "Україна",
      "country_code": "ua"
    }
  }
]
          ''');
        when(
          () => httpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => response);

        final NominatimLocationResponse result = await apiClient.locationSearch(
          query,
        );

        expect(result, isA<NominatimLocationResponse>());
        expect(result.name, 'Київ');
        expect(result.displayName, contains('Київ'));
        expect(result.lat, '50.4500336');
        expect(result.lon, '30.5241361');
      });
    });

    group('reverseSearch', () {
      const double lat = 50.45;
      const double lon = 30.52;

      test('makes correct HTTP request', () async {
        final MockResponse response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('''
          {
            "place_id": 178260985,
            "lat": "50.4500336",
            "lon": "30.5241361",
            "display_name": "Київ, Україна",
            "address": {
              "city": "Київ",
              "country": "Україна",
              "country_code": "uk"
            }
          }
          ''');
        when(
          () => httpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => response);

        await apiClient.reverseSearch(latitude: lat, longitude: lon);

        verify(
          () => httpClient.get(
            Uri.https(
              'nominatim.openstreetmap.org',
              '/reverse',
              <String, String>{
                'lat': lat.toString(),
                'lon': lon.toString(),
                'format': 'json',
                'accept-language': 'uk,en',
              },
            ),
            headers: any(named: 'headers'),
          ),
        ).called(1);
      });

      test('returns NominatimLocationResponse on valid response', () async {
        final MockResponse response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('''
{
  "place_id": 178260985,
  "lat": "50.4500336",
  "lon": "30.5241361",
  "display_name": "Київ, Україна",
  "address": {
    "city": "Київ",
    "country": "Україна",
    "country_code": "ua"
  }
}
          ''');
        when(
          () => httpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => response);

        final NominatimLocationResponse result = await apiClient.reverseSearch(
          latitude: lat,
          longitude: lon,
        );

        expect(result, isA<NominatimLocationResponse>());
        expect(result.displayName, contains('Київ'));
        expect(result.address['city'], 'Київ');
      });
    });
  });
}
