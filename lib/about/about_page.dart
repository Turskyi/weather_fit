import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: kIsWeb ? const LeadingWidget() : null,
        title: const Text('About ${constants.appName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: <Widget>[
            Text(
              constants.appName,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your stylish weather companion.',
              style: textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${constants.appName} helps you dress for the weather with '
              'carefully crafted outfit suggestions. Just enter a location, '
              'and the app will show you the current forecast along with a '
              'visual and text-based recommendation on what to wear.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              '🌟 Features',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Outfit suggestions based on weather\n'
              '• Location-based weather forecast\n'
              '• ${_getLocationSupportText()}\n'
              '• Privacy-friendly (no tracking, no accounts)'
              '${_showWidgetsFeature ? '\n'
                  '• Home screen widgets for mobile devices' : ''}',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              '🎨 Artwork',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: textTheme.bodyMedium,
                children: <InlineSpan>[
                  const TextSpan(text: 'The outfit illustrations in '),
                  TextSpan(
                    text: constants.appName,
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' were hand-drawn by artist '),
                  TextSpan(
                    text: 'Anna Turska',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(
                          Uri.parse('https://www.instagram.com/anartistart/'),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                  ),
                  const TextSpan(
                    text: ', whose style brings charm and personality to the '
                        'app.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '🔒 Privacy & Data',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${constants.appName} does not collect or store any personal '
              'data. Your approximate location is used only to show the local '
              'weather and is never shared. Outfit suggestions are generated '
              'on-device based on the weather conditions. You can read the '
              'full privacy policy below.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.privacy_tip_outlined),
              label: const Text('View Privacy Policy'),
              onPressed: () => Navigator.pushNamed(
                context,
                defaultTargetPlatform == TargetPlatform.android
                    ? AppRoute.privacyPolicyAndroid.path
                    : AppRoute.privacyPolicy.path,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '📬 Support & Feedback',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Having trouble? Need help or want to suggest a feature? '
              'Join the community or contact the developer directly.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('Telegram Support Group'),
              onPressed: () => launchUrl(
                Uri.parse('https://t.me/+J3nrwxVrxVE2MDdi'),
              ),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              icon: const Icon(Icons.email_outlined),
              label: const Text('Developer Contact Form'),
              onPressed: () => launchUrl(
                Uri.parse('https://${constants.developerDomain}/#/support'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getLocationSupportText() {
    if (kIsWeb) {
      return 'Approximate location support (browser permission required)';
    }
    if (Platform.isMacOS) {
      return 'Approximate location support (location permission required)';
    }
    return 'Approximate location support (no GPS required)';
  }
}
