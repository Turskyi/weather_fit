import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Service to handle in-app updates for Android.
abstract class UpdateService {
  /// Checks if an update is available and prompts the user to update.
  Future<void> checkForUpdate();
}

class UpdateServiceImpl implements UpdateService {
  const UpdateServiceImpl();

  @override
  Future<void> checkForUpdate() async {
    // In-app updates are only supported on Android.
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      final AppUpdateInfo info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        // For Android, we trigger an immediate update flow.
        // This will show a full-screen UI provided by Google Play.
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      debugPrint('Error checking for update: $e');
    }
  }
}
