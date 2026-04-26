import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather_repository/src/utils/weather_code_to_condition.dart';
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
    final int rawCode = (data['weather'] as List<dynamic>).isNotEmpty
        ? (data['weather'][0]['id'] as int)
        : 0;
    final int wmoCode = _mapOwmToWmo(rawCode);
    final String desc = (data['weather'] as List<dynamic>).isNotEmpty
        ? (data['weather'][0]['description'] as String)
        : '';
    return WeatherDomain(
      temperature: temp,
      location: location,
      condition: wmoCode.toCondition,
      countryCode: location.countryCode,
      description: desc,
      weatherCode: wmoCode,
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
      final int rawCode = (item['weather'] as List<dynamic>).isNotEmpty
          ? (item['weather'][0]['id'] as int)
          : 0;
      return ForecastItemDomain(
        time: dtTxt,
        temperature: temp,
        weatherCode: _mapOwmToWmo(rawCode),
      );
    }).toList();
    return DailyForecastDomain(forecast: forecastItems);
  }

  int _mapOwmToWmo(int code) {
    if (code >= 200 && code <= 232) {
      return 95; // Thunderstorm
    } else if (code >= 300 && code <= 321) {
      return 51; // Drizzle
    } else if (code >= 500 && code <= 504) {
      return 61; // Rain
    } else if (code == 511) {
      return 66; // Freezing rain
    } else if (code >= 520 && code <= 531) {
      return 80; // Rain showers
    } else if (code >= 600 && code <= 602) {
      return 71; // Snow
    } else if (code >= 611 && code <= 616) {
      return 77; // Sleet
    } else if (code >= 620 && code <= 622) {
      return 85; // Snow showers
    } else if (code >= 701 && code <= 781) {
      return 45; // Atmosphere (Fog)
    } else if (code == 800) {
      return 0; // Clear
    } else if (code == 801) {
      return 1; // Mainly clear
    } else if (code == 802) {
      return 2; // Partly cloudy
    } else if (code == 803) {
      return 2; // Broken clouds -> Partly cloudy
    } else if (code == 804) {
      return 3; // Overcast
    } else {
      return code; // Fallback to original code
    }
  }
}
