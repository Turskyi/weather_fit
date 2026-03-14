import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/theme/cubit/theme_cubit.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/page/weather_page_default_layout.dart';
import 'package:weather_fit/weather/ui/page/weather_page_extra_small_layout.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> with WidgetsBindingObserver {
  late PageController _pageController;
  List<Location> _locations = <Location>[];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
    // Initialize locations list immediately so PageView has items on first
    // build.
    // We use context.read here; this is safe in `initState` as long as
    // providers are ancestors.
    _locations = _getSwipeList(context.read<LocalDataSource>());

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) {
        context.read<WeatherBloc>().add(RefreshWeather(context.origin));
      }
    });
  }

  List<Location> _getSwipeList(LocalDataSource localDataSource) {
    final Location activeLocation = localDataSource.getLastSavedLocation();
    final List<Location> favourites = localDataSource.getFavouriteLocations();

    final List<Location> newList = <Location>[];
    if (activeLocation.isNotEmpty) {
      newList.add(activeLocation);
    }

    for (final Location fav in favourites) {
      final bool alreadyExists = newList.any(
        (Location l) =>
            l.latitude == fav.latitude && l.longitude == fav.longitude,
      );
      if (!alreadyExists) {
        newList.add(fav);
      }
    }

    if (newList.isEmpty) {
      newList.add(const Location.empty());
    }
    return newList;
  }

  void _updateLocations({bool resetToFirst = false}) {
    final List<Location> newList = _getSwipeList(
      context.read<LocalDataSource>(),
    );

    final bool setChanged =
        newList.length != _locations.length ||
        !newList.every(
          (Location nl) => _locations.any(
            (Location l) =>
                l.latitude == nl.latitude && l.longitude == nl.longitude,
          ),
        );

    if (setChanged || resetToFirst) {
      setState(() {
        _locations = newList;
      });
      if (resetToFirst && _pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check if the date has changed while the app was in the background.
      // Only reload if we've transitioned to a new day.
      context.read<WeatherBloc>().add(CheckDateChangeOnResume(context.origin));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isExtraSmall = context.isExtraSmallScreen;
    final Widget pageView = PageView.builder(
      controller: _pageController,
      itemCount: _locations.length,
      onPageChanged: (int index) {
        final Location location = _locations[index];
        if (location.isNotEmpty) {
          context.read<LocalDataSource>().saveLocation(location);
          context.read<WeatherBloc>().add(
            FetchWeather(location: location, origin: context.origin),
          );
        }
      },
      itemBuilder: (BuildContext context, int index) {
        final Location location = _locations[index];
        if (isExtraSmall) {
          return WeatherPageExtraSmallLayout(
            onSettingsPressed: _navigateToSettingsAndRefreshOutfit,
            onRefresh: _refresh,
            onSearchPressed: _handleLocationSearchAndFetchWeather,
            onReportPressed: _handleReportPressed,
            isEmbedded: true,
            location: location,
          );
        } else {
          return WeatherPageDefaultLayout(
            onSettingsPressed: _navigateToSettingsAndRefreshOutfit,
            onRefresh: _refresh,
            onSearchPressed: _handleLocationSearchAndFetchWeather,
            onReportPressed: _handleReportPressed,
            isEmbedded: true,
            location: location,
          );
        }
      },
    );

    return BlocListener<WeatherBloc, WeatherState>(
      listener: (BuildContext context, WeatherState state) {
        _weatherBlocStateListener(context, state);
        if (state is WeatherSuccess || state is WeatherInitial) {
          _updateLocations();
        }
      },
      child: isExtraSmall
          ? WeatherPageExtraSmallLayout(
              onSettingsPressed: _navigateToSettingsAndRefreshOutfit,
              onRefresh: _refresh,
              onSearchPressed: _handleLocationSearchAndFetchWeather,
              onReportPressed: _handleReportPressed,
              bodyOverride: pageView,
            )
          : WeatherPageDefaultLayout(
              onSettingsPressed: _navigateToSettingsAndRefreshOutfit,
              onRefresh: _refresh,
              onSearchPressed: _handleLocationSearchAndFetchWeather,
              onReportPressed: _handleReportPressed,
              bodyOverride: pageView,
            ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
        FetchDailyForecast(location: weather.location),
      );

      context.read<WeatherBloc>().add(
        GetOutfitEvent(weather: weather, origin: context.origin),
      );
      _updateLocations(resetToFirst: true);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: SelectableText(stateMessage),
            action: SnackBarAction(
              label: translate('ok'),
              onPressed: ScaffoldMessenger.of(context).hideCurrentSnackBar,
            ),
          ),
        );
      }
    } else if (state is WeatherFailure || state is LocalWebCorsFailure) {
      if (state.weather.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 4),
              content: Row(
                children: <Widget>[
                  Expanded(child: SelectableText(state.message)),
                  TextButton(
                    onPressed: ScaffoldMessenger.of(
                      context,
                    ).hideCurrentSnackBar,
                    child: Text(translate('ok')),
                  ),
                ],
              ),
              action: SnackBarAction(
                label: translate('try_again'),
                onPressed: _refresh,
              ),
            ),
          );
      }
    }
  }
}
