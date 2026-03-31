import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:weather_fit/app/weather_fit_app.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;
import 'package:weather_fit/router/navigator.dart';
import 'package:weather_repository/weather_repository.dart';

class DeepLinkHandlerApp extends StatefulWidget {
  const DeepLinkHandlerApp({
    required this.weatherRepository,
    required this.locationRepository,
    required this.outfitRepository,
    required this.localDataSource,
    required this.initialLanguage,
    required this.routes,
    super.key,
  });

  final WeatherRepository weatherRepository;
  final LocationRepository locationRepository;
  final OutfitRepository outfitRepository;
  final LocalDataSource localDataSource;
  final Language initialLanguage;
  final Map<String, WidgetBuilder> routes;

  @override
  State<DeepLinkHandlerApp> createState() => _DeepLinkHandlerAppState();
}

class _DeepLinkHandlerAppState extends State<DeepLinkHandlerApp> {
  StreamSubscription<Uri?>? _sub;

  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  @override
  Widget build(BuildContext context) {
    return WeatherFitApp(
      weatherRepository: widget.weatherRepository,
      locationRepository: widget.locationRepository,
      outfitRepository: widget.outfitRepository,
      localDataSource: widget.localDataSource,
      initialLanguage: widget.initialLanguage,
      routes: widget.routes,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _initUniLinks() async {
    // Listen for incoming links
    _sub = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null &&
            uri.scheme == constants.kWeatherFitScheme &&
            uri.host == constants.kWeatherFitHost) {
          // Always reset navigation stack to weather page
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            constants.kWeatherRoute,
            (Route<Object?> route) => false,
          );
        }
      },
      onError: (Object err) {
        debugPrint('Deep link error: $err');
      },
    );

    // Handle initial link if app was started from widget
    try {
      final Uri? initialUri = await getInitialUri();
      if (initialUri != null &&
          initialUri.scheme == constants.kWeatherFitScheme &&
          initialUri.host == constants.kWeatherFitHost) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            constants.kWeatherRoute,
            (Route<Object?> route) => false,
          );
        });
      }
      // Dart's catch syntax does not allow a type annotation here (e.g., 'catch
      // (Object error)'), so we must use 'catch (error)' without a type.
    } catch (error) {
      debugPrint('Error handling initial deep link: $error');
    }
  }
}
