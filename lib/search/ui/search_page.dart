import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:permission_handler/permission_handler.dart' as geolocator;
import 'package:weather_fit/entities/enums/search_error_type.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/search/ui/widgets/search_layout_default.dart';
import 'package:weather_fit/search/ui/widgets/search_layout_extra_small.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({required this.languageIsoCode, super.key});

  final String languageIsoCode;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _textController = TextEditingController();

  String get _text => _textController.text.trim();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    // 192.0 is the size of Kate's Pixel Watch 2.
    final bool isExtraSmallScreen = screenWidth <= 200.0;
    return Semantics(
      label: translate('search.page_semantics_label'),
      child: isExtraSmallScreen
          ? SearchPageExtraSmallLayout(
              textEditingController: _textController,
              searchStateListener: _searchStateListener,
              languageIsoCode: widget.languageIsoCode,
            )
          : SearchLayoutDefault(
              textEditingController: _textController,
              searchStateListener: _searchStateListener,
              languageIsoCode: widget.languageIsoCode,
            ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
        if (context.isExtraSmallScreen) {
          return Dialog.fullscreen(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 24.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        onPressed: _handleLocationConfirmationNo,
                        child: Text(translate('no')),
                      ),
                      TextButton(
                        child: Text(translate('yes')),
                        onPressed: () => _confirmLocationAndPop(location),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return AlertDialog(
            title: Text(translate('search.confirm_location_dialog_title')),
            content: Text(displayLocation),
            actions: <Widget>[
              TextButton(
                onPressed: _handleLocationConfirmationNo,
                child: Text(translate('no')),
              ),
              TextButton(
                child: Text(translate('yes')),
                onPressed: () => _confirmLocationAndPop(location),
              ),
            ],
          );
        }
      },
    );
  }

  void _confirmLocationAndPop(Location location) {
    context.read<SearchBloc>().add(ConfirmLocation(location));
    Navigator.of(context).pop();
  }

  void _handleLocationConfirmationNo() {
    Navigator.of(context).pop();
    _showUseCurrentLocationDialog();
  }

  Future<void> _showUseCurrentLocationDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        if (context.isExtraSmallScreen) {
          return Dialog.fullscreen(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 16, right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    translate(
                      'search.location_not_found_use_current_dialog_content',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        onPressed: Navigator.of(context).pop,
                        child: Text(translate('cancel')),
                      ),
                      TextButton(
                        onPressed: _handleUseCurrentLocationConfirm,
                        child: Text(translate('yes')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return AlertDialog(
            title: Text(translate('search.use_current_location_dialog_title')),
            content: Text(
              translate('search.location_not_found_use_current_dialog_content'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text(translate('cancel')),
              ),
              TextButton(
                onPressed: _handleUseCurrentLocationConfirm,
                child: Text(translate('yes')),
              ),
            ],
          );
        }
      },
    );
  }

  void _handleUseCurrentLocationConfirm() {
    Navigator.of(context).pop();

    context.read<SearchBloc>().add(RequestPermissionAndSearchByLocation(_text));
  }

  Future<void> _showLocationNotFoundDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(translate('search.location_not_found_dialog_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                translate('search.location_not_found_suggestion_spell_check'),
              ),
              // Example translation key
              const SizedBox(height: 16),
              Text(translate('search.location_not_found_suggestion_use_gps')),
              // Example translation key
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: Navigator.of(dialogContext).pop,
              child: Text(translate('cancel')),
            ),
            TextButton(
              child: Text(translate('search.use_gps_button')),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<SearchBloc>().add(
                  RequestPermissionAndSearchByLocation(_text),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _searchStateListener(BuildContext context, SearchState state) {
    if (state is SearchLocationFound) {
      _showLocationConfirmationDialog(state.location);
    } else if (state is SearchLocationNotFound) {
      _showLocationNotFoundDialog();
    } else if (state is SearchWeatherLoaded) {
      // Navigate to the weather details page.
      Navigator.pop(context, state.weather);
    } else if (state is SearchError) {
      if (state.isCertificateValidationError) {
        // Show a more detailed, blocking dialog for
        // this specific error.
        showDialog(
          context: context,
          // User must interact with the dialog.
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text(translate('error.connection_security_issue_title')),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(state.errorMessage),
                    const SizedBox(height: 16),
                    Text(translate('error.what_you_can_do')),
                    Text(
                      "- ${translate('error.'
                      'ensure_os_updated')}",
                    ),
                    Text(
                      "- ${translate('error.'
                      'check_date_time')}",
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(translate('error.report_issue_button')),
                  onPressed: () =>
                      _handleReportActionAndPop(state.errorMessage),
                ),
                TextButton(
                  child: Text(translate('ok')),
                  onPressed: () {
                    // Close the dialog.
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (state.isPermissionDeniedError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage),
            duration: const Duration(seconds: 7),
            action: SnackBarAction(
              label: translate('settings.title'),
              onPressed: () {
                // Helper from geolocator to open app
                // settings.
                geolocator.openAppSettings();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      } else if (state.isNetworkError) {
        if (context.isExtraSmallScreen) {
          Navigator.pushNamed(
            context,
            AppRoute.unableToConnect.path,
            arguments: SearchError(
              errorMessage: state.errorMessage,
              query: _text,
              errorType: SearchErrorType.network,
            ),
          );
        } else {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(translate('error.unable_to_connect')),
                content: Text(translate('error.connection_reset_suggestion')),
                actions: <Widget>[
                  TextButton(
                    onPressed: () =>
                        _handleReportActionAndPop(state.errorMessage),
                    child: Text(translate('report_issue')),
                  ),
                  ElevatedButton(
                    onPressed: _text.isEmpty ? null : () => _popAndSearch(),
                    child: Text(translate('try_again')),
                  ),
                ],
              );
            },
          );
        }
      } else {
        if (context.isExtraSmallScreen) {
          showGeneralDialog<void>(
            context: context,
            barrierDismissible: true,
            barrierLabel: translate('close'),
            pageBuilder:
                (BuildContext context, Animation<double> _, Animation<double> _) {
                  return Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
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
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(translate('close')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              duration: const Duration(seconds: 7),
              action: SnackBarAction(
                label: translate('error.report'),
                onPressed: _handleReportErrorSnackBarAction,
              ),
            ),
          );
        }
      }
    }
  }

  void _popAndSearch() {
    Navigator.of(context).pop();
    context.read<SearchBloc>().add(SearchLocation(_text));
  }

  void _handleReportActionAndPop(String errorText) {
    context.read<SettingsBloc>().add(BugReportPressedEvent(errorText));
    Navigator.of(context).pop();
  }

  void _handleReportErrorSnackBarAction() {
    if (mounted) {
      final SearchState state = context.read<SearchBloc>().state;

      context.read<SettingsBloc>().add(
        BugReportPressedEvent(state is SearchError ? state.errorMessage : ''),
      );
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }
}
