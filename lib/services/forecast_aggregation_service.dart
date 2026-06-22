import 'package:collection/collection.dart';
import 'package:weather_repository/weather_repository.dart';

List<ForecastItemDomain> aggregateForecastItems(
  List<ForecastItemDomain> items,
) {
  if (items.isEmpty) return <ForecastItemDomain>[];

  final DateTime now = DateTime.now();
  final List<ForecastItemDomain> result = <ForecastItemDomain>[];

  final DateTime today = DateTime(now.year, now.month, now.day);

  for (int dayOffset = 0; dayOffset <= 2; dayOffset++) {
    final DateTime date = today.add(Duration(days: dayOffset));

    // Morning (0-10)
    final ForecastItemDomain? morning = _getAggregatedPeriod(
      items,
      date,
      0,
      10,
      8,
    );
    if (morning != null && _isPeriodRelevant(morning, now, 10)) {
      result.add(morning);
    }
    if (result.length >= 3) break;

    // Day (10-17)
    final ForecastItemDomain? day = _getAggregatedPeriod(
      items,
      date,
      10,
      17,
      13,
    );
    if (day != null && _isPeriodRelevant(day, now, 17)) {
      result.add(day);
    }
    if (result.length >= 3) break;

    // Evening (17-24)
    final ForecastItemDomain? evening = _getAggregatedPeriod(
      items,
      date,
      17,
      24,
      19,
    );
    if (evening != null && _isPeriodRelevant(evening, now, 24)) {
      result.add(evening);
    }
    if (result.length >= 3) break;
  }

  return result.take(3).toList();
}

bool _isPeriodRelevant(
  ForecastItemDomain aggregatedItem,
  DateTime now,
  int endHour,
) {
  final DateTime itemTime = DateTime.parse(aggregatedItem.time);
  final DateTime periodEnd = DateTime(
    itemTime.year,
    itemTime.month,
    itemTime.day,
    endHour,
  );
  return periodEnd.isAfter(now);
}

ForecastItemDomain? _getAggregatedPeriod(
  List<ForecastItemDomain> items,
  DateTime date,
  int startHour,
  int endHour,
  int representativeHour,
) {
  final List<ForecastItemDomain> periodItems = items.where((
    ForecastItemDomain item,
  ) {
    final DateTime? itemTime = DateTime.tryParse(item.time);
    if (itemTime == null) return false;
    return itemTime.year == date.year &&
        itemTime.month == date.month &&
        itemTime.day == date.day &&
        itemTime.hour >= startHour &&
        itemTime.hour < endHour;
  }).toList();

  if (periodItems.isEmpty) return null;

  // Rule 1: Rain Detection
  final ForecastItemDomain? firstRainItem = periodItems.firstWhereOrNull(
    (ForecastItemDomain item) => item.toCondition() == WeatherCondition.rainy,
  );

  int weatherCode;
  if (firstRainItem != null) {
    weatherCode = firstRainItem.weatherCode;
  } else {
    // Rule 2: Majority Condition
    final Map<int, int> counts = <int, int>{};
    for (final ForecastItemDomain item in periodItems) {
      counts[item.weatherCode] = (counts[item.weatherCode] ?? 0) + 1;
    }
    weatherCode = counts.entries
        .sorted(
          (MapEntry<int, int> a, MapEntry<int, int> b) =>
              b.value.compareTo(a.value),
        )
        .first
        .key;
  }

  // Temperature Aggregation: Median
  final List<double> temperatures =
      periodItems.map((ForecastItemDomain item) => item.temperature).toList()
        ..sort();
  final double representativeTemperature =
      temperatures[temperatures.length ~/ 2];

  final DateTime repTime = DateTime(
    date.year,
    date.month,
    date.day,
    representativeHour,
  );

  return ForecastItemDomain(
    time: repTime.toIso8601String(),
    temperature: representativeTemperature,
    weatherCode: weatherCode,
  );
}
