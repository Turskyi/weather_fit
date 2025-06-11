import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nested/nested.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/theme/cubit/theme_cubit.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/router/routes.dart' as routes;
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({
    required WeatherRepository weatherRepository,
    required OutfitRepository outfitRepository,
    super.key,
  })  : _weatherRepository = weatherRepository,
        _aiRepository = outfitRepository;

  final WeatherRepository _weatherRepository;
  final OutfitRepository _aiRepository;

  @override
  Widget build(BuildContext context) {
    // Use the `MultiRepositoryProvider` widget to provide two repositories.
    return MultiRepositoryProvider(
      providers: <SingleChildWidget>[
        // Provide the weather repository.
        RepositoryProvider<WeatherRepository>.value(value: _weatherRepository),
        // Provide the AI repository.
        RepositoryProvider<OutfitRepository>.value(value: _aiRepository),
      ],
      child: MultiBlocProvider(
        providers: <SingleChildWidget>[
          // Provide the theme cubit.
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
          BlocProvider<WeatherBloc>(
            create: (_) => WeatherBloc(_weatherRepository, _aiRepository),
          ),
          BlocProvider<SettingsBloc>(create: (_) => SettingsBloc()),
          BlocProvider<SearchBloc>(
            create: (_) => SearchBloc(_weatherRepository),
          ),
        ],
        child: BlocBuilder<ThemeCubit, Color>(
          builder: (_, Color color) {
            final DateTime now = DateTime.now();
            final int hour = now.hour;
            // Assume darkness from 10 PM to 6 AM
            final bool completeDarkness = hour < 6 || hour > 21;

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: constants.appName,
              initialRoute: AppRoute.weather.path,
              routes: routes.routeMap,
              theme: ThemeData(
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                colorScheme: ColorScheme.fromSeed(seedColor: color),
                textTheme: GoogleFonts.rajdhaniTextTheme(),
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
                textTheme: GoogleFonts.rajdhaniTextTheme(
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
}
