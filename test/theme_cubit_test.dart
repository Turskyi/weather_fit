import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/theme/cubit/theme_cubit.dart';
import 'package:weather_repository/weather_repository.dart' hide WeatherDomain;

import 'helpers/hydrated_bloc.dart';
import 'helpers/mocks/mock_weather.dart';

void main() {
  initHydratedStorage();

  group('ThemeCubit', () {
    test('initial state is correct', () {
      expect(ThemeCubit().state, ThemeCubit.defaultColor);
    });

    group('toJson/fromJson', () {
      test('work properly', () {
        final ThemeCubit themeCubit = ThemeCubit();
        expect(
          themeCubit.fromJson(themeCubit.toJson(themeCubit.state)),
          themeCubit.state,
        );
      });
    });

    group('updateTheme', () {
      final MockWeather clearWeather = MockWeather(WeatherCondition.clear);
      final MockWeather snowyWeather = MockWeather(WeatherCondition.snowy);
      final MockWeather cloudyWeather = MockWeather(WeatherCondition.cloudy);
      final MockWeather rainyWeather = MockWeather(WeatherCondition.rainy);
      final MockWeather unknownWeather = MockWeather(WeatherCondition.unknown);

      blocTest<ThemeCubit, Color>(
        'emits correct color for WeatherCondition.clear',
        build: ThemeCubit.new,
        act: (ThemeCubit cubit) => cubit.updateTheme(clearWeather as Weather?),
        expect: () => <Color>[Colors.yellow],
      );

      blocTest<ThemeCubit, Color>(
        'emits correct color for WeatherCondition.snowy',
        build: ThemeCubit.new,
        act: (ThemeCubit cubit) => cubit.updateTheme(snowyWeather as Weather?),
        expect: () => <Color>[Colors.lightBlueAccent],
      );

      blocTest<ThemeCubit, Color>(
        'emits correct color for WeatherCondition.cloudy',
        build: ThemeCubit.new,
        act: (ThemeCubit cubit) => cubit.updateTheme(cloudyWeather as Weather?),
        expect: () => <Color>[Colors.blueGrey],
      );

      blocTest<ThemeCubit, Color>(
        'emits correct color for WeatherCondition.rainy',
        build: ThemeCubit.new,
        act: (ThemeCubit cubit) => cubit.updateTheme(rainyWeather as Weather?),
        expect: () => <Color>[Colors.indigoAccent],
      );

      blocTest<ThemeCubit, Color>(
        'emits correct color for WeatherCondition.unknown',
        build: ThemeCubit.new,
        act: (ThemeCubit cubit) =>
            cubit.updateTheme(unknownWeather as Weather?),
        expect: () => <Color>[ThemeCubit.defaultColor],
      );
    });
  });
}
