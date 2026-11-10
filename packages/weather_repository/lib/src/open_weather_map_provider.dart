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

  static const String _baseUrl = 'api.openweathermap.org';
  static const String _weatherEndpoint = '/data/2.5/weather';
  static const String _forecastEndpoint = '/data/2.5/forecast';

  static const String _latParam = 'lat';
  static const String _lonParam = 'lon';
  static const String _appidParam = 'appid';
  static const String _unitsParam = 'units';
  static const String _metricUnits = 'metric';

  static const String _mainKey = 'main';
  static const String _tempKey = 'temp';
  static const String _feelsLikeKey = 'feels_like';
  static const String _humidityKey = 'humidity';
  static const String _pressureKey = 'pressure';
  static const String _windKey = 'wind';
  static const String _speedKey = 'speed';
  static const String _visibilityKey = 'visibility';
  static const String _cloudsKey = 'clouds';
  static const String _allKey = 'all';
  static const String _weatherKey = 'weather';
  static const String _idKey = 'id';
  static const String _descriptionKey = 'description';
  static const String _sysKey = 'sys';
  static const String _sunriseKey = 'sunrise';
  static const String _sunsetKey = 'sunset';
  static const String _dtKey = 'dt';
  static const String _listKey = 'list';
  static const String _dtTxtKey = 'dt_txt';

  @override
  Future<WeatherDomain> getCurrentWeather(Location location) async {
    final Uri url = Uri.https(_baseUrl, _weatherEndpoint, <String, String>{
      _latParam: location.latitude.toString(),
      _lonParam: location.longitude.toString(),
      _appidParam: apiKey,
      _unitsParam: _metricUnits,
    });
    final http.Response response = await _httpClient.get(url);
    if (response.statusCode != 200) {
      throw Exception('OpenWeatherMap error: ${response.statusCode}');
    }

    final Object? jsonBody = jsonDecode(response.body);
    if (jsonBody is! Map<String, Object?>) {
      throw Exception('Invalid OpenWeatherMap response format');
    }
    final Map<String, Object?> data = jsonBody;

    final Object? mainObj = data[_mainKey];
    final double temp = switch (mainObj) {
      Map<String, Object?> mainMap when mainMap[_tempKey] is num =>
        (mainMap[_tempKey] as num).toDouble(),
      _ => 0.0,
    };
    final double? feelsLike = switch (mainObj) {
      Map<String, Object?> mainMap when mainMap[_feelsLikeKey] is num =>
        (mainMap[_feelsLikeKey] as num).toDouble(),
      _ => null,
    };
    final double? humidity = switch (mainObj) {
      Map<String, Object?> mainMap when mainMap[_humidityKey] is num =>
        (mainMap[_humidityKey] as num).toDouble(),
      _ => null,
    };
    final double? pressure = switch (mainObj) {
      Map<String, Object?> mainMap when mainMap[_pressureKey] is num =>
        (mainMap[_pressureKey] as num).toDouble(),
      _ => null,
    };

    final Object? windObj = data[_windKey];
    final double? windSpeed = switch (windObj) {
      Map<String, Object?> windMap when windMap[_speedKey] is num =>
        (windMap[_speedKey] as num).toDouble(),
      _ => null,
    };

    final double? visibility = data[_visibilityKey] is num
        ? (data[_visibilityKey] as num).toDouble()
        : null;

    final Object? cloudsObj = data[_cloudsKey];
    final double? cloudCover = switch (cloudsObj) {
      Map<String, Object?> cloudsMap when cloudsMap[_allKey] is num =>
        (cloudsMap[_allKey] as num).toDouble(),
      _ => null,
    };

    final Object? weatherListObj = data[_weatherKey];
    int rawCode = 0;
    String desc = '';
    if (weatherListObj is List<Object?> && weatherListObj.isNotEmpty) {
      final Object? firstWeather = weatherListObj.first;
      if (firstWeather is Map<String, Object?>) {
        if (firstWeather[_idKey] is int) {
          rawCode = firstWeather[_idKey] as int;
        } else if (firstWeather[_idKey] is num) {
          rawCode = (firstWeather[_idKey] as num).toInt();
        }
        if (firstWeather[_descriptionKey] is String) {
          desc = firstWeather[_descriptionKey] as String;
        }
      }
    }
    final int wmoCode = _mapOwmToWmo(rawCode);

    final Object? sysObj = data[_sysKey];
    final Map<String, Object?>? sys = sysObj is Map<String, Object?>
        ? sysObj
        : null;
    final int? sunrise = sys?[_sunriseKey] is num
        ? (sys![_sunriseKey] as num).toInt()
        : null;
    final int? sunset = sys?[_sunsetKey] is num
        ? (sys![_sunsetKey] as num).toInt()
        : null;
    final int? dt = data[_dtKey] is num ? (data[_dtKey] as num).toInt() : null;

    bool? isDay;
    if (sunrise != null && sunset != null && dt != null) {
      isDay = dt >= sunrise && dt < sunset;
    } else if (sunrise != null && sunset != null) {
      final int nowEpochSeconds =
          DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      isDay = nowEpochSeconds >= sunrise && nowEpochSeconds < sunset;
    }

    return WeatherDomain(
      temperature: temp,
      location: location,
      condition: wmoCode.toCondition,
      countryCode: location.countryCode,
      description: desc,
      weatherCode: wmoCode,
      locale: location.locale,
      feelsLike: feelsLike,
      humidity: humidity,
      windSpeed: windSpeed,
      pressure: pressure,
      visibility: visibility,
      cloudCover: cloudCover,
      isDay: isDay,
    );
  }

  @override
  Future<DailyForecastDomain> getForecast(Location location) async {
    final Uri url = Uri.https(_baseUrl, _forecastEndpoint, <String, String>{
      _latParam: location.latitude.toString(),
      _lonParam: location.longitude.toString(),
      _appidParam: apiKey,
      _unitsParam: _metricUnits,
    });
    final http.Response response = await _httpClient.get(url);
    if (response.statusCode != 200) {
      throw Exception('OpenWeatherMap forecast error: ${response.statusCode}');
    }

    final Object? jsonBody = jsonDecode(response.body);
    if (jsonBody is! Map<String, Object?>) {
      throw Exception('Invalid OpenWeatherMap forecast response format');
    }
    final Object? listObj = jsonBody[_listKey];
    if (listObj is! List<Object?>) {
      throw Exception('Invalid OpenWeatherMap forecast list format');
    }

    final List<ForecastItemDomain> forecastItems = listObj.map((Object? item) {
      if (item is! Map<String, Object?>) {
        return const ForecastItemDomain(
          time: '',
          temperature: 0,
          weatherCode: 0,
        );
      }
      final String dtTxt = item[_dtTxtKey] is String
          ? item[_dtTxtKey] as String
          : '';
      final Object? mainObj = item[_mainKey];
      final double temp = switch (mainObj) {
        Map<String, Object?> mainMap when mainMap[_tempKey] is num =>
          (mainMap[_tempKey] as num).toDouble(),
        _ => 0.0,
      };
      final double? feelsLike = switch (mainObj) {
        Map<String, Object?> mainMap when mainMap[_feelsLikeKey] is num =>
          (mainMap[_feelsLikeKey] as num).toDouble(),
        _ => null,
      };
      final double? humidity = switch (mainObj) {
        Map<String, Object?> mainMap when mainMap[_humidityKey] is num =>
          (mainMap[_humidityKey] as num).toDouble(),
        _ => null,
      };
      final double? pressure = switch (mainObj) {
        Map<String, Object?> mainMap when mainMap[_pressureKey] is num =>
          (mainMap[_pressureKey] as num).toDouble(),
        _ => null,
      };

      final Object? windObj = item[_windKey];
      final double? windSpeed = switch (windObj) {
        Map<String, Object?> windMap when windMap[_speedKey] is num =>
          (windMap[_speedKey] as num).toDouble(),
        _ => null,
      };

      final double? visibility = item[_visibilityKey] is num
          ? (item[_visibilityKey] as num).toDouble()
          : null;

      final Object? cloudsObj = item[_cloudsKey];
      final double? cloudCover = switch (cloudsObj) {
        Map<String, Object?> cloudsMap when cloudsMap[_allKey] is num =>
          (cloudsMap[_allKey] as num).toDouble(),
        _ => null,
      };

      final Object? weatherListObj = item[_weatherKey];
      int rawCode = 0;
      if (weatherListObj is List<Object?> && weatherListObj.isNotEmpty) {
        final Object? firstWeather = weatherListObj.first;
        if (firstWeather is Map<String, Object?>) {
          if (firstWeather[_idKey] is int) {
            rawCode = firstWeather[_idKey] as int;
          } else if (firstWeather[_idKey] is num) {
            rawCode = (firstWeather[_idKey] as num).toInt();
          }
        }
      }

      return ForecastItemDomain(
        time: dtTxt,
        temperature: temp,
        weatherCode: _mapOwmToWmo(rawCode),
        feelsLike: feelsLike,
        humidity: humidity,
        pressure: pressure,
        windSpeed: windSpeed,
        visibility: visibility,
        cloudCover: cloudCover,
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
