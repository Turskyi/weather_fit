import 'package:weather_repository/weather_repository.dart';

const String dummyOutfitImageUrl =
    'https://weather-fit-ai.web.app/icons/Icon-512.png';

const String dummyWeatherLocation = 'London';
const WeatherCondition dummyWeatherCondition = WeatherCondition.unknown;
const double dummyWeatherTemperature = 9.8;
const String dummyCountryCode = 'gb';
const String dummyCity = 'London';

const Location dummyLocation = Location(
  latitude: 51.5073219,
  longitude: -0.1276474,
  locale: 'en',
  name: dummyCity,
  countryCode: dummyCountryCode,
  country: 'United Kingdom',
);
