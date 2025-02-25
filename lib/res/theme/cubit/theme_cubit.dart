import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/extensions/color_extensions.dart';
import 'package:weather_repository/weather_repository.dart';

class ThemeCubit extends HydratedCubit<Color> {
  ThemeCubit() : super(defaultColor);

  static const Color defaultColor = Color(0xFF2196F3);

  void updateTheme(Weather? weather) {
    if (weather != null) emit(weather.toColor);
  }

  @override
  Color fromJson(Map<String, dynamic> json) {
    final Object? colorJsonValue = json[_jsonColorKey];
    if (colorJsonValue is String) {
      final String colorString = colorJsonValue;
      // Check if the string is in the correct format.
      if (colorString.startsWith('#') &&
          (colorString.length == 7 || colorString.length == 9)) {
        // Remove the '#'
        final String hexColor = colorString.substring(1);
        // Parse as hex.
        final int? intColor = int.tryParse(hexColor, radix: 16);
        if (intColor != null) {
          return Color(intColor);
        } else {
          // Handle the case where the hex string is invalid.
          return ThemeCubit.defaultColor;
        }
      } else {
        // Handle the case where the string is not in the correct format.
        return ThemeCubit.defaultColor;
      }
    } else {
      // Handle the case where 'color' is not a string.
      return ThemeCubit.defaultColor;
    }
  }

  @override
  Map<String, dynamic> toJson(Color state) {
    return <String, String>{
      _jsonColorKey: '#${state.intAlpha.toRadixString(16).padLeft(2, '0')}'
          '${state.intRed.toRadixString(16).padLeft(2, '0')}'
          '${state.intGreen.toRadixString(16).padLeft(2, '0')}'
          '${state.intBlue.toRadixString(16).padLeft(2, '0')}',
    };
  }
}

extension on Weather {
  Color get toColor {
    switch (condition) {
      case WeatherCondition.clear:
        return Colors.yellow;
      case WeatherCondition.snowy:
        return Colors.lightBlueAccent;
      case WeatherCondition.cloudy:
        return Colors.blueGrey;
      case WeatherCondition.rainy:
        return Colors.indigoAccent;
      case WeatherCondition.unknown:
        return ThemeCubit.defaultColor;
    }
  }
}

const String _jsonColorKey = 'color';
