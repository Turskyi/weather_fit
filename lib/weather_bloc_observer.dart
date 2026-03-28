import 'dart:developer';

import 'package:bloc/bloc.dart';

class WeatherBlocObserver extends BlocObserver {
  const WeatherBlocObserver();

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    log('onEvent ${bloc.runtimeType}: ${_summarize(event)}');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log(
      'onChange ${bloc.runtimeType}: '
      '${_summarize(change.currentState)} -> ${_summarize(change.nextState)}',
    );
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    log(
      'onTransition ${bloc.runtimeType}: '
      '${_summarize(transition.currentState)} '
      '--${_summarize(transition.event)}--> '
      '${_summarize(transition.nextState)}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    log('onError ${bloc.runtimeType}: $error');
  }

  String _summarize(Object? object) {
    if (object == null) return 'null';

    final String type = object.runtimeType.toString();
    final List<String> details = <String>[];

    final String? location = _extractLocation(object);
    if (location != null && location.isNotEmpty) {
      details.add('location=$location');
    }

    final String? origin = _extractStringField(object, 'origin');
    if (origin != null && origin.isNotEmpty) {
      details.add('origin=$origin');
    }

    final String? message = _extractStringField(object, 'message');
    if (message != null && message.isNotEmpty) {
      details.add('message=$message');
    }

    final bool? isFavourite = _extractBoolField(object, 'isFavourite');
    if (isFavourite != null) {
      details.add('isFavourite=$isFavourite');
    }

    final int? forecastCount = _extractForecastCount(object);
    if (forecastCount != null) {
      details.add('forecastCount=$forecastCount');
    }

    if (details.isEmpty) {
      return type;
    }

    return '$type(${details.join(', ')})';
  }

  String? _extractLocation(Object object) {
    final dynamic dynamicObject = object;

    try {
      final dynamic location = dynamicObject.location;
      final String? formattedLocation = _formatLocation(location);
      if (formattedLocation != null && formattedLocation.isNotEmpty) {
        return formattedLocation;
      }
    } catch (_) {}

    try {
      final dynamic weather = dynamicObject.weather;
      final dynamic weatherLocation = weather.location;
      return _formatLocation(weatherLocation);
    } catch (_) {
      return null;
    }
  }

  String? _formatLocation(dynamic location) {
    if (location == null) return null;

    try {
      final String name = (location.name as String?)?.trim() ?? '';
      final String countryCode =
          (location.countryCode as String?)?.trim() ?? '';

      if (name.isEmpty) {
        return null;
      }

      return countryCode.isEmpty ? name : '$name/$countryCode';
    } catch (_) {
      return null;
    }
  }

  String? _extractStringField(Object object, String fieldName) {
    final dynamic dynamicObject = object;
    try {
      final dynamic value = switch (fieldName) {
        'origin' => dynamicObject.origin,
        'message' => dynamicObject.message,
        _ => null,
      };

      if (value == null) return null;
      return value.toString();
    } catch (_) {
      return null;
    }
  }

  bool? _extractBoolField(Object object, String fieldName) {
    final dynamic dynamicObject = object;
    try {
      final dynamic value = switch (fieldName) {
        'isFavourite' => dynamicObject.isFavourite,
        _ => null,
      };

      if (value is bool) {
        return value;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  int? _extractForecastCount(Object object) {
    final dynamic dynamicObject = object;
    try {
      final dynamic dailyForecast = dynamicObject.dailyForecast;
      if (dailyForecast == null) return null;

      final dynamic forecast = dailyForecast.forecast;
      if (forecast is List<dynamic>) {
        return forecast.length;
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
