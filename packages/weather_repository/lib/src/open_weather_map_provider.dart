import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather_repository/weather_repository.dart';

class OpenWeatherMapProvider implements WeatherProvider {
  OpenWeatherMapProvider({required this.apiKey, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final String apiKey;
  final http.Client _httpClient;

  @override
  Future<WeatherDomain> getCurrentWeather(Location location) async {
    final Uri url = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      <String, String>{
        'lat': location.latitude.toString(),
        'lon': location.longitude.toString(),
        'appid': apiKey,
        'units': 'metric',
      },
    );
    final http.Response response = await _httpClient.get(url);
    if (response.statusCode != 200) {
      throw Exception('OpenWeatherMap error: ${response.statusCode}');
    }
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    final double temp = (data['main']['temp'] as num).toDouble();
    final int code = (data['weather'] as List<dynamic>).isNotEmpty
        ? (data['weather'][0]['id'] as int)
        : 0;
    final String desc = (data['weather'] as List<dynamic>).isNotEmpty
        ? (data['weather'][0]['description'] as String)
        : '';
    return WeatherDomain(
      temperature: temp,
      location: location,
      condition: _mapOwmCodeToCondition(code),
      countryCode: location.countryCode,
      description: desc,
      weatherCode: code,
      locale: location.locale,
    );
  }

  @override
  Future<DailyForecastDomain> getForecast(Location location) async {
    final Uri url = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/forecast',
      <String, String>{
        'lat': location.latitude.toString(),
        'lon': location.longitude.toString(),
        'appid': apiKey,
        'units': 'metric',
      },
    );
    final http.Response response = await _httpClient.get(url);
    if (response.statusCode != 200) {
      throw Exception('OpenWeatherMap forecast error: ${response.statusCode}');
    }
    final List<dynamic> data =
        jsonDecode(response.body)['list'] as List<dynamic>;
    final List<ForecastItemDomain> forecastItems = data.map((dynamic item) {
      final String dtTxt = item['dt_txt'] as String;
      final double temp = (item['main']['temp'] as num).toDouble();
      final int code = (item['weather'] as List<dynamic>).isNotEmpty
          ? (item['weather'][0]['id'] as int)
          : 0;
      return ForecastItemDomain(
        time: dtTxt,
        temperature: temp,
        weatherCode: code,
      );
    }).toList();
    return DailyForecastDomain(forecast: forecastItems);
  }

  WeatherCondition _mapOwmCodeToCondition(int code) {
    if (code >= 200 && code < 600) {
      return WeatherCondition.rainy;
    } else if (code >= 600 && code < 700) {
      return WeatherCondition.snowy;
    } else if (code == 800) {
      return WeatherCondition.clear;
    } else if (code > 800 && code < 900) {
      return WeatherCondition.cloudy;
    } else {
      return WeatherCondition.unknown;
    }
  }
}
