import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home_widget/home_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_fit/entities/enums/weather_status.dart';
import 'package:weather_fit/entities/weather.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/theme/cubit/theme_cubit.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/weather/cubit/weather_cubit.dart';
import 'package:weather_fit/weather/ui/outfit_widget.dart';
import 'package:weather_fit/weather/ui/weather.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  int _oldestTimestamp = 0;
  final int _tenSeconds = 10;
  late int _defaultDelay;

  @override
  void initState() {
    super.initState();
    _defaultDelay = Duration(seconds: _tenSeconds).inMilliseconds;
    Permission.location.request().then((PermissionStatus status) {
// Check if permission is granted
      if (status.isGranted) {
        // Get the current position of the device.
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
            .then((Position position) async {
          double latitude = position.latitude;
          double longitude = position.longitude;
          if (!kIsWeb) {
            // Geocode the coordinates and get a `Placemark` object.
            try {
              placemarkFromCoordinates(latitude, longitude)
                  .then((List<Placemark> placemarks) {
                if (placemarks.isNotEmpty &&
                    placemarks.first.locality != null) {
                  // Assign the city name to the variable.
                  String city = placemarks.first.locality!;
                  context.read<WeatherCubit>().fetchWeather(city);
                }
              });
            } catch (err, stacktrace) {
              debugPrint(
                'Warning: got an error: $err in $runtimeType\nStacktrace: '
                '$stacktrace',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $err. Cannot get current location.'),
                ),
              );
            }
          }
        });
      } else {
        // Permission is denied, handle accordingly
        // Show a snackbar with a message and a button.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Location permission is required for this app.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        context.read<WeatherCubit>().refreshWeather();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoute.settings.path,
            ),
          ),
        ],
      ),
      body: Center(
        child: BlocConsumer<WeatherCubit, WeatherState>(
          listener: (BuildContext context, WeatherState state) {
            if (state.status.isSuccess) {
              context.read<ThemeCubit>().updateTheme(state.weather);
            }
          },
          builder: (BuildContext context, WeatherState state) {
            switch (state.status) {
              case WeatherStatus.initial:
                return const WeatherEmpty();
              case WeatherStatus.loading:
                if (state.weather.location.isEmpty) {
                  return const WeatherLoading();
                } else {
                  return WeatherPopulated(
                    weather: state.weather,
                    child: const WeatherLoading(),
                    onRefresh: () =>
                        context.read<WeatherCubit>().refreshWeather(),
                  );
                }
              case WeatherStatus.success:
                Widget outfitImageWidget = const SizedBox();
                if (state.outfitImageUrl.isNotEmpty) {
                  outfitImageWidget = OutfitWidget(
                    url: state.outfitImageUrl,
                    onLoaded: () => _updateWeatherHomeWidget(
                      weather: state.weather,
                      outfitImageWidget: outfitImageWidget,
                    ),
                  );
                }
                return WeatherPopulated(
                  weather: state.weather,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: kIsWeb ? Colors.black54 : Colors.transparent,
                          blurRadius: 10,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                    child: outfitImageWidget,
                  ),
                  onRefresh: () =>
                      context.read<WeatherCubit>().refreshWeather(),
                );
              case WeatherStatus.failure:
                return WeatherError(state.message);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search, semanticLabel: 'Search'),
        onPressed: () async {
          final String? city = await Navigator.pushNamed<dynamic>(
            context,
            AppRoute.search.path,
          );

          if (context.mounted && city is String) {
            await context.read<WeatherCubit>().fetchWeather(city);
          } else {
            return;
          }
        },
      ),
    );
  }

  Future<void> _updateWeatherHomeWidget({
    required Weather weather,
    required Widget outfitImageWidget,
  }) async {
    if (_shouldUpdate) {
      // Set the group ID
      HomeWidget.setAppGroupId(constants.appGroupId);

      // Save the weather widget data to the widget
      HomeWidget.saveWidgetData<String>('text_emoji', weather.emoji);

      HomeWidget.saveWidgetData<String>('text_location', weather.location);

      HomeWidget.saveWidgetData<String>(
        'text_temperature',
        weather.formattedTemperature,
      );

      HomeWidget.saveWidgetData<String>(
        'text_last_updated',
        '''Last Updated at ${TimeOfDay.fromDateTime(weather.lastUpdated).format(context)}''',
      );

      dynamic imagePath = await HomeWidget.renderFlutterWidget(
        outfitImageWidget,
        key: 'image_weather',
        logicalSize: const Size(400, 400),
      );

      // Save the image path if it exists
      if (imagePath is String && imagePath.isNotEmpty) {
        HomeWidget.saveWidgetData<String>('image_weather', imagePath);
      }

      // Update the widget
      HomeWidget.updateWidget(
        iOSName: constants.iOSWidgetName,
        androidName: constants.androidWidgetName,
      );
    }
  }

  bool get _shouldUpdate {
    if (kIsWeb) return false;
    bool needsRefresh = _needsRefresh;
    if (needsRefresh) {
      _oldestTimestamp = DateTime.now().millisecondsSinceEpoch;
    }
    return needsRefresh;
  }

  bool get _needsRefresh {
    bool needsRefresh = _oldestTimestamp <
        DateTime.now().millisecondsSinceEpoch - _defaultDelay;
    return needsRefresh;
  }
}
