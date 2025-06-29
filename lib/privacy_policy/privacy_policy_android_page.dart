import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_fit/privacy_policy/email_text.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/widgets/leading_widget.dart';
import 'package:weather_fit/utils/date_util.dart';

class PrivacyPolicyAndroidPage extends StatelessWidget {
  const PrivacyPolicyAndroidPage({
    required this.languageIsoCode,
    super.key,
  });

  final String languageIsoCode;

  @override
  Widget build(BuildContext context) {
    final int age = 6;
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    final double? titleSize = textTheme.titleLarge?.fontSize;
    final double? bodySize = textTheme.bodyLarge?.fontSize;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${translate('privacy_policy')} ${kIsWeb ? '${translate('for')} '
              '«${translate('title')}» ${translate('android_app')}' : ''}',
        ),
        leading: kIsWeb ? const LeadingWidget() : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${translate('last_update')}: ${getPrivacyLastUpdatedDate(
                languageIsoCode,
              )}',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              translate(
                'privacy.policy_intro',
                args: <String, Object?>{'appName': translate('title')},
              ),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              translate('privacy.information_we_collect'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              translate('privacy.no_personal_data_collection'),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              translate('location'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              translate(
                'privacy.location_access_request',
                args: <String, Object?>{'appName': translate('title')},
              ),
              style: TextStyle(fontSize: bodySize),
            ),
            Text(
              translate('privacy.location_data_usage'),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              translate('third_party'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              translate(
                'privacy.third_party_services_info',
                args: <String, Object?>{'appName': translate('title')},
              ),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              translate('consent'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              translate('privacy.consent_agreement'),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              translate('privacy.security_measures'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              translate('privacy.security_measures_description'),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              translate('children_privacy'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              translate(
                'privacy.children_description',
                args: <String, Object?>{'age': age},
              ),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              translate('crashlytics'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              translate(
                'privacy.crashlytics_description',
                args: <String, Object?>{'appName': translate('title')},
              ),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              translate('ai_content'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              translate(
                'privacy.ai_content_description',
                args: <String, Object?>{'appName': translate('title')},
              ),
              style: TextStyle(fontSize: bodySize),
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: bodySize,
                  color: themeData.colorScheme.onSurface,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '${translate(
                      'privacy.outfit_illustrations_created_by',
                    )} ',
                  ),
                  TextSpan(
                    text: translate('anna_turska'),
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launchUrl(
                            Uri.parse(constants.artistInstagramUrl),
                          ),
                  ),
                  TextSpan(
                    text: translate('privacy.artwork_creation_method'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              translate('updates_and_notifications'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              translate('privacy.updates_and_notifications_description'),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              translate('contact_us'),
              style:
                  TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold),
            ),
            Text(
              translate('privacy.contact_us_invitation'),
              style: TextStyle(fontSize: bodySize),
            ),
            const EmailText(constants.supportEmail),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
