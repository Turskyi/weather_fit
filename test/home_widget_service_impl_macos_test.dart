import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;
import 'package:weather_fit/services/home_widget_service_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.weatherfit.home_widget');
  const HomeWidgetServiceImpl service = HomeWidgetServiceImpl();

  final List<MethodCall> methodCalls = <MethodCall>[];

  setUp(() {
    methodCalls.clear();
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
  });
}
