import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/outfit/outfit_image.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/weather/ui/widgets/outfit_image_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: FutureBuilder<OutfitImage>(
          future: _imageFuture,
          builder: (BuildContext context, AsyncSnapshot<OutfitImage> snapshot) {
            Widget? content;
            final OutfitImage? outfit = snapshot.data;
            if (snapshot.connectionState == ConnectionState.waiting) {
              content = const SizedBox(
                width: 140,
                height: 140,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            } else if (snapshot.hasError || outfit == null || outfit.isEmpty) {
              content = const SizedBox(
                width: 140,
                height: 140,
                child: Center(child: Icon(Icons.error_outline)),
              );
            } else {
              content = SizedBox(
                width: 140,
                height: 140,
                child: OutfitImageWidget(
                  outfitImage: outfit,
                  onRefresh: () async {},
                  fit: BoxFit.contain,
                ),
              );
            }

            return Card(
              clipBehavior: Clip.antiAlias,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: content,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<OutfitImage> _loadImage() async {
    final OutfitRepository outfitRepository =
        RepositoryProvider.of<OutfitRepository>(context);

    final Weather forecastWeather = Weather(
      condition: widget.item.toCondition(),
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
}
