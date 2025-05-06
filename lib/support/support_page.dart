import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/widgets/leading_widget.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: kIsWeb ? const LeadingWidget() : null,
        title: const Text('Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text(
              'WeatherFit Support',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Need help or want to give feedback? You’re in the right place.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Text(
              '📌 Frequently Asked Questions',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '• Why is there no hourly forecast?\n  '
              'Hourly weather is currently not supported, '
              'but may be added in the future.\n',
              style: textTheme.bodyMedium,
            ),
            Text(
              '• Can I change my location later?\n  '
              'Yes, the app lets you confirm and update your location during '
              'use.\n',
              style: textTheme.bodyMedium,
            ),
            Text(
              '• Why does the theme change at night?\n  '
              'The app automatically switches to a moon-themed dark mode '
              'between 11pm and 5am for a more natural look.\n',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Text(
              '📬 Contact Support',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'If you’re experiencing issues or have suggestions:',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _launchEmail(context),
              icon: const Icon(Icons.mail),
              label: const Text('Contact Us via Email'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse('https://t.me/+J3nrwxVrxVE2MDdi'),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.chat),
              label: const Text('Join Telegram Support Group'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse('https://${constants.developerDomain}/#/support'),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.web),
              label: const Text('Visit Support Page on Developer\'s Website'),
            ),
            const SizedBox(height: 32),
            Text(
              '📄 Legal & App Info',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('Developer: Dmytro Turskyi', style: textTheme.bodySmall),
            Text(
              'Email: ${constants.supportEmail}',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries.map(
      (MapEntry<String, String> entry) {
        return '${Uri.encodeComponent(entry.key)}='
            '${Uri.encodeComponent(entry.value)}';
      },
    ).join('&');
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@turskyi.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'WeatherFit Support',
        'body': 'Hi, I need help with...',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      final Uri fallbackUri = Uri.parse('https://turskyi.com/#/support');
      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch email or support page.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
