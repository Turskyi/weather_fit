import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS Flutter deep linking is disabled', () {
    final File infoPlist = File('ios/Runner/Info.plist');

    expect(
      infoPlist.existsSync(),
      isTrue,
      reason: 'Expected ios/Runner/Info.plist to exist in project root.',
    );

    final String plistContent = infoPlist.readAsStringSync();

    expect(plistContent, contains('<key>FlutterDeepLinkingEnabled</key>'));

    final RegExp disabledDeepLinkingPattern = RegExp(
      r'<key>FlutterDeepLinkingEnabled</key>\s*<false\s*/>',
      multiLine: true,
    );

    expect(
      disabledDeepLinkingPattern.hasMatch(plistContent),
      isTrue,
      reason:
          'FlutterDeepLinkingEnabled must stay false to avoid duplicate '
          'route pushes when opening from iOS home widget.',
    );
  });
}
