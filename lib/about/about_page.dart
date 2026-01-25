import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/widgets/leading_widget.dart';
import 'package:weather_fit/router/app_route.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  bool get _showWidgetsFeature {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  // Helper to get the correct translation key for location support.
  String get _locationSupportKey {
    if (kIsWeb) {
      return 'about.feature_location_support_web';
    }
    if (Platform.isMacOS) {
      return 'about.feature_location_support_macos';
    }
    return 'about.feature_location_support_default';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    final List<String> features = <String>[
      translate('about.feature_outfit_suggestions'),
      translate('about.feature_location_forecast'),
      translate(_locationSupportKey),
      translate('about.feature_privacy_friendly'),
    ];

    if (_showWidgetsFeature) {
      features.add(translate('about.feature_home_widgets'));
    }

    return Scaffold(
      appBar: AppBar(
        leading: kIsWeb ? const LeadingWidget() : null,
        title: Text(
          '${translate('about.title')} «${translate('title')}»',
          maxLines: 2,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 12),
            Text(translate('app_description'), style: textTheme.bodyLarge),
            const SizedBox(height: 24),
            Text(
              '🌟 ${translate('features')}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(features.join('\n'), style: textTheme.bodyMedium),
            const SizedBox(height: 24),
            Text(
              '🎨 ${translate('artwork')}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText.rich(
              TextSpan(
                style: textTheme.bodyMedium,
                children: <InlineSpan>[
                  TextSpan(
                    text: '${translate("about.outfit_illustrations_in")} ',
                  ),
                  TextSpan(
                    text: translate('title'),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: ' ${translate('about.were_created_by')} '),
                  TextSpan(
                    text: translate('anna_turska'),
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(
                          Uri.parse(constants.artistInstagramUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                  ),
                  TextSpan(text: translate('about.artwork_artist_outro')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '🔒 ${translate('about.privacy_title')}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              translate(
                'about.privacy_description',
                args: <String, Object?>{'appName': translate('title')},
              ),
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.privacy_tip_outlined),
              label: Text(translate('about.view_privacy_policy')),
              onPressed: () => Navigator.pushNamed(
                context,
                defaultTargetPlatform == TargetPlatform.android
                    ? AppRoute.privacyPolicyAndroid.path
                    : AppRoute.privacyPolicy.path,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '📬 ${translate('support_and_feedback')}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              translate('about.support_description'),
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.chat),
              label: Text(translate('telegram_group')),
              onPressed: () => launchUrl(Uri.parse(constants.telegramUrl)),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              icon: const Icon(Icons.email_outlined),
              label: Text(translate('developer_contact_form')),
              onPressed: () =>
                  launchUrl(Uri.parse(constants.developerSupportUrl)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
