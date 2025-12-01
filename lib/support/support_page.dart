import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/widgets/leading_widget.dart';
import 'package:weather_fit/widgets/language_selector.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({required this.languageIsoCode, super.key});

  final String languageIsoCode;

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: kIsWeb
            ? LeadingWidget(languageIsoCode: widget.languageIsoCode)
            : null,
        title: Text(translate('support.title')),
        actions: <Widget>[
          LanguageSelector(
            // Update state of the whole page to show text from another
            // language.
            onLanguageSelected: () => setState(() {}),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text(
              '«${translate('title')}» ${translate('support.title')}',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(translate('support.intro_line'), style: textTheme.bodyLarge),
            const SizedBox(height: 32),
            Text(
              '📌 ${translate('faq')}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: textTheme.bodyMedium,
                children: <TextSpan>[
                  TextSpan(
                    text: '${translate('support.faq_hourly_forecast_q')}\n  ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${translate('support.faq_hourly_forecast_a')}\n',
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: textTheme.bodyMedium,
                children: <TextSpan>[
                  TextSpan(
                    text: '${translate('support.faq_change_location_q')}\n  ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${translate('support.faq_change_location_a')}\n',
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: textTheme.bodyMedium,
                children: <TextSpan>[
                  TextSpan(
                    text: '${translate('support.faq_theme_change_q')}\n  ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${translate('support.faq_theme_change_a')}\n',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '📬 ${translate('contact_support')}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              translate('support.contact_intro'),
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _launchEmail(context),
              icon: const Icon(Icons.mail),
              label: Text(translate('support.contact_us_via_email_button')),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(constants.telegramUrl),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.chat),
              label: Text(translate('support.join_telegram_support_button')),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(constants.developerSupportUrl),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.web),
              label: Text(
                translate('support.visit_developer_support_website_button'),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              translate('legal_and_app_info_title'),
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${translate('developer')}: ${translate('developer_name')}',
              style: textTheme.bodySmall,
            ),
            InkWell(
              onTap: () => launchUrl(
                Uri(
                  scheme: constants.mailToScheme,
                  path: constants.supportEmail,
                ),
              ),
              child: SelectableText(
                '${translate('email')}: ${constants.supportEmail}',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> entry) {
          return '${Uri.encodeComponent(entry.key)}='
              '${Uri.encodeComponent(entry.value)}';
        })
        .join('&');
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: constants.mailToScheme,
      path: constants.supportEmail,
      query: _encodeQueryParameters(<String, String>{
        constants.subjectParameter:
            '«${translate('title')}» ${translate('support.title')}',
        constants.bodyParameter: translate('support.email_default_body'),
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      final Uri fallbackUri = Uri.parse(constants.developerSupportUrl);
      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate('error.launch_email_or_support_page')),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
