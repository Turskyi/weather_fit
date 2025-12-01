import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart';

const String dummyOutfitImageUrl =
    'https://weather-fit-ai.web.app/icons/Icon-512.png';

const String dummyWeatherLocation = 'London';
const WeatherCondition dummyWeatherCondition = WeatherCondition.unknown;
const double dummyWeatherTemperature = 9.8;
const String dummyCountryCode = 'en';
const String dummyCity = 'London';
const String dummyWeatherDescription = 'Fog';
const int dummyWeatherCode = 45;
const String dummyLocale = 'en';
const String dummyForecastTime = '2025-11-25T00:00';

const Location dummyLocation = Location(
  latitude: 51.5073219,
  longitude: -0.1276474,
  locale: 'en',
  name: dummyCity,
  countryCode: dummyCountryCode,
  country: 'United Kingdom',
);

Weather dummyWeather = Weather(
  location: dummyLocation,
  temperature: const Temperature(value: dummyWeatherTemperature),
  lastUpdatedDateTime: DateTime(2025, DateTime.april, 1),
  condition: dummyWeatherCondition,
  temperatureUnits: TemperatureUnits.celsius,
  countryCode: dummyCountryCode,
  description: dummyWeatherDescription,
  code: dummyWeatherCode,
  locale: dummyLocale,
);
