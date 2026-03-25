import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const MethodChannel _deviceChannel = MethodChannel(
  'com.turskyi.weather_fit/device',
);

bool _isWearDevice = false;
bool _deviceTypeInitialized = false;

bool get nativeWearDevice => _isWearDevice;

Future<void> initializeDeviceType() async {
  if (_deviceTypeInitialized) return;
  _deviceTypeInitialized = true;

  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

  try {
    _isWearDevice =
        await _deviceChannel.invokeMethod<bool>('isWearDevice') ?? false;
  } on MissingPluginException {
    _isWearDevice = false;
  } on PlatformException {
    _isWearDevice = false;
  }
}
