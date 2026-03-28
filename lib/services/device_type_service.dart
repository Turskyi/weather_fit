import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;

const MethodChannel _deviceChannel = MethodChannel(
  constants.kDeviceMethodChannel,
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
