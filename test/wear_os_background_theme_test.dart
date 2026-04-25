import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_fit/app/weather_fit_app.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/data_sources/remote/remote_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/services/feedback_service.dart';
import 'package:weather_fit/services/home_widget_service.dart';
import 'package:weather_fit/services/update_service.dart';
import 'package:weather_repository/weather_repository.dart';

import 'helpers/flutter_translate_test_utils.dart';
import 'helpers/hydrated_bloc.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

class MockRemoteDataSource extends Mock implements RemoteDataSource {}

class MockHomeWidgetService extends Mock implements HomeWidgetService {}

class MockLocalDataSource extends Mock implements LocalDataSource {}

class MockFeedbackService extends Mock implements FeedbackService {}

class MockUpdateService extends Mock implements UpdateService {}

void main() {
  initHydratedStorage();

  late MockWeatherRepository mockWeatherRepository;
  late MockLocationRepository mockLocationRepository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockHomeWidgetService mockHomeWidgetService;
  late MockLocalDataSource mockLocalDataSource;
  late MockFeedbackService mockFeedbackService;
  late MockUpdateService mockUpdateService;
  late OutfitRepository outfitRepository;

  setUp(() {
    mockWeatherRepository = MockWeatherRepository();
    mockLocationRepository = MockLocationRepository();
    mockRemoteDataSource = MockRemoteDataSource();
    mockHomeWidgetService = MockHomeWidgetService();
    mockLocalDataSource = MockLocalDataSource();
    mockFeedbackService = MockFeedbackService();
    mockUpdateService = MockUpdateService();
    outfitRepository = OutfitRepository(
      mockLocalDataSource,
      mockRemoteDataSource,
    );

    when(() => mockLocalDataSource.getSavedLanguage()).thenReturn(Language.en);
    when(() => mockLocalDataSource.getWidgetUpdateFrequency()).thenReturn(120);
    when(() => mockLocalDataSource.getDayStartHour()).thenReturn(6);
    when(() => mockLocalDataSource.getNightStartHour()).thenReturn(20);
    when(
      () => mockLocalDataSource.getDebugWeatherProviderOpenWeatherMap(),
    ).thenReturn(false);
    when(
      () => mockLocalDataSource.isWeatherBackgroundEnabled(),
    ).thenReturn(true);
    when(
      () => mockLocalDataSource.getLastSavedLocation(),
    ).thenReturn(const Location.empty());
    when(
      () => mockLocalDataSource.getLastSearchedLocation(),
    ).thenReturn(const Location.empty());
    when(
      () => mockLocalDataSource.getFavouriteLocations(),
    ).thenReturn(<Location>[]);
    when(
      () => mockUpdateService.checkForUpdate(),
    ).thenAnswer((_) async => <Object?, Object?>{});
  });

  testWidgets('Wear OS (Extra Small) MUST have pure black background', (
    WidgetTester tester,
  ) async {
    // Simulate a small Wear OS device (e.g., 200x200)
    tester.view.physicalSize = const Size(200, 200);
    tester.view.devicePixelRatio = 1.0;

    final LocalizationDelegate localizationDelegate =
        await setUpFlutterTranslateForTests();

    final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
      AppRoute.weather.path: (BuildContext context) =>
          const Scaffold(body: Text('Weather')),
    };

    await tester.pumpWidget(
      LocalizedApp(
        localizationDelegate,
        WeatherFitApp(
          weatherRepository: mockWeatherRepository,
          locationRepository: mockLocationRepository,
          outfitRepository: outfitRepository,
          homeWidgetService: mockHomeWidgetService,
          localDataSource: mockLocalDataSource,
          feedbackService: mockFeedbackService,
          updateService: mockUpdateService,
          routes: routes,
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    // Find the Scaffold within the MaterialApp's builder/navigator
    final Finder scaffoldFinder = find.byType(Scaffold);
    expect(scaffoldFinder, findsOneWidget);

    final BuildContext scaffoldContext = tester.element(scaffoldFinder);
    final ThemeData theme = Theme.of(scaffoldContext);

    debugPrint(
      'TEST: theme.scaffoldBackgroundColor=${theme.scaffoldBackgroundColor}',
    );

    expect(
      theme.scaffoldBackgroundColor,
      Colors.black,
      reason: 'Scaffold background must be black on Wear OS',
    );
    expect(
      theme.colorScheme.surface,
      Colors.black,
      reason: 'Surface color must be black on Wear OS',
    );
    expect(
      theme.brightness,
      Brightness.dark,
      reason: 'Theme must be dark on Wear OS',
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
