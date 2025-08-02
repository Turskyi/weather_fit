import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nested/nested.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/resources.dart';
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
    required this.weatherRepository,
    required this.locationRepository,
    required this.outfitRepository,
    required this.localDataSource,
    required this.initialLanguage,
    super.key,
  });

  final WeatherRepository weatherRepository;
  final LocationRepository locationRepository;
  final OutfitRepository outfitRepository;
  final LocalDataSource localDataSource;
  final Language initialLanguage;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: <SingleChildWidget>[
        // Provide the weather repository.
        RepositoryProvider<WeatherRepository>.value(value: weatherRepository),
        // Provide the AI repository.
        RepositoryProvider<OutfitRepository>.value(value: outfitRepository),
      ],
      child: MultiBlocProvider(
        providers: <SingleChildWidget>[
          // Provide the theme cubit.
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
          BlocProvider<WeatherBloc>(
            create: (BuildContext _) {
              return WeatherBloc(
                weatherRepository,
                outfitRepository,
                localDataSource,
                const HomeWidgetServiceImpl(),
                initialLanguage.isoLanguageCode,
              );
            },
          ),
          BlocProvider<SettingsBloc>(
            create: (BuildContext _) {
              return SettingsBloc(localDataSource, initialLanguage);
            },
          ),
          BlocProvider<SearchBloc>(
            create: (BuildContext _) => SearchBloc(
              weatherRepository,
              locationRepository,
              localDataSource,
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, Color>(
          builder: (BuildContext _, Color color) {
            final DateTime now = DateTime.now();
            final int hour = now.hour;
            // Assume darkness from 10 PM to 6 AM
            final bool completeDarkness = hour < 6 || hour > 21;

            return Resources(
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: constants.appName,
                initialRoute: AppRoute.weather.path,
                routes: routes.getRouteMap(initialLanguage.isoLanguageCode),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
