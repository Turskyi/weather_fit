import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/entities/enums/search_error_type.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;
import 'package:weather_fit/res/widgets/wear_position_indicator.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/search/ui/widgets/search_layout_default.dart';
import 'package:weather_fit/search/ui/widgets/search_layout_extra_small.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _textController = TextEditingController();

  String get _text => _textController.text.trim();

  @override
  Widget build(BuildContext context) {
    final bool isExtraSmallScreen = context.isExtraSmallScreen;
    return Semantics(
      label: translate('search.page_semantics_label'),
      child: isExtraSmallScreen
          ? SearchPageExtraSmallLayout(
              textEditingController: _textController,
              searchStateListener: _searchStateListener,
            )
          : SearchLayoutDefault(
              textEditingController: _textController,
              searchStateListener: _searchStateListener,
            ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _searchStateListener(BuildContext context, SearchState state) {
    if (state is SearchLocationFound) {
      _showLocationConfirmationDialog(state.location);
    } else if (state is SearchLocationNotFound) {
      _showLocationNotFoundDialog();
    } else if (state is SearchWeatherLoaded) {
      _handleSearchWeatherLoaded(state.weather);
    } else if (state is SearchError) {
      _handleSearchError(state);
    }
  }

  Future<void> _handleSearchWeatherLoaded(Weather weather) async {
    final Location location = weather.location;
    final LocalDataSource localDataSource = context.read<LocalDataSource>();
    final WeatherBloc weatherBloc = context.read<WeatherBloc>();
    final NavigatorState navigator = Navigator.of(context);
    final RoutePredicate weatherRoutePredicate = ModalRoute.withName(
      AppRoute.weather.path,
    );

    await localDataSource.saveLastSearchedLocation(location);
    await localDataSource.saveLocation(location);

    if (mounted) {
      weatherBloc.add(FetchWeather(location: location, origin: context.origin));

      navigator.popUntil(weatherRoutePredicate);
    }
  }

  Future<void> _showLocationConfirmationDialog(Location location) {
    // Build a list of non-empty location parts.
    final List<String> parts = <String>[];

    // Assuming location.name will always be present and not empty based on
    // typical API responses.
    parts.add(location.name);

    if (location.province.isNotEmpty) {
      parts.add(location.province);
    }

    if (location.country.isNotEmpty) {
      parts.add(location.country);
    }

    // Join the parts with a comma and a space.
    final String displayLocation = parts.join(', ');

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final Widget dialog = context.isExtraSmallScreen
            ? _WearDialog(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      translate('search.confirm_location_dialog_title'),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      displayLocation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                          onPressed: _handleLocationConfirmationNo,
                          child: Text(translate('no')),
                        ),
                        TextButton(
                          autofocus: true,
                          child: Text(translate('yes')),
                          onPressed: () => _confirmLocationAndPop(location),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : AlertDialog(
                title: Text(translate('search.confirm_location_dialog_title')),
                content: Text(displayLocation),
                actions: <Widget>[
                  TextButton(
                    onPressed: _handleLocationConfirmationNo,
                    child: Text(translate('no')),
                  ),
                  TextButton(
                    autofocus: true,
                    child: Text(translate('yes')),
                    onPressed: () => _confirmLocationAndPop(location),
                  ),
                ],
              );

        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                FocusScope.of(context).previousFocus(),
            const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                FocusScope.of(context).nextFocus(),
          },
          child: dialog,
        );
      },
    );
  }

  void _confirmLocationAndPop(Location location) {
    context.read<SearchBloc>().add(ConfirmLocation(location));
    return Navigator.of(context).pop();
  }

  Future<void> _handleLocationConfirmationNo() {
    Navigator.of(context).pop();
    return _showUseCurrentLocationDialog();
  }

  Future<void> _showUseCurrentLocationDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final Widget dialog = context.isExtraSmallScreen
            ? _WearDialog(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      translate(
                        'search.'
                        'location_not_found_suggestion_spell_check',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Theme.of(
                          context,
                        ).textTheme.bodySmall?.fontSize,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                          autofocus: true,
                          onPressed: Navigator.of(context).pop,
                          child: Text(translate('close')),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : AlertDialog(
                title: Text(
                  translate('search.use_current_location_dialog_title'),
                ),
                content: Text(
                  translate(
                    'search.location_not_found_use_current_dialog_content',
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(translate('cancel')),
                  ),
                  TextButton(
                    autofocus: true,
                    onPressed: _handleUseCurrentLocationConfirm,
                    child: Text(translate('yes')),
                  ),
                ],
              );

        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                FocusScope.of(context).previousFocus(),
            const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                FocusScope.of(context).nextFocus(),
          },
          child: dialog,
        );
      },
    );
  }

  void _handleUseCurrentLocationConfirm() {
    Navigator.of(context).pop();

    return context.read<SearchBloc>().add(
      RequestPermissionAndSearchByLocation(_text),
    );
  }

  Future<void> _showLocationNotFoundDialog() {
    final bool isExtraSmallScreen = context.isExtraSmallScreen;
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        if (isExtraSmallScreen) {
          return _WearLocationNotFoundDialog(
            onCancel: () => Navigator.of(dialogContext).pop(),
          );
        }

        return AlertDialog(
          title: Text(translate('search.location_not_found_dialog_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                translate('search.location_not_found_suggestion_spell_check'),
              ),
              const SizedBox(height: 16),
              Text(translate('search.location_not_found_suggestion_use_gps')),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: Navigator.of(dialogContext).pop,
              child: Text(translate('cancel')),
            ),
            TextButton(
              autofocus: true,
              onPressed: _handleUseGpsConfirm,
              child: Text(translate('search.use_gps_button')),
            ),
          ],
        );
      },
    );
  }

  void _handleUseGpsConfirm() {
    Navigator.of(context).pop();
    return context.read<SearchBloc>().add(
      RequestPermissionAndSearchByLocation(_text),
    );
  }

  void _handleSearchError(SearchError state) {
    if (state.isCertificateValidationError) {
      // Show a more detailed, blocking dialog for
      // this specific error.
      _handleCertificateValidationError(state);
    } else if (state.isPermissionDeniedError) {
      _handlePermissionDeniedError(state);
    } else if (state.isNetworkError) {
      _handleNetworkError(state);
    } else if (state.isLocationServiceDisabledError) {
      _handleLocationServiceDisabledError(state);
    } else {
      debugPrint(
        '[_handleSearchError] Unexpected SearchError state:\n'
        'errorMessage: ${state.errorMessage}\n'
        'query: ${state.query}\n'
        'errorType: ${state.errorType}',
      );

      if (context.isExtraSmallScreen) {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return _WearDialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('📍', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    translate('error.gps_unavailable_watch'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _handleReportErrorSnackBarAction,
                    child: Text(translate('error.report_issue')),
                  ),
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(translate('close')),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SelectableText(state.errorMessage),
            duration: const Duration(seconds: 7),
            action: SnackBarAction(
              label: translate('try_again'),
              onPressed: () => _handleRetrySearch(state),
            ),
          ),
        );
      }
    }
  }

  void _handleRetrySearch(SearchError state) {
    final String query = state.query;
    if (query.isNotEmpty) {
      return context.read<SearchBloc>().add(SearchLocation(query));
    } else {
      return context.read<SearchBloc>().add(
        RetrySearchByCurrentLocation(query),
      );
    }
  }

  Future<void> _handleCertificateValidationError(SearchError state) {
    // Show a more detailed, blocking dialog for
    // this specific error.
    return showDialog<void>(
      context: context,
      // User must interact with the dialog.
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final String errorMessage = state.errorMessage;
        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                FocusScope.of(dialogContext).previousFocus(),
            const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                FocusScope.of(dialogContext).nextFocus(),
          },
          child: AlertDialog(
            title: Text(translate('error.connection_security_issue_title')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(errorMessage),
                  const SizedBox(height: 16),
                  Text(translate('error.what_you_can_do')),
                  Text("- ${translate('error.ensure_os_updated')}"),
                  Text("- ${translate('error.check_date_time')}"),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(translate('error.report_issue_button')),
                onPressed: () => _handleReportActionAndPop(errorMessage),
              ),
              TextButton(
                autofocus: true,
                onPressed: Navigator.of(dialogContext).pop,
                child: Text(translate('ok')),
              ),
            ],
          ),
        );
      },
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
  _handlePermissionDeniedError(SearchError state) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SelectableText(state.errorMessage),
        duration: const Duration(seconds: 7),
        action: SnackBarAction(
          label: translate('settings.title'),
          onPressed: _handleOpenLocationSettings,
        ),
      ),
    );
  }

  Future<void> _handleOpenLocationSettings() async {
    if (!kIsWeb && Platform.isMacOS) {
      final Uri url = Uri.parse(constants.kMacOSLocationServicesSettingsUrl);
      final bool canLaunch = await canLaunchUrl(url);
      if (canLaunch) {
        await launchUrl(url);
      }
    } else {
      await _openDeviceLocationSettings();
    }
    if (mounted) {
      return ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  Future<void> _handleNetworkError(SearchError state) {
    final String errorMessage = state.errorMessage;
    if (context.isExtraSmallScreen) {
      return Navigator.pushNamed<void>(
        context,
        AppRoute.unableToConnect.path,
        arguments: SearchError(
          errorMessage: errorMessage,
          query: _text,
          errorType: SearchErrorType.network,
          quickCitiesSuggestions: state.quickCitiesSuggestions,
        ),
      );
    } else {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CallbackShortcuts(
            bindings: <ShortcutActivator, VoidCallback>{
              const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                  FocusScope.of(context).previousFocus(),
              const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                  FocusScope.of(context).nextFocus(),
            },
            child: AlertDialog(
              title: Text(translate('error.unable_to_connect')),
              content: Text(translate('error.connection_reset_suggestion')),
              actions: <Widget>[
                TextButton(
                  onPressed: () => _handleReportActionAndPop(errorMessage),
                  child: Text(translate('report_issue')),
                ),
                ElevatedButton(
                  autofocus: true,
                  onPressed: _text.isEmpty ? null : _popAndSearch,
                  child: Text(translate('try_again')),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _handleLocationServiceDisabledError(SearchError state) {
    if (context.isExtraSmallScreen) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return _WearDialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  translate('error.location_services_disabled_title'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  translate('error.location_services_disabled_content'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    autofocus: true,
                    onPressed: Navigator.of(dialogContext).pop,
                    child: Text(translate('close')),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(translate('error.location_services_disabled_title')),
            content: Text(
              translate('error.location_services_disabled_content'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: Navigator.of(dialogContext).pop,
                child: Text(translate('cancel')),
              ),
              TextButton(
                autofocus: true,
                onPressed: _handleOpenLocationSettingsAndPop,
                child: Text(translate('settings.title')),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _handleOpenLocationSettingsAndPop() async {
    Navigator.of(context).pop();
    await _openDeviceLocationSettings();
  }

  Future<void> _openDeviceLocationSettings() async {
    final bool openedByGeolocator =
        await geolocator.Geolocator.openLocationSettings();

    if (!openedByGeolocator) {
      await permission_handler.openAppSettings();
    }
  }

  void _popAndSearch() {
    Navigator.of(context).pop();
    return context.read<SearchBloc>().add(SearchLocation(_text));
  }

  void _handleReportActionAndPop(String errorText) {
    context.read<SettingsBloc>().add(BugReportPressedEvent(errorText));
    return Navigator.of(context).pop();
  }

  void _handleReportErrorSnackBarAction() {
    final SearchState state = context.read<SearchBloc>().state;

    context.read<SettingsBloc>().add(
      BugReportPressedEvent(state is SearchError ? state.errorMessage : ''),
    );
    return ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}

class _WearDialog extends StatefulWidget {
  const _WearDialog({required this.child});

  final Widget child;

  @override
  State<_WearDialog> createState() => _WearDialogState();
}

class _WearDialogState extends State<_WearDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: WearPositionIndicator(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: widget.child,
        ),
      ),
    );
  }
}

class _WearLocationNotFoundDialog extends StatefulWidget {
  const _WearLocationNotFoundDialog({required this.onCancel});

  final VoidCallback onCancel;

  @override
  State<_WearLocationNotFoundDialog> createState() =>
      _WearLocationNotFoundDialogState();
}

class _WearLocationNotFoundDialogState
    extends State<_WearLocationNotFoundDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: WearPositionIndicator(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                translate('search.location_not_found_dialog_title'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                translate('search.location_not_found_suggestion_spell_check'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: widget.onCancel,
                  child: Text(translate('cancel')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
