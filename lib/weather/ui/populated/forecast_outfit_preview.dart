import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/outfit_image_source.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/outfit/outfit_image.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart';

class ForecastOutfitPreview extends StatefulWidget {
  const ForecastOutfitPreview({
    required this.item,
    required this.baseWeather,
    required this.isCelsius,
    super.key,
  });

  final ForecastItemDomain item;
  final Weather baseWeather;
  final bool isCelsius;

  @override
  State<ForecastOutfitPreview> createState() => _ForecastOutfitPreviewState();
}

WeatherCondition _toCondition(int code) {
  switch (code) {
    case 0:
      return WeatherCondition.clear;
    case 1:
    case 2:
    case 3:
    case 45:
    case 48:
      return WeatherCondition.cloudy;
    case 51:
    case 53:
    case 55:
    case 56:
    case 57:
    case 61:
    case 63:
    case 65:
    case 66:
    case 67:
    case 80:
    case 81:
    case 82:
    case 95:
    case 96:
    case 99:
      return WeatherCondition.rainy;
    case 71:
    case 73:
    case 75:
    case 77:
    case 85:
    case 86:
      return WeatherCondition.snowy;
    default:
      return WeatherCondition.unknown;
  }
}

class _ForecastOutfitPreviewState extends State<ForecastOutfitPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Future<OutfitImage>? _imageFuture;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _imageFuture = _loadImage();
    _controller.forward();
  }

  Future<OutfitImage> _loadImage() async {
    final OutfitRepository outfitRepository =
        RepositoryProvider.of<OutfitRepository>(context);

    // Build a Weather model for the forecast item reusing baseWeather for
    // location / locale / countryCode to avoid duplicating logic.

    final Weather forecastWeather = Weather(
      condition: _toCondition(widget.item.weatherCode),
      lastUpdatedDateTime: null,
      location: widget.baseWeather.location,
      temperature: Temperature(value: widget.item.temperature),
      temperatureUnits: widget.isCelsius
          ? TemperatureUnits.celsius
          : TemperatureUnits.fahrenheit,
      countryCode: widget.baseWeather.countryCode,
      description: widget.baseWeather.description,
      code: widget.item.weatherCode,
      locale: widget.baseWeather.locale,
    );

    return outfitRepository.getOutfitImage(forecastWeather);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: FutureBuilder<OutfitImage>(
          future: _imageFuture,
          builder: (BuildContext context, AsyncSnapshot<OutfitImage> snapshot) {
            Widget content;
            if (snapshot.connectionState == ConnectionState.waiting) {
              content = const SizedBox(
                width: 120,
                height: 120,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            } else if (snapshot.hasError ||
                snapshot.data == null ||
                snapshot.data!.isEmpty) {
              content = const SizedBox(
                width: 120,
                height: 120,
                child: Center(child: Icon(Icons.error_outline)),
              );
            } else {
              final OutfitImage outfit = snapshot.data!;
              if (outfit.source == OutfitImageSource.asset) {
                content = Image.asset(
                  outfit.path,
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                );
              } else if (outfit.source == OutfitImageSource.network) {
                content = Image.network(
                  outfit.path,
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                );
              } else {
                // file
                if (!kIsWeb) {
                  content = Image.file(
                    File(outfit.path),
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  );
                } else {
                  content = Image.network(
                    outfit.path,
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  );
                }
              }
            }

            return Card(
              clipBehavior: Clip.antiAlias,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  clipBehavior: Clip.antiAlias,
                  child: content,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
