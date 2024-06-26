import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';
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
  late int _defaultWeatherRefreshDelay;

  @override
  void initState() {
    super.initState();
    _defaultWeatherRefreshDelay = Duration(seconds: _tenSeconds).inMilliseconds;
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
        onPressed: _handleCitySelectionAndFetchWeather,
        child: const Icon(Icons.search, semanticLabel: 'Search'),
      ),
    );
  }

  Future<void> _handleCitySelectionAndFetchWeather() async {
    final String? city = await Navigator.pushNamed<dynamic>(
      context,
      AppRoute.search.path,
    );

    if (mounted && city is String) {
      await context.read<WeatherCubit>().fetchWeather(city);
    } else if (mounted) {
      context.read<WeatherCubit>().refreshWeather();
    } else {
      return;
    }
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
        DateTime.now().millisecondsSinceEpoch - _defaultWeatherRefreshDelay;
    return needsRefresh;
  }
}
