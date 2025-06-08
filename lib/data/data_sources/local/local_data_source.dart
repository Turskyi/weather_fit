import 'dart:math';

import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_repository/weather_repository.dart';

class LocalDataSource {
  const LocalDataSource();

  String getOutfitImageAssetPath(Weather weather) {
    final WeatherCondition condition = weather.condition;
    final double temperatureValue = weather.temperature.value;
    if (temperatureValue < -40) {
      return '${constants.outfitImagePath}-40.png';
    }

    // Round down temperature to nearest 10 degrees.
    int roundedTemp = (temperatureValue / 10).floor() * 10;

    // Clamp to -30...30.
    if (roundedTemp > 30) roundedTemp = 30;
    if (roundedTemp < -30) roundedTemp = -30;

    final String precipitation = 'precipitation';

    // Random condition for unknown states
    final List<String> possibleConditions = <String>[
      WeatherCondition.clear.name,
      WeatherCondition.cloudy.name,
      precipitation,
    ];

    // Handle unknowns early.
    if (condition.isUnknown) {
      final int index = Random().nextInt(possibleConditions.length);
      final String randomConditionName = possibleConditions[index];
      return '${constants.outfitImagePath}${randomConditionName}_$roundedTemp'
          '.png';
    }

    // Normalize snowy → precipitation for shared assets
    final String conditionName = switch (condition) {
      WeatherCondition.clear => condition.name,
      WeatherCondition.cloudy => condition.name,
      WeatherCondition.rainy || WeatherCondition.snowy => precipitation,
      _ => WeatherCondition.unknown.name,
    };

    return '${constants.outfitImagePath}${conditionName}_$roundedTemp.png';
  }
}
