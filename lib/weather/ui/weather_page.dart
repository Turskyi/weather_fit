import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:weather_fit/entities/weather.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/theme/cubit/theme_cubit.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
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
        child: BlocConsumer<WeatherBloc, WeatherState>(
          listener: (BuildContext context, WeatherState state) {
            if (state is WeatherSuccess) {
              context.read<ThemeCubit>().updateTheme(state.weather);
            }
          },
          builder: (BuildContext context, WeatherState state) {
            switch (state) {
              case WeatherInitial():
                return const WeatherEmpty();
              case WeatherLoadingState():
                if (state.weather.city.isEmpty) {
                  return const WeatherLoadingWidget();
                } else {
                  return WeatherPopulated(
                    weather: state.weather,
                    onRefresh: _refresh,
                    child: const WeatherLoadingWidget(),
                  );
                }
              case WeatherSuccess():
                if (state.weather.isUnknown) {
                  return const WeatherEmpty();
                }
                Widget outfitImageWidget = const SizedBox();
                if (state.outfitImageUrl.isNotEmpty) {
                  outfitImageWidget = OutfitWidget(
                    imageUrl: state.outfitImageUrl,
                    onLoaded: () => _updateWeatherOnHomeScreen(
                      weather: state.weather,
                      outfitImageWidget: outfitImageWidget,
                    ),
                  );
                }
                return WeatherPopulated(
                  weather: state.weather,
                  onRefresh: _refresh,
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
                );
              case WeatherFailure():
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
      context.read<WeatherBloc>().add(FetchWeather(city: city));
    } else {
      return;
    }
  }

  Future<void> _updateWeatherOnHomeScreen({
    required Weather weather,
    required Widget outfitImageWidget,
  }) async {
    if (_shouldUpdate) {
      // Set the group ID.
      HomeWidget.setAppGroupId(constants.appGroupId);

      // Save the weather widget data to the widget
      HomeWidget.saveWidgetData<String>('text_emoji', weather.emoji);

      HomeWidget.saveWidgetData<String>('text_location', weather.city);

      HomeWidget.saveWidgetData<String>(
        'text_temperature',
        weather.formattedTemperature,
      );

      HomeWidget.saveWidgetData<String>(
        'text_last_updated',
        'Last Updated on ${_formatDateTime(weather.lastUpdated)}',
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

  Future<void> _refresh() => Future<void>.delayed(
        Duration.zero,
        () => context.read<WeatherBloc>().add(const RefreshWeather()),
      );

  /// Output: e.g., "Dec 12, Monday at 03:45 PM"
  String _formatDateTime(DateTime? lastUpdated) {
    if (lastUpdated != null) {
      final DateFormat formatter = DateFormat('MMM dd, EEEE \'at\' hh:mm a');
      return formatter.format(lastUpdated);
    } else {
      return 'Never updated';
    }
  }
}
