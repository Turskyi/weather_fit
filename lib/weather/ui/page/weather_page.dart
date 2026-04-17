import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;
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
  int _currentPageIndex = 0;
  AppLifecycleState? _lastLifecycleState;
  DateTime? _lastResumeCheckAt;
  DateTime? _lastLocationResyncAt;
  DateTime? _lastStateSnapshotLogAt;

  static const Duration _resumeCheckDebounce = Duration(seconds: 4);
  static const Duration _locationResyncDebounce = Duration(seconds: 2);
  static const Duration _stateSnapshotLogDebounce = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
    // Initialize locations list immediately so `PageView` has items on first
    // build.
    final LocalDataSource dataSource = context.read<LocalDataSource>();
    _locations = _getSwipeList(dataSource);

    // Find and set the current index to the active location
    final Location activeLocation = dataSource.getLastSavedLocation();
    if (activeLocation.isNotEmpty) {
      _currentPageIndex = _locations.indexWhere(
        (Location l) => _isSameLocation(l, activeLocation),
      );
      if (_currentPageIndex < 0) {
        _currentPageIndex = 0;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) {
        // Jump to the active location's index if not already there
        if (_pageController.hasClients &&
            _currentPageIndex > 0 &&
            _currentPageIndex < _locations.length) {
          _pageController.jumpToPage(_currentPageIndex);
        }
        _fetchWeatherForCurrentPageLocation();
      }
    });
  }

  List<Location> _getSwipeList(LocalDataSource localDataSource) {
    final Location lastSearched = localDataSource.getLastSearchedLocation();
    final List<Location> favourites = localDataSource.getFavouriteLocations();

    final List<Location> newList = <Location>[];

    // 1. Last searched if not a favorite.
    if (lastSearched.isNotEmpty) {
      final bool isFavourite = favourites.any(
        (Location l) => _isSameLocation(l, lastSearched),
      );
      if (!isFavourite) {
        newList.add(lastSearched);
      }
    }

    // 2. Favourites in stable order.
    newList.addAll(favourites);

    if (newList.isEmpty) {
      newList.add(const Location.empty());
    }
    return newList;
  }

  bool _isSameLocation(Location l1, Location l2) {
    return l1.isSamePlaceAs(l2);
  }

  void _updateLocations({bool resetToFirst = false}) {
    final LocalDataSource localDataSource = context.read<LocalDataSource>();
    final Location activeLocation = localDataSource.getLastSavedLocation();
    final List<Location> previousLocations = _locations;
    final int previousIndex = _getCurrentVisibleIndex();

    final Location previousVisibleLocation;
    if (previousLocations.isEmpty) {
      previousVisibleLocation = const Location.empty();
    } else {
      final int safePreviousIndex = previousIndex.clamp(
        0,
        previousLocations.length - 1,
      );
      previousVisibleLocation = previousLocations[safePreviousIndex];
    }

    final List<Location> newList = _getSwipeList(localDataSource);

    final bool lengthChanged = newList.length != _locations.length;
    final bool contentChanged = !_areLocationListsSame(
      previousLocations,
      newList,
    );
    final bool shouldUpdateList = contentChanged || resetToFirst;

    if (shouldUpdateList) {
      setState(() {
        _locations = newList;
        _currentPageIndex = _currentPageIndex.clamp(0, _locations.length - 1);
      });

      if (!lengthChanged && contentChanged) {
        debugPrint(
          'WeatherPage updateLocations: content/order changed without '
          'length change.',
        );
      }

      bool jumpedToActiveLocation = false;
      if (_pageController.hasClients) {
        // On length change or explicit reset, jump to the active location
        if (resetToFirst) {
          _currentPageIndex = 0;
          _pageController.jumpToPage(0);
          return;
        } else if (activeLocation.isNotEmpty) {
          final int activeIndex = newList.indexWhere(
            (Location l) => _isSameLocation(l, activeLocation),
          );

          if (activeIndex >= 0 && activeIndex != _currentPageIndex) {
            _currentPageIndex = activeIndex;
            _pageController.jumpToPage(activeIndex);
            jumpedToActiveLocation = true;
          }
        }
      }

      if (jumpedToActiveLocation) {
        return;
      } else {
        final int updatedVisibleIndex = _getCurrentVisibleIndex();
        final Location updatedVisibleLocation = _locations[updatedVisibleIndex];
        if (!_isSameLocation(previousVisibleLocation, updatedVisibleLocation)) {
          _fetchWeatherForCurrentPageLocation();
        }
      }
    } else {
      final bool activeLocationMissingFromCurrent =
          activeLocation.isNotEmpty &&
          _locations.indexWhere(
                (Location l) => _isSameLocation(l, activeLocation),
              ) <
              0;

      if (activeLocationMissingFromCurrent) {
        debugPrint(
          'WeatherPage updateLocations: active location is missing in '
          'current list while no update was needed '
          '(active=$activeLocation, currentList=$_locations).',
        );
      }
    }
  }

  bool _areLocationListsSame(List<Location> first, List<Location> second) {
    if (first.length != second.length) {
      return false;
    } else {
      for (int index = 0; index < first.length; index++) {
        if (!_isSameLocation(first[index], second[index])) {
          return false;
        }
      }
      return true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final AppLifecycleState? previousState = _lastLifecycleState;
    _lastLifecycleState = state;

    final bool isResumed = state == AppLifecycleState.resumed;
    if (isResumed) {
      final DateTime now = DateTime.now();
      final bool hasRecentResumeCheck =
          _lastResumeCheckAt != null &&
          now.difference(_lastResumeCheckAt!) < _resumeCheckDebounce;

      final bool isFromBackgroundState =
          previousState == AppLifecycleState.inactive ||
          previousState == AppLifecycleState.hidden ||
          previousState == AppLifecycleState.paused;
      final bool shouldFilterMacDesktopTransition =
          !kIsWeb &&
          defaultTargetPlatform == TargetPlatform.macOS &&
          !isFromBackgroundState;

      if (shouldFilterMacDesktopTransition) {
        debugPrint(
          'WeatherPage lifecycle: skip resume weather check on macOS '
          '(previousState=$previousState).',
        );
      } else if (hasRecentResumeCheck) {
        debugPrint(
          'WeatherPage lifecycle: skip debounced resume weather check '
          '(previousState=$previousState).',
        );
      } else {
        _lastResumeCheckAt = now;
        debugPrint(
          'WeatherPage lifecycle: dispatch resume weather check '
          '(previousState=$previousState).',
        );
        // Check if the hour has changed while the app was in the background.
        // Only reload if we've transitioned to a new hour.
        context.read<WeatherBloc>().add(
          CheckHourChangeOnResume(context.origin),
        );
      }

      _reconcileVisibleLocationOnResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isExtraSmall = context.isExtraSmallScreen;
    final bool isWide = context.screenWidth > constants.kWideLayoutBreakpoint;
    final bool showPageArrows =
        _locations.length > 1 && (isWearDevice || isWide);

    final Widget pageView = PageView.builder(
      controller: _pageController,
      itemCount: _locations.length,
      onPageChanged: (int index) {
        setState(() {
          _currentPageIndex = index;
        });
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

    final Widget body = showPageArrows
        ? Stack(
            children: <Widget>[
              pageView,
              if (_currentPageIndex > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: isExtraSmall ? 2.0 : 8.0),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: isExtraSmall ? 36 : 56,
                        minHeight: isExtraSmall ? 36 : 56,
                      ),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.54,
                        ),
                        size: isExtraSmall ? 18 : 48,
                      ),
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),
                ),
              if (_currentPageIndex < _locations.length - 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: isExtraSmall ? 2.0 : 8.0),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: isExtraSmall ? 36 : 56,
                        minHeight: isExtraSmall ? 36 : 56,
                      ),
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.54,
                        ),
                        size: isExtraSmall ? 18 : 48,
                      ),
                      onPressed: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),
                ),
            ],
          )
        : pageView;

    return BlocListener<WeatherBloc, WeatherState>(
      listener: (BuildContext context, WeatherState state) {
        _logStateSnapshot(state);
        _weatherBlocStateListener(context, state);
        // Update locations list whenever state changes to ensure new locations
        // from search are added before loading state is shown
        if (state is WeatherSuccess ||
            state is WeatherInitial ||
            state is WeatherLoadingState) {
          _updateLocations();
          _syncVisibleLocationWithState(state);
        }
      },
      child: isExtraSmall
          ? WeatherPageExtraSmallLayout(
              onSettingsPressed: _navigateToSettingsAndRefreshOutfit,
              onRefresh: _refresh,
              onSearchPressed: _handleLocationSearchAndFetchWeather,
              onReportPressed: _handleReportPressed,
              bodyOverride: body,
            )
          : WeatherPageDefaultLayout(
              onSettingsPressed: _navigateToSettingsAndRefreshOutfit,
              onRefresh: _refresh,
              onSearchPressed: _handleLocationSearchAndFetchWeather,
              onReportPressed: _handleReportPressed,
              bodyOverride: body,
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
    final LocalDataSource localDataSource = context.read<LocalDataSource>();
    final Location locationBeforeNavigation = localDataSource
        .getLastSavedLocation();

    Navigator.pushNamed(context, AppRoute.settings.path).whenComplete(() {
      if (mounted) {
        final Location locationAfterNavigation = localDataSource
            .getLastSavedLocation();
        if (_isSameLocation(
          locationBeforeNavigation,
          locationAfterNavigation,
        )) {
          final WeatherBloc weatherBloc = context.read<WeatherBloc>();
          weatherBloc.add(
            GetOutfitEvent(
              weather: weatherBloc.state.weather,
              origin: context.origin,
            ),
          );
        }
      }
    });
  }

  Future<void> _handleLocationSearchAndFetchWeather() async {
    final Object? weather = await Navigator.pushNamed<Object>(
      context,
      AppRoute.search.path,
    );

    if (mounted && weather is Weather) {
      final LocalDataSource localDataSource = context.read<LocalDataSource>();
      await localDataSource.saveLastSearchedLocation(weather.location);
      await localDataSource.saveLocation(weather.location);
      if (mounted) {
        context.read<WeatherBloc>().add(
          FetchDailyForecast(location: weather.location),
        );
        context.read<WeatherBloc>().add(
          GetOutfitEvent(weather: weather, origin: context.origin),
        );
      }

      _updateLocations(resetToFirst: true);
    }
  }

  Future<void> _refresh() {
    return Future<void>.delayed(Duration.zero, () {
      if (mounted) {
        _fetchWeatherForCurrentPageLocation();
      }
    });
  }

  void _fetchWeatherForCurrentPageLocation() {
    if (_locations.isEmpty) {
      context.read<WeatherBloc>().add(RefreshWeather(context.origin));
      return;
    }

    final int safeIndex = _getCurrentVisibleIndex();
    final Location currentLocation = _locations[safeIndex];

    if (currentLocation.isNotEmpty) {
      context.read<LocalDataSource>().saveLocation(currentLocation);
      context.read<WeatherBloc>().add(
        FetchWeather(location: currentLocation, origin: context.origin),
      );
    } else {
      context.read<WeatherBloc>().add(RefreshWeather(context.origin));
    }
  }

  void _syncVisibleLocationWithState(WeatherState state) {
    if (_locations.isEmpty) {
      debugPrint(
        'WeatherPage state sync: skipped because locations are empty.',
      );
      return;
    } else {
      final int safeIndex = _getCurrentVisibleIndex();
      final Location visibleLocation = _locations[safeIndex];
      final Location stateLocation = state.location;

      if (visibleLocation.isEmpty || stateLocation.isEmpty) {
        debugPrint(
          'WeatherPage state sync: skipped due to empty location '
          '(visible=$visibleLocation, state=$stateLocation).',
        );
        return;
      } else {
        final bool locationsMismatch = !_isSameLocation(
          visibleLocation,
          stateLocation,
        );
        final bool loadingVisibleLocation =
            state is WeatherLoadingState &&
            _isSameLocation(stateLocation, visibleLocation);

        if (locationsMismatch && !loadingVisibleLocation) {
          final DateTime now = DateTime.now();
          final bool hasRecentResync =
              _lastLocationResyncAt != null &&
              now.difference(_lastLocationResyncAt!) < _locationResyncDebounce;

          if (hasRecentResync) {
            debugPrint(
              'WeatherPage state sync: skip debounced resync '
              '(visible=$visibleLocation, state=$stateLocation).',
            );
          } else {
            _lastLocationResyncAt = now;
            debugPrint(
              'WeatherPage state sync: fetch visible page location '
              '(visible=$visibleLocation, state=$stateLocation).',
            );
            context.read<LocalDataSource>().saveLocation(visibleLocation);
            context.read<WeatherBloc>().add(
              FetchWeather(location: visibleLocation, origin: context.origin),
            );
          }
        } else {
          debugPrint(
            'WeatherPage state sync: no resync needed '
            '(locationsMismatch=$locationsMismatch, '
            'loadingVisibleLocation=$loadingVisibleLocation, '
            'visible=$visibleLocation, state=$stateLocation).',
          );
        }
      }
    }
  }

  void _reconcileVisibleLocationOnResume() {
    if (_locations.isEmpty) {
      debugPrint('WeatherPage lifecycle: resume resync skipped, no locations.');
      return;
    } else {
      final int safeIndex = _getCurrentVisibleIndex();
      final Location visibleLocation = _locations[safeIndex];
      final WeatherState state = context.read<WeatherBloc>().state;
      final Location stateLocation = state.location;

      debugPrint(
        'WeatherPage lifecycle: evaluate resume resync '
        '(stateType=${state.runtimeType}, visible=$visibleLocation, '
        'state=$stateLocation).',
      );

      if (visibleLocation.isEmpty || stateLocation.isEmpty) {
        debugPrint(
          'WeatherPage lifecycle: resume resync skipped due to empty location '
          '(visible=$visibleLocation, state=$stateLocation).',
        );
        return;
      } else {
        final bool hasLocationMismatch = !_isSameLocation(
          visibleLocation,
          stateLocation,
        );

        if (hasLocationMismatch) {
          final DateTime now = DateTime.now();
          final bool hasRecentResync =
              _lastLocationResyncAt != null &&
              now.difference(_lastLocationResyncAt!) < _locationResyncDebounce;

          if (hasRecentResync) {
            debugPrint(
              'WeatherPage lifecycle: skip debounced resume resync '
              '(visible=$visibleLocation, state=$stateLocation).',
            );
          } else {
            _lastLocationResyncAt = now;
            debugPrint(
              'WeatherPage lifecycle: fetch visible location on resume '
              '(visible=$visibleLocation, state=$stateLocation).',
            );
            context.read<LocalDataSource>().saveLocation(visibleLocation);
            context.read<WeatherBloc>().add(
              FetchWeather(location: visibleLocation, origin: context.origin),
            );
          }
        } else {
          debugPrint(
            'WeatherPage lifecycle: resume resync not needed '
            '(visible matches state).',
          );
        }
      }
    }
  }

  void _logStateSnapshot(WeatherState state) {
    final DateTime now = DateTime.now();
    final bool shouldSkipLog =
        _lastStateSnapshotLogAt != null &&
        now.difference(_lastStateSnapshotLogAt!) < _stateSnapshotLogDebounce;

    if (shouldSkipLog) {
      return;
    } else {
      _lastStateSnapshotLogAt = now;

      final Location visibleLocation;
      if (_locations.isEmpty) {
        visibleLocation = const Location.empty();
      } else {
        final int safeIndex = _getCurrentVisibleIndex();
        visibleLocation = _locations[safeIndex];
      }

      debugPrint(
        'WeatherPage snapshot: state=${state.runtimeType}, '
        'stateLocation=${state.location}, visibleLocation=$visibleLocation, '
        'pageIndex=$_currentPageIndex.',
      );
    }
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

  int _getCurrentVisibleIndex() {
    if (_locations.isEmpty) {
      return 0;
    } else {
      int resolvedIndex = _currentPageIndex.clamp(0, _locations.length - 1);

      if (_pageController.hasClients) {
        final double? page = _pageController.page;
        if (page != null) {
          final int controllerIndex = page.round().clamp(
            0,
            _locations.length - 1,
          );

          if (controllerIndex != resolvedIndex) {
            debugPrint(
              'WeatherPage page sync: align current index '
              '(stateIndex=$resolvedIndex, controllerIndex=$controllerIndex).',
            );
            resolvedIndex = controllerIndex;
            _currentPageIndex = controllerIndex;
          }
        }
      }

      return resolvedIndex;
    }
  }
}
