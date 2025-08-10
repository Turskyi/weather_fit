import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/theme/cubit/theme_cubit.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/weather_page_default_layout.dart';
import 'package:weather_fit/weather/ui/weather_page_extra_small_layout.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({required this.languageIsoCode, super.key});

  final String languageIsoCode;

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<WeatherBloc>().add(RefreshWeather(context.origin));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (context.isExtraSmallScreen) {
      return WeatherPageExtraSmallLayout(
        onSettingsPressed: _navigateToSettingsAndRefreshOutfit,
        weatherStateListener: _weatherBlocStateListener,
        onRefresh: _refresh,
        onSearchPressed: _handleLocationSearchAndFetchWeather,
        onReportPressed: _handleReportPressed,
      );
    } else {
      return WeatherPageDefaultLayout(
        onSettingsPressed: _navigateToSettingsAndRefreshOutfit,
        weatherStateListener: _weatherBlocStateListener,
        onRefresh: _refresh,
        onSearchPressed: _handleLocationSearchAndFetchWeather,
        onReportPressed: _handleReportPressed,
      );
    }
  }

  void _handleReportPressed() {
    final WeatherState state = context.read<WeatherBloc>().state;
    context.read<SettingsBloc>().add(
      BugReportPressedEvent(state is WeatherFailure ? state.message : ''),
    );
  }

  void _navigateToSettingsAndRefreshOutfit() {
    Navigator.pushNamed(context, AppRoute.settings.path).whenComplete(() {
      if (mounted) {
        final WeatherBloc weatherBloc = context.read<WeatherBloc>();
        weatherBloc.add(
          GetOutfitEvent(
            weather: weatherBloc.state.weather,
            origin: context.origin,
          ),
        );
      }
    });
  }

  Future<void> _handleLocationSearchAndFetchWeather() async {
    final Object? weather = await Navigator.pushNamed<Object>(
      context,
      AppRoute.search.path,
    );

    if (mounted && weather is Weather) {
      context.read<WeatherBloc>().add(
        GetOutfitEvent(weather: weather, origin: context.origin),
      );
    } else {
      return;
    }
  }

  Future<void> _refresh() {
    return Future<void>.delayed(Duration.zero, () {
      if (mounted) {
        context.read<WeatherBloc>().add(RefreshWeather(context.origin));
      }
    });
  }

  void _weatherBlocStateListener(BuildContext context, WeatherState state) {
    if (state is WeatherSuccess) {
      context.read<ThemeCubit>().updateTheme(state.weather);
      final String stateMessage = state.message;
      if (stateMessage.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(stateMessage)));
      }
    }
  }
}
