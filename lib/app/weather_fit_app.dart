import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nested/nested.dart';
import 'package:resend/resend.dart';
import 'package:weather_fit/app/settings_state_listener_content.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/env/env.dart';
import 'package:weather_fit/feedback/feedback_form.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/resources.dart';
import 'package:weather_fit/res/theme/cubit/theme_cubit.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/router/navigator.dart';
import 'package:weather_fit/router/routes.dart' as routes;
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/services/home_widget_service.dart';
import 'package:weather_fit/services/update_service.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherFitApp extends StatelessWidget {
  const WeatherFitApp({
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
    Resend(apiKey: Env.resendApiKey);
    return MultiRepositoryProvider(
      providers: <SingleChildWidget>[
        RepositoryProvider<WeatherRepository>.value(value: weatherRepository),
        RepositoryProvider<OutfitRepository>.value(value: outfitRepository),
        RepositoryProvider<HomeWidgetService>(
          create: (BuildContext _) => const HomeWidgetServiceImpl(),
        ),
        RepositoryProvider<UpdateService>(
          create: (BuildContext _) => const UpdateServiceImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: <SingleChildWidget>[
          // Provide the theme cubit.
          BlocProvider<ThemeCubit>(create: (BuildContext _) => ThemeCubit()),
          BlocProvider<WeatherBloc>(
            create: (BuildContext context) {
              return WeatherBloc(
                weatherRepository,
                outfitRepository,
                localDataSource,
                context.read<HomeWidgetService>(),
              );
            },
          ),
          BlocProvider<SettingsBloc>(
            create: (BuildContext context) {
              return SettingsBloc(
                localDataSource,
                context.read<UpdateService>(),
              );
            },
          ),
          BlocProvider<SearchBloc>(
            create: (BuildContext _) {
              return SearchBloc(
                weatherRepository,
                locationRepository,
                localDataSource,
              );
            },
          ),
        ],
        child: BlocBuilder<ThemeCubit, Color>(
          builder: (BuildContext context, Color color) {
            final DateTime now = DateTime.now();
            final int hour = now.hour;
            // Assume darkness from 10 PM to 6 AM.
            final bool completeDarkness = hour < 6 || hour > 21;
            final LocalizationDelegate localizationDelegate = LocalizedApp.of(
              context,
            ).delegate;

            const String fontFamily = 'Montserrat';

            final ColorScheme lightColorScheme = ColorScheme.fromSeed(
              seedColor: color,
            );
            final ColorScheme darkColorScheme = ColorScheme.fromSeed(
              seedColor: color,
              brightness: Brightness.dark,
            );

            return Resources(
              child: BetterFeedback(
                feedbackBuilder:
                    (
                      BuildContext _,
                      OnSubmit onSubmit,
                      ScrollController? scrollController,
                    ) {
                      return FeedbackForm(
                        onSubmit: onSubmit,
                        scrollController: scrollController,
                      );
                    },
                theme: FeedbackThemeData(
                  feedbackSheetColor: completeDarkness
                      ? darkColorScheme.surface
                      : lightColorScheme.surface,
                ),
                child: MaterialApp(
                  navigatorKey: navigatorKey,
                  debugShowCheckedModeBanner: false,
                  title: constants.appName,
                  localizationsDelegates: <LocalizationsDelegate<Object>>[
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    localizationDelegate,
                  ],
                  supportedLocales: localizationDelegate.supportedLocales,
                  locale: localizationDelegate.currentLocale,
                  initialRoute: AppRoute.weather.path,
                  routes: routes.getRouteMap(),
                  builder: (BuildContext _, Widget? child) {
                    return SettingsStateListenerContent(child: child);
                  },
                  theme: ThemeData(
                    useMaterial3: true,
                    fontFamily: fontFamily,
                    appBarTheme: AppBarTheme(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      titleTextStyle: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: lightColorScheme.onSurface,
                      ),
                    ),
                    colorScheme: lightColorScheme,
                  ),
                  darkTheme: ThemeData(
                    useMaterial3: true,
                    fontFamily: fontFamily,
                    appBarTheme: AppBarTheme(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      titleTextStyle: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: darkColorScheme.onSurface,
                      ),
                    ),
                    colorScheme: darkColorScheme,
                  ),
                  themeMode: completeDarkness
                      ? ThemeMode.dark
                      : ThemeMode.light,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
