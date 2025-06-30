import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nested/nested.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/theme/cubit/theme_cubit.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/router/routes.dart' as routes;
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/services/home_widget_service.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({
    required WeatherRepository weatherRepository,
    required LocationRepository locationRepository,
    required OutfitRepository outfitRepository,
    required LocalDataSource localDataSource,
    super.key,
  })  : _weatherRepository = weatherRepository,
        _locationRepository = locationRepository,
        _localDataSource = localDataSource,
        _outfitRepository = outfitRepository;

  final WeatherRepository _weatherRepository;
  final LocationRepository _locationRepository;
  final OutfitRepository _outfitRepository;
  final LocalDataSource _localDataSource;

  @override
  Widget build(BuildContext context) {
    // Use the `MultiRepositoryProvider` widget to provide two repositories.
    return MultiRepositoryProvider(
      providers: <SingleChildWidget>[
        // Provide the weather repository.
        RepositoryProvider<WeatherRepository>.value(value: _weatherRepository),
        // Provide the AI repository.
        RepositoryProvider<OutfitRepository>.value(value: _outfitRepository),
      ],
      child: MultiBlocProvider(
        providers: <SingleChildWidget>[
          // Provide the theme cubit.
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
          BlocProvider<WeatherBloc>(
            create: (BuildContext _) {
              return WeatherBloc(
                _weatherRepository,
                _outfitRepository,
                _localDataSource,
                const HomeWidgetServiceImpl(),
              );
            },
          ),
          BlocProvider<SettingsBloc>(
            create: (BuildContext context) {
              final Language initialLanguage = _getInitialLanguage(context);
              return SettingsBloc(_localDataSource, initialLanguage);
            },
          ),
          BlocProvider<SearchBloc>(
            create: (BuildContext _) => SearchBloc(
              _weatherRepository,
              _locationRepository,
              _localDataSource,
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, Color>(
          builder: (BuildContext _, Color color) {
            final DateTime now = DateTime.now();
            final int hour = now.hour;
            // Assume darkness from 10 PM to 6 AM
            final bool completeDarkness = hour < 6 || hour > 21;

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: constants.appName,
              initialRoute: AppRoute.weather.path,
              routes: routes.getRouteMap(_localDataSource.getLanguageIsoCode()),
              theme: ThemeData(
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                colorScheme: ColorScheme.fromSeed(seedColor: color),
                textTheme: GoogleFonts.montserratTextTheme(),
                // This font is probably not needed, I added it to avoid a
                // "Could not find a set of Noto fonts to display all missing
                // characters" error, but it still did not help.
                fontFamily: 'NotoSans',
              ),
              darkTheme: ThemeData(
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: color,
                  brightness: Brightness.dark,
                ),
                textTheme: GoogleFonts.montserratTextTheme(
                  ThemeData.dark().textTheme,
                ),
                fontFamily: 'NotoSans',
              ),
              themeMode: completeDarkness ? ThemeMode.dark : ThemeMode.light,
            );
          },
        ),
      ),
    );
  }

  Language _getInitialLanguage(BuildContext context) {
    final Language currentLanguage = Language.fromIsoLanguageCode(
      LocalizedApp.of(context).delegate.currentLocale.languageCode,
    );
    final Language savedLanguage = Language.fromIsoLanguageCode(
      _localDataSource.getLanguageIsoCode(),
    );

    if (currentLanguage != savedLanguage) {
      changeLocale(context, savedLanguage.isoLanguageCode);
    }
    return savedLanguage;
  }
}
