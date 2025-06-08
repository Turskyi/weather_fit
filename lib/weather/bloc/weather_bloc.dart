import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart' as http;
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_repository/weather_repository.dart';

part 'weather_bloc.g.dart';
part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends HydratedBloc<WeatherEvent, WeatherState> {
  WeatherBloc(this._weatherRepository, this._outfitRepository)
      : super(const WeatherInitial()) {
    on<FetchWeather>(_onFetchWeather);
    on<RefreshWeather>(_onRefreshWeather);
    on<ToggleUnits>(_onToggleUnits);
    on<UpdateWeatherOnMobileHomeScreenEvent>(_updateWeatherOnMobileHomeScreen);
    on<GetOutfitEvent>(_onOutfitRecommendationRequested);
  }

  final WeatherRepository _weatherRepository;
  final OutfitRepository _outfitRepository;

  @override
  WeatherSuccess fromJson(Map<String, Object?> json) {
    return WeatherSuccess.fromJson(json);
  }

  @override
  Map<String, Object?> toJson(Object? state) {
    if (state is WeatherSuccess) {
      return state.toJson();
    } else {
      return <String, Object?>{};
    }
  }

  FutureOr<void> _onFetchWeather(
    FetchWeather event,
    Emitter<WeatherState> emit,
  ) async {
    final String eventLocation = event.location;

    if (eventLocation.isEmpty) {
      emit(const WeatherInitial());
      return;
    }

    emit(const WeatherLoadingState());
    try {
      final WeatherDomain domainWeather = await _weatherRepository.getWeather(
        eventLocation,
      );

      final Weather weather = Weather.fromRepository(domainWeather);

      final TemperatureUnits units = state.temperatureUnits;

      final double value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      final Weather updatedWeather = weather.copyWith(
        temperature: Temperature(value: value),
        temperatureUnits: units,
      );

      final String outfitRecommendation = _getOutfitRecommendation(
        updatedWeather,
      );

      emit(
        LoadingOutfitState(
          weather: updatedWeather,
          outfitRecommendation: outfitRecommendation,
        ),
      );

      if (state is WeatherSuccess) {
        final String assetPath = _outfitRepository.getOutfitImageAssetPath(
          weather,
        );

        emit(
          (state as WeatherSuccess).copyWith(outfitAssetPath: assetPath),
        );

        // Only add the event if it's NOT web AND NOT macOS.
        // For context, see issue:
        // https://github.com/ABausG/home_widget/issues/137.
        if (!kIsWeb && !Platform.isMacOS) {
          add(const UpdateWeatherOnMobileHomeScreenEvent());
        }
      } else {
        emit(
          WeatherSuccess(
            weather: updatedWeather,
            outfitRecommendation: outfitRecommendation,
          ),
        );
      }
    } on Exception catch (e) {
      if (e is http.ClientException && kDebugMode && kIsWeb) {
        emit(
          LocalWebCorsFailure(
            message: 'Error: Local Environment Setup Required\nTo run this '
                'application locally on web, please use the following '
                'command:\n\nflutter run -d chrome --web-browser-flag '
                '"--disable-web-security"\n\nThis step is necessary to '
                'bypass CORS restrictions during local development. '
                'Please note that this flag should only be used in a '
                'development environment and never in production.',
            outfitRecommendation: state.outfitRecommendation,
          ),
        );
      } else {
        emit(
          WeatherFailure(
            message: '$e',
            outfitRecommendation: state.outfitRecommendation,
          ),
        );
      }
    }
  }

  FutureOr<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    if (state is! WeatherSuccess) {
      emit(
        WeatherInitial(
          weather: state.weather,
          outfitRecommendation: state.outfitRecommendation,
          outfitAssetPath: state.outfitAssetPath,
        ),
      );
      return;
    }

    if (state.weather.isUnknown) {
      emit(const WeatherInitial());
      return;
    }

    emit(
      WeatherLoadingState(
        weather: state.weather,
        outfitRecommendation: state.outfitRecommendation,
        outfitAssetPath: state.outfitAssetPath,
      ),
    );

    try {
      final WeatherDomain updatedWeather = state.locationCity.isEmpty
          ? await _weatherRepository.getWeatherByLocation(state.location)
          : await _weatherRepository.getWeather(state.locationCity);

      final Weather weather = Weather.fromRepository(updatedWeather);

      final TemperatureUnits units = state.weather.temperatureUnits;

      final double value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      final String outfitRecommendation = _getOutfitRecommendation(weather);

      emit(
        LoadingOutfitState(
          weather: weather.copyWith(
            temperature: Temperature(value: value),
            temperatureUnits: units,
          ),
          outfitRecommendation: outfitRecommendation,
          outfitAssetPath: _outfitRepository.getOutfitImageAssetPath(weather),
        ),
      );

      if (state is WeatherSuccess) {
        final String filePath = _outfitRepository.getOutfitImageAssetPath(
          weather,
        );

        emit(
          (state as WeatherSuccess).copyWith(outfitAssetPath: filePath),
        );

        // Only add the event if it's NOT web AND NOT macOS.
        // For context, see issue:
        // https://github.com/ABausG/home_widget/issues/137.
        if (!kIsWeb && !Platform.isMacOS) {
          add(const UpdateWeatherOnMobileHomeScreenEvent());
        }
      }
    } on Exception catch (e) {
      emit(
        WeatherFailure(
          message: '$e',
          outfitRecommendation: state.outfitRecommendation,
          outfitAssetPath: state.outfitAssetPath,
        ),
      );
    }
  }

  void _onToggleUnits(ToggleUnits _, Emitter<WeatherState> emit) {
    final TemperatureUnits units = state.weather.temperatureUnits.isFahrenheit
        ? TemperatureUnits.celsius
        : TemperatureUnits.fahrenheit;
    final Weather weather = state.weather;
    final Temperature temperature = weather.temperature;
    final double value = units.isCelsius
        ? temperature.value.toCelsius()
        : temperature.value.toFahrenheit();

    if (state is WeatherSuccess) {
      emit(
        (state as WeatherSuccess).copyWith(
          weather: weather.copyWith(
            temperature: Temperature(value: value),
            temperatureUnits: units,
          ),
        ),
      );
    } else if (state is WeatherInitial) {
      emit(
        (state as WeatherInitial).copyWith(
          weather: weather.copyWith(
            temperature: Temperature(value: value),
            temperatureUnits: units,
          ),
        ),
      );
    }
  }

  Future<Directory> _getAppDirectory() async {
    if (!kIsWeb & Platform.isIOS) {
      const MethodChannel channel = MethodChannel(
        'weatherfit.shared/container',
      );
      final String path = await channel.invokeMethod(
        'getAppleAppGroupDirectory',
      );

      return Directory(path);
    } else {
      // On Android or other platforms, fallback to Documents directory.
      return getApplicationDocumentsDirectory();
    }
  }

  Future<String> _downloadAndSaveImage(String assetPath) async {
    // Check if the platform is web OR macOS. If so, return early.
    // See issue: https://github.com/ABausG/home_widget/issues/137.
    if (kIsWeb || (!kIsWeb && Platform.isMacOS)) {
      return '';
    }
    try {
      // Load asset data as ByteData.
      final ByteData byteData = await rootBundle.load(assetPath);

      // Get the application documents directory.
      final Directory directory = await _getAppDirectory();
      final String filePath = '${directory.path}/outfit_image.png';
      // Write the bytes to the file.
      final File file = File(filePath);

      // Check if the file exists and delete it if it does.
      if (await file.exists()) {
        await file.delete();
      }

      // Ensure the directory exists.
      await directory.create(recursive: true);

      // Write the new image data.
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );

      // Invalidate the image cache.
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      return filePath;
    } catch (e) {
      // Handle potential errors (e.g., asset not found)
      debugPrint('Error saving asset image to file: $e');
      throw Exception('Failed to save asset image: $e');
    }
  }

  FutureOr<void> _updateWeatherOnMobileHomeScreen(
    UpdateWeatherOnMobileHomeScreenEvent event,
    Emitter<WeatherState> emit,
  ) async {
    // Check if the platform is web OR macOS. If so, return early.
    // See issue: https://github.com/ABausG/home_widget/issues/137.
    if (kIsWeb || (!kIsWeb && Platform.isMacOS)) {
      return;
    }

    try {
      // Set the group ID.
      HomeWidget.setAppGroupId(constants.appleAppGroupId);

      // Save weather data to the widget.
      HomeWidget.saveWidgetData<String>('text_emoji', state.emoji);

      HomeWidget.saveWidgetData<String>('text_location', state.locationName);

      HomeWidget.saveWidgetData<String>(
        'text_temperature',
        state.formattedTemperature,
      );

      HomeWidget.saveWidgetData<String>(
        'text_last_updated',
        'Last Updated on\n${state.formattedLastUpdatedDateTime}',
      );

      HomeWidget.saveWidgetData<String>(
        'text_recommendation',
        state.outfitRecommendation,
      );

      String assetPath = state.outfitAssetPath;
      if (assetPath.isEmpty) {
        final Weather weather = state.weather;
        if (weather.isNotEmpty) {
          assetPath = _outfitRepository.getOutfitImageAssetPath(weather);
        }
      }
      final String filePath = await _downloadAndSaveImage(assetPath);

      // Save the image path if it's valid.
      HomeWidget.saveWidgetData<String>('image_weather', filePath);

      // Update the widget.
      HomeWidget.updateWidget(
        iOSName: constants.iOSWidgetName,
        androidName: constants.androidWidgetName,
      );
    } catch (e) {
      debugPrint('Failed to update home screen widget: $e');
    }
  }

  String _getOutfitRecommendation(Weather weather) {
    final double temperature = weather.temperature.value;
    final WeatherCondition condition = weather.condition;
    final TemperatureUnits units = weather.temperatureUnits;

    if (condition.isRainy) {
      return '🌧️\nIt\'s rainy! Consider wearing a waterproof jacket and '
          'boots.';
    } else if (condition.isSnowy) {
      return '❄️\nIt\'s snowy! Dress warmly with a heavy coat, hat, gloves, '
          'and scarf.';
    } else if (temperature < 10 && units.isCelsius ||
        temperature < 50 && units.isFahrenheit) {
      return '🥶\nIt\'s cold! Wear a warm jacket, sweater, and consider a hat '
          'and gloves.';
    } else if (temperature >= 10 && temperature < 20 && units.isCelsius ||
        temperature >= 50 && temperature < 68 && units.isFahrenheit) {
      return '🧥\nIt\'s cool. A light jacket or sweater should be comfortable.';
    } else if (temperature >= 20 && temperature < 30 && units.isCelsius ||
        temperature >= 68 && temperature < 86 && units.isFahrenheit) {
      return '👕\nIt\'s warm. Shorts, t-shirts, and light dresses are great '
          'options.';
    } else if (temperature >= 30 && units.isCelsius ||
        temperature >= 86 && units.isFahrenheit) {
      return '☀️\nIt\'s hot! Wear light, breathable clothing like tank tops '
          'and shorts.';
    } else {
      return '🌤️\nThe weather is moderate. You can wear a variety of outfits.';
    }
  }

  FutureOr<void> _onOutfitRecommendationRequested(
    GetOutfitEvent event,
    Emitter<WeatherState> emit,
  ) async {
    final Weather weather = event.weather;

    if (weather.isEmpty) {
      emit(const WeatherInitial());
      return;
    }

    emit(const WeatherLoadingState());
    try {
      final TemperatureUnits units = state.temperatureUnits;

      final double value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      final Weather updatedWeather = weather.copyWith(
        temperature: Temperature(value: value),
        temperatureUnits: units,
      );

      final String outfitRecommendation = _getOutfitRecommendation(
        updatedWeather,
      );

      emit(
        LoadingOutfitState(
          weather: updatedWeather,
          outfitRecommendation: outfitRecommendation,
        ),
      );

      if (state is WeatherSuccess) {
        final String assetPath = _outfitRepository.getOutfitImageAssetPath(
          weather,
        );
        emit(
          (state as WeatherSuccess).copyWith(outfitAssetPath: assetPath),
        );
        // Only add the event if it's NOT web AND NOT macOS.
        // For context, see issue:
        // https://github.com/ABausG/home_widget/issues/137.
        if (!kIsWeb && !Platform.isMacOS) {
          add(const UpdateWeatherOnMobileHomeScreenEvent());
        }
      } else {
        emit(
          WeatherSuccess(
            weather: updatedWeather,
            outfitRecommendation: outfitRecommendation,
          ),
        );
      }
    } on Exception catch (e) {
      if (e is http.ClientException && kDebugMode && kIsWeb) {
        emit(
          LocalWebCorsFailure(
            message: 'Error: Local Environment Setup Required\nTo run this '
                'application locally on web, please use the following '
                'command:\n\nflutter run -d chrome --web-browser-flag '
                '"--disable-web-security"\n\nThis step is necessary to '
                'bypass CORS restrictions during local development. '
                'Please note that this flag should only be used in a '
                'development environment and never in production.',
            outfitRecommendation: state.outfitRecommendation,
          ),
        );
      } else {
        emit(
          WeatherFailure(
            message: '$e',
            outfitRecommendation: state.outfitRecommendation,
          ),
        );
      }
    }
  }
}

extension on double {
  double toFahrenheit() => (this * 9 / 5) + 32;

  double toCelsius() => (this - 32) * 5 / 9;
}
