import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/extensions/http_response_extension.dart';

/// Service to handle in-app updates for Android and iOS.
abstract class UpdateService {
  /// Checks if an update is available and prompts the user to update.
  Future<void> checkForUpdate();
}

class UpdateServiceImpl implements UpdateService {
  const UpdateServiceImpl();

  @override
  Future<void> checkForUpdate() async {
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        await _checkAndroidUpdate();
      } else if (Platform.isIOS) {
        await _checkIosUpdate();
      }
    }
  }

  Future<void> _checkAndroidUpdate() async {
    try {
      final AppUpdateInfo info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        // For Android, we trigger an immediate update flow.
        // This will show a full-screen UI provided by Google Play.
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      debugPrint('Error checking for Android update: $e');
    }
  }

  Future<void> _checkIosUpdate() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String bundleId = packageInfo.packageName;
      final String currentVersion = packageInfo.version;

      final Uri url = Uri.parse('${constants.itunesLookupUrl}$bundleId');

      final http.Response response = await http.get(url);

      if (response.isOk) {
        final Object? decodedData = json.decode(response.body);
        if (decodedData is Map<String, Object?>) {
          final Object? results = decodedData['results'];

          if (results is List<Object?> && results.isNotEmpty) {
            final Object? firstResult = results.firstOrNull;

            if (firstResult is Map<String, Object?>) {
              final Object? storeVersion = firstResult['version'];
              final Object? trackViewUrl = firstResult['trackViewUrl'];

              if (storeVersion is String && trackViewUrl is String) {
                if (_isUpdateAvailable(currentVersion, storeVersion)) {
                  final Uri appStoreUri = Uri.parse(trackViewUrl);
                  final bool canLaunchAppStoreUrl = await canLaunchUrl(
                    appStoreUri,
                  );
                  if (canLaunchAppStoreUrl) {
                    await launchUrl(
                      appStoreUri,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking for iOS update: $e');
    }
  }

  bool _isUpdateAvailable(String currentVersion, String storeVersion) {
    try {
      final List<int> currentParts = currentVersion
          .split('.')
          .map(int.parse)
          .toList();
      final List<int> storeParts = storeVersion
          .split('.')
          .map(int.parse)
          .toList();

      for (int i = 0; i < storeParts.length; i++) {
        final int current = i < currentParts.length ? currentParts[i] : 0;
        final int store = storeParts[i];

        if (store > current) return true;
        if (store < current) return false;
      }
    } catch (e) {
      debugPrint('Error checking for update: $e');
      return false;
    }
    return false;
  }
}
