import 'package:flutter/foundation.dart' as platform;
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
  if (_deviceTypeInitialized) {
    return;
  } else {
    _deviceTypeInitialized = true;

    if (kIsWeb || platform.defaultTargetPlatform != TargetPlatform.android) {
      return;
    } else {
      try {
        _isWearDevice =
            await _deviceChannel.invokeMethod<bool>(
              constants.kIsWearDeviceMethod,
            ) ??
            false;
      } on MissingPluginException catch (e) {
        debugPrint('MissingPluginException in initializeDeviceType: $e');
        _isWearDevice = false;
      } on PlatformException catch (e) {
        debugPrint('PlatformException in initializeDeviceType: $e');
        _isWearDevice = false;
      }
    }
  }
}

/// Triggers the native Wear OS input dialog (RemoteInput).
///
/// Returns the text entered by the user, or `null` if the user canceled.
Future<String?> openRemoteInput({String? label}) async {
  if (kIsWeb || platform.defaultTargetPlatform != TargetPlatform.android) {
    return null;
  } else {
    try {
      return await _deviceChannel.invokeMethod<String>(
        constants.kOpenRemoteInputMethod,
        <String, Object?>{'label': label},
      );
    } on MissingPluginException catch (e) {
      debugPrint('MissingPluginException in openRemoteInput: $e');
      return null;
    } on PlatformException catch (e) {
      debugPrint('PlatformException in openRemoteInput: $e');
      return null;
    }
  }
}
