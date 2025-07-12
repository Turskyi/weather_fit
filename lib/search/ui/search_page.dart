import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:permission_handler/permission_handler.dart' as geolocator;
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  FeedbackController? _feedbackController;
  bool _isFeedbackControllerInitialized = false;
  bool _isDisposing = false;
  final TextEditingController _textController = TextEditingController();

  String get _text => _textController.text.trim();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return BlocListener<SettingsBloc, SettingsState>(
      listener: _settingsBlocStateListener,
      child: Semantics(
        label: translate('search.page_semantics_label'),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(title: Text(translate('search.page_app_bar_title'))),
          body: Stack(
            children: <Widget>[
              const Background(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '🏙️',
                      style: TextStyle(
                        fontSize: textTheme.displayLarge?.fontSize,
                      ),
                    ),
                    Text(
                      translate('explore_weather_prompt'),
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      translate('search.instructions'),
                      style: textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        labelText: translate('search.city_or_country'),
                        hintText: translate('search.enter_city_or_country'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.all(12.0),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    BlocConsumer<SearchBloc, SearchState>(
                      listener: (BuildContext context, SearchState state) {
                        if (state is SearchLocationFound) {
                          _showLocationConfirmationDialog(state.location);
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
                                  title: Text(
                                    translate(
                                      'error.connection_security_issue_title',
                                    ),
                                  ),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(state.errorMessage),
                                        const SizedBox(height: 16),
                                        Text(
                                          translate('error.what_you_can_do'),
                                        ),
                                        Text("- ${translate(
                                          'error.ensure_os_updated',
                                        )}"),
                                        Text("- ${translate(
                                          'error.check_date_time',
                                        )}"),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                        translate('error.report_issue_button'),
                                      ),
                                      onPressed: () {
                                        context
                                            .read<SettingsBloc>()
                                            .add(const BugReportPressedEvent());

                                        // Close the dialog.
                                        Navigator.of(dialogContext).pop();
                                      },
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
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                  },
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.errorMessage),
                                duration: const Duration(seconds: 7),
                                action: SnackBarAction(
                                  label: translate('error.report'),
                                  onPressed: () {
                                    context
                                        .read<SettingsBloc>()
                                        .add(const BugReportPressedEvent());
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                  },
                                ),
                              ),
                            );
                          }
                        }
                      },
                      builder: (BuildContext context, SearchState state) {
                        return ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _textController,
                          child: state is SearchLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(),
                                )
                              : Text(
                                  translate('submit'),
                                  semanticsLabel: translate('submit'),
                                ),
                          builder: (
                            BuildContext context,
                            TextEditingValue value,
                            Widget? textSubmit,
                          ) {
                            return ElevatedButton(
                              key: const Key('searchPage_search_iconButton'),
                              onPressed: state is! SearchLoading &&
                                      value.text.trim().isNotEmpty
                                  ? () => context
                                      .read<SearchBloc>()
                                      .add(SearchLocation(_text))
                                  : null,
                              child: textSubmit,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _isDisposing = true;
    // Immediately remove the listener.
    _feedbackController?.removeListener(_onFeedbackChanged);

    // Dispose the controller right away.
    _feedbackController?.dispose();
    _feedbackController = null;
    _isFeedbackControllerInitialized = false;
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
        return AlertDialog(
          title: Text(translate('search.confirm_location_dialog_title')),
          content: Text(displayLocation),
          actions: <Widget>[
            TextButton(
              child: Text(translate('no')),
              onPressed: () {
                Navigator.of(context).pop();
                _showLocationIcon();
              },
            ),
            TextButton(
              child: Text(translate('yes')),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<SearchBloc>().add(ConfirmLocation(location));
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLocationIcon() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
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
              child: Text(translate('yes')),
              onPressed: () async {
                Navigator.of(context).pop();

                context.read<SearchBloc>().add(
                      const RequestPermissionAndSearchByLocation(),
                    );
              },
            ),
          ],
        );
      },
    );
  }

  void _settingsBlocStateListener(BuildContext context, SettingsState state) {
    if (state is FeedbackState) {
      _showFeedbackUi();
    } else if (state is FeedbackSent) {
      _notifyFeedbackSent();
    } else if (state is SettingsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showFeedbackUi() {
    if (_isDisposing) return;
    if (!_isFeedbackControllerInitialized) {
      _feedbackController = BetterFeedback.of(context);
      _isFeedbackControllerInitialized = true;
    }
    if (_feedbackController != null) {
      _feedbackController?.show(
        (UserFeedback feedback) => context.read<SettingsBloc>().add(
              SubmitFeedbackEvent(feedback),
            ),
      );
      _feedbackController?.addListener(_onFeedbackChanged);
    }
  }

  void _onFeedbackChanged() {
    if (_isDisposing) return;
    final bool? isVisible = _feedbackController?.isVisible;
    if (isVisible == false) {
      _feedbackController?.removeListener(_onFeedbackChanged);
      _feedbackController = null;
      _isFeedbackControllerInitialized = false;
      context.read<SettingsBloc>().add(
            const ClosingFeedbackEvent(),
          );
    }
  }

  void _notifyFeedbackSent() {
    _feedbackController?.hide();
    // Let user know that his feedback is sent.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate('feedback.sent')),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
