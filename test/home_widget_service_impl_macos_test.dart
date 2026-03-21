import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;
import 'package:weather_fit/res/home_widget_keys.dart';
import 'package:weather_fit/services/home_widget_service_impl.dart';
import 'package:weather_repository/weather_repository.dart';

import 'helpers/mocks/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.weatherfit.home_widget');
  const HomeWidgetServiceImpl service = HomeWidgetServiceImpl();
  late MockOutfitRepository outfitRepository;

  final List<MethodCall> methodCalls = <MethodCall>[];

  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  setUp(() {
    methodCalls.clear();
    outfitRepository = MockOutfitRepository();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          methodCalls.add(call);
          if (call.method == 'setAppGroupId') {
            return null;
          }
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('HomeWidgetServiceImpl macOS bridge', () {
    test('setAppGroupId invokes platform channel on macOS', () async {
      if (!Platform.isMacOS) return;

      await service.setAppGroupId(constants.kAppleAppGroupId);

      expect(methodCalls, hasLength(1));
      expect(methodCalls.first.method, 'setAppGroupId');
      expect(methodCalls.first.arguments, <String, String>{
        'appGroupId': constants.kAppleAppGroupId,
      });
    });

    test('saveWidgetData invokes platform channel on macOS', () async {
      if (!Platform.isMacOS) return;

      final bool? result = await service.saveWidgetData<String>(
        'test_key',
        'v',
      );

      expect(result, isTrue);
      expect(methodCalls, hasLength(1));
      expect(methodCalls.first.method, 'saveWidgetData');
      expect(methodCalls.first.arguments, <String, Object>{
        'key': 'test_key',
        'value': 'v',
        'appGroupId': constants.kAppleAppGroupId,
      });
    });

    test('updateWidget invokes platform channel on macOS', () async {
      if (!Platform.isMacOS) return;

      final bool? result = await service.updateWidget();

      expect(result, isTrue);
      expect(methodCalls, hasLength(1));
      expect(methodCalls.first.method, 'updateWidget');
    });

    test(
      'updateHomeWidget writes macOS native refresh bootstrap data',
      () async {
        if (!Platform.isMacOS) return;

        SharedPreferences.setMockInitialValues(<String, Object>{
          'language_iso_code': 'en',
          'widget_update_frequency': 30,
        });
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        final LocalDataSource localDataSource = LocalDataSource(preferences);

        final DateTime now = DateTime.now();
        final DailyForecastDomain forecast = DailyForecastDomain(
          forecast: <ForecastItemDomain>[
            ForecastItemDomain(
              time: now.add(const Duration(hours: 1)).toIso8601String(),
              temperature: 10,
              weatherCode: 1,
            ),
            ForecastItemDomain(
              time: now.add(const Duration(hours: 4)).toIso8601String(),
              temperature: 12,
              weatherCode: 2,
            ),
            ForecastItemDomain(
              time: now.add(const Duration(hours: 8)).toIso8601String(),
              temperature: 8,
              weatherCode: 3,
            ),
          ],
        );

        final Weather weather = Weather(
          condition: WeatherCondition.clear,
          location: const Location(
            latitude: 50.45,
            longitude: 30.523,
            locale: 'en',
            name: 'Kyiv',
            countryCode: 'UA',
            country: 'Ukraine',
            province: 'Kyiv',
          ),
          temperature: const Temperature(value: 11),
          temperatureUnits: TemperatureUnits.celsius,
          countryCode: 'UA',
          description: 'Clear',
          code: 0,
          locale: 'en',
          lastUpdatedDateTime: now,
        );

        when(
          () => outfitRepository.getOutfitRecommendation(weather),
        ).thenReturn('Wear a light jacket');
        when(
          () => outfitRepository.downloadAndSaveImages(weather),
        ).thenAnswer((_) async => <String>['/tmp/outfit.png']);

        await service.updateHomeWidget(
          localDataSource: localDataSource,
          weather: weather,
          forecast: forecast,
          outfitRepository: outfitRepository as OutfitRepository,
        );

        final Iterable<Map<Object?, Object?>> saveCalls = methodCalls
            .where((MethodCall call) => call.method == 'saveWidgetData')
            .map(
              (MethodCall call) => (call.arguments as Map<Object?, Object?>),
            );

        bool hasSavedKey(String key) =>
            saveCalls.any((Map<Object?, Object?> args) => args['key'] == key);

        expect(hasSavedKey(HomeWidgetKey.locationLatitude.stringValue), isTrue);
        expect(
          hasSavedKey(HomeWidgetKey.locationLongitude.stringValue),
          isTrue,
        );
        expect(hasSavedKey(HomeWidgetKey.temperatureUnit.stringValue), isTrue);
        expect(
          hasSavedKey(HomeWidgetKey.widgetUpdateFrequency.stringValue),
          isTrue,
        );
      },
    );
  });
}
