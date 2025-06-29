import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nominatim_api/nominatim_api.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/di/injector.dart';
import 'package:weather_fit/feedback/feedback_form.dart';
import 'package:weather_fit/localization/localization_delelegate_getter.dart'
    as locale;
import 'package:weather_fit/weather_app.dart';
import 'package:weather_repository/weather_repository.dart';

/// The [main] is the ultimate detail — the lowest-level policy.
/// It is the initial entry point of the system.
/// Nothing, other than the operating system, depends on it.
/// Here you should [injectDependencies].
/// Think of [main] as a plugin to the [WeatherApp] - a plugin that sets up
/// the initial conditions and configurations, gathers all the outside
/// resources, and then hands control over to the high-level policy of the
/// [WeatherApp].
/// When [main] is released, it has utterly no effect on any of the other
/// components in the system. They don’t know about [main], and they don’t care
/// when it changes.
void main() async {
  await injectDependencies();

  final SharedPreferences preferences = await SharedPreferences.getInstance();

  final LocalDataSource localDataSource = LocalDataSource(preferences);

  final LocalizationDelegate localizationDelegate =
      await locale.getLocalizationDelegate(
    localDataSource,
  );

  runApp(
    LocalizedApp(
      localizationDelegate,
      BetterFeedback(
        feedbackBuilder: (
          BuildContext context,
          OnSubmit onSubmit,
          ScrollController? scrollController,
        ) {
          return FeedbackForm(
            onSubmit: onSubmit,
            scrollController: scrollController,
          );
        },
        theme: FeedbackThemeData(feedbackSheetColor: Colors.grey.shade50),
        child: WeatherApp(
          weatherRepository: WeatherRepository(),
          locationRepository: LocationRepository(
            NominatimApiClient(),
            OpenMeteoApiClient(),
            localDataSource,
          ),
          outfitRepository: OutfitRepository(localDataSource),
          localDataSource: localDataSource,
        ),
      ),
    ),
  );
}
