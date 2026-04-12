import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/services/feedback_service.dart';
import 'package:weather_fit/services/update_service.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';

import 'helpers/flutter_translate_test_utils.dart';

class MockLocalDataSource extends Mock implements LocalDataSource {}

class MockUpdateService extends Mock implements UpdateService {}

class MockFeedbackService extends Mock implements FeedbackService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocalDataSource localDataSource;
  late MockUpdateService updateService;
  late MockFeedbackService feedbackService;

  setUpAll(() async {
    await setUpFlutterTranslateForTests();
    PackageInfo.setMockInitialValues(
      appName: 'WeatherFit',
      packageName: 'com.example.weather_fit',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: 'test',
    );
  });

  setUp(() {
    localDataSource = MockLocalDataSource();
    updateService = MockUpdateService();
    feedbackService = MockFeedbackService();

    when(() => localDataSource.getSavedLanguage()).thenReturn(Language.en);
    when(() => localDataSource.getWidgetUpdateFrequency()).thenReturn(120);
    when(() => localDataSource.getDayStartHour()).thenReturn(6);
    when(() => localDataSource.getNightStartHour()).thenReturn(22);
    when(
      () => localDataSource.getDebugWeatherProviderOpenWeatherMap(),
    ).thenReturn(false);
    when(() => updateService.checkForUpdate()).thenAnswer((_) async {});
  });

  group('SettingsBloc change language', () {
    test('returns to initial state with new language after saving from error '
        'state', () async {
      when(
        () => localDataSource.saveLanguageIsoCode(Language.uk.isoLanguageCode),
      ).thenAnswer((_) async => true);

      final SettingsBloc bloc = SettingsBloc(
        localDataSource,
        updateService,
        feedbackService,
      );
      await _waitForInitialLoad(bloc);

      bloc.add(const SettingsErrorEvent('boom'));
      await _flushEvents();

      bloc.add(const ChangeLanguageEvent(Language.uk));
      await _flushEvents();

      expect(bloc.state, isA<SettingsInitial>());
      expect(bloc.state.language, Language.uk);
      verify(
        () => localDataSource.saveLanguageIsoCode(Language.uk.isoLanguageCode),
      ).called(1);

      await bloc.close();
    });

    test(
      'emits a settings error when saving the selected language fails',
      () async {
        when(
          () =>
              localDataSource.saveLanguageIsoCode(Language.uk.isoLanguageCode),
        ).thenAnswer((_) async => false);

        final SettingsBloc bloc = SettingsBloc(
          localDataSource,
          updateService,
          feedbackService,
        );
        await _waitForInitialLoad(bloc);

        bloc.add(const ChangeLanguageEvent(Language.uk));
        await _flushEvents();

        expect(bloc.state, isA<SettingsError>());
        expect(bloc.state.language, Language.en);
        expect(
          (bloc.state as SettingsError).errorMessage,
          translate('error.unexpected_error'),
        );
        verify(
          () =>
              localDataSource.saveLanguageIsoCode(Language.uk.isoLanguageCode),
        ).called(1);

        await bloc.close();
      },
    );
  });
}

Future<void> _waitForInitialLoad(SettingsBloc bloc) async {
  for (int i = 0; i < 10 && bloc.state.appVersion == null; i++) {
    await _flushEvents();
  }
}

Future<void> _flushEvents() async {
  await Future<void>.delayed(Duration.zero);
}
