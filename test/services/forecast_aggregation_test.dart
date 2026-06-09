import 'package:flutter_test/flutter_test.dart';
import 'package:weather_fit/services/forecast_aggregation_service.dart';
import 'package:weather_repository/weather_repository.dart';

void main() {
  group('Forecast Aggregation Rules', () {
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    final String tomorrowStr =
        '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-'
        '${tomorrow.day.toString().padLeft(2, '0')}';

    test('Rule 1: Rain priority - should show rain if ANY hour has rain', () {
      final List<ForecastItemDomain> hourlyData = <ForecastItemDomain>[
        ForecastItemDomain(
          time: '${tomorrowStr}T06:00',
          temperature: 20,
          weatherCode: 0, // Clear
        ),
        ForecastItemDomain(
          time: '${tomorrowStr}T07:00',
          temperature: 20,
          weatherCode: 0, // Clear
        ),
        ForecastItemDomain(
          time: '${tomorrowStr}T08:00',
          temperature: 20,
          weatherCode: 61, // Slight rain
        ),
        ForecastItemDomain(
          time: '${tomorrowStr}T09:00',
          temperature: 20,
          weatherCode: 0, // Clear
        ),
      ];

      final List<ForecastItemDomain> result = aggregateForecastItems(
        hourlyData,
      );

      // We expect the first period (Morning) to be at index 0 because it's
      // tomorrow
      final ForecastItemDomain morning = result.firstWhere(
        (ForecastItemDomain item) => DateTime.parse(item.time).hour == 8,
      );
      expect(morning.weatherCode, 61);
    });

    test(
      'Rule 2: Majority condition - should show most common code if no rain',
      () {
        final List<ForecastItemDomain> hourlyData = <ForecastItemDomain>[
          ForecastItemDomain(
            time: '${tomorrowStr}T10:00',
            temperature: 25,
            weatherCode: 3, // Overcast
          ),
          ForecastItemDomain(
            time: '${tomorrowStr}T11:00',
            temperature: 25,
            weatherCode: 0, // Clear
          ),
          ForecastItemDomain(
            time: '${tomorrowStr}T12:00',
            temperature: 25,
            weatherCode: 0, // Clear
          ),
          ForecastItemDomain(
            time: '${tomorrowStr}T13:00',
            temperature: 25,
            weatherCode: 0, // Clear
          ),
          ForecastItemDomain(
            time: '${tomorrowStr}T14:00',
            temperature: 25,
            weatherCode: 3, // Overcast
          ),
        ];

        final List<ForecastItemDomain> result = aggregateForecastItems(
          hourlyData,
        );

        final ForecastItemDomain day = result.firstWhere(
          (ForecastItemDomain item) => DateTime.parse(item.time).hour == 13,
        );
        expect(day.weatherCode, 0); // Clear is majority
      },
    );

    test('Temperature Aggregation: should use median temperature', () {
      final List<ForecastItemDomain> hourlyData = <ForecastItemDomain>[
        ForecastItemDomain(
          time: '${tomorrowStr}T17:00',
          temperature: 15,
          weatherCode: 0,
        ),
        ForecastItemDomain(
          time: '${tomorrowStr}T18:00',
          temperature: 18,
          weatherCode: 0,
        ),
        ForecastItemDomain(
          time: '${tomorrowStr}T19:00',
          temperature: 22,
          weatherCode: 0,
        ),
        ForecastItemDomain(
          time: '${tomorrowStr}T20:00',
          temperature: 19,
          weatherCode: 0,
        ),
        ForecastItemDomain(
          time: '${tomorrowStr}T21:00',
          temperature: 16,
          weatherCode: 0,
        ),
      ];
      // Sorted temps: 15, 16, 18, 19, 22. Median is 18.

      final List<ForecastItemDomain> result = aggregateForecastItems(
        hourlyData,
      );

      final ForecastItemDomain evening = result.firstWhere(
        (ForecastItemDomain item) => DateTime.parse(item.time).hour == 19,
      );
      expect(evening.temperature, 18);
    });

    test('Period Definitions: should correctly split day into 3 periods', () {
      final List<ForecastItemDomain> hourlyData = <ForecastItemDomain>[];
      // Populate 24 hours for tomorrow
      for (int i = 0; i < 24; i++) {
        hourlyData.add(
          ForecastItemDomain(
            time: '${tomorrowStr}T${i.toString().padLeft(2, '0')}:00',
            temperature: 20,
            weatherCode: 0,
          ),
        );
      }

      final List<ForecastItemDomain> result = aggregateForecastItems(
        hourlyData,
      );

      expect(result.length, 3);
      expect(DateTime.parse(result[0].time).hour, 8); // Morning rep hour
      expect(DateTime.parse(result[1].time).hour, 13); // Day rep hour
      expect(DateTime.parse(result[2].time).hour, 19); // Evening rep hour
    });

    test('Relevance: should filter out past periods', () {
      final DateTime now = DateTime.now();
      // If now is 11:00 AM, Morning (0-10) is past.
      // We need a fixed 'now' to test this reliably, or we test based on
      // relative time.

      // We'll create items for "today" at various hours.
      final String todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';

      final List<ForecastItemDomain> hourlyData = <ForecastItemDomain>[
        ForecastItemDomain(
          time: '${todayStr}T08:00',
          temperature: 10,
          weatherCode: 0,
        ),
        ForecastItemDomain(
          time: '${todayStr}T13:00',
          temperature: 20,
          weatherCode: 0,
        ),
        ForecastItemDomain(
          time: '${todayStr}T19:00',
          temperature: 15,
          weatherCode: 0,
        ),
      ];

      final List<ForecastItemDomain> result = aggregateForecastItems(
        hourlyData,
      );

      // The result should only contain periods that END after 'now'.
      for (final ForecastItemDomain item in result) {
        final DateTime itemTime = DateTime.parse(item.time);
        if (itemTime.day == now.day) {
          // If it's today, it must be a future period
          int endHour = itemTime.hour == 8
              ? 10
              : (itemTime.hour == 13 ? 17 : 24);
          final DateTime periodEnd = DateTime(
            now.year,
            now.month,
            now.day,
            endHour,
          );
          expect(periodEnd.isAfter(now), isTrue);
        }
      }
    });
  });
}
