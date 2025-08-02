import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/privacy_policy/email_text.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/widgets/leading_widget.dart';
import 'package:weather_fit/utils/date_util.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({required this.languageIsoCode, super.key});

  final String languageIsoCode;

  @override
  Widget build(BuildContext context) {
    final int age = 6;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double? titleSize = textTheme.titleLarge?.fontSize;
    final double? bodySize = textTheme.bodyLarge?.fontSize;
    final String updatedDate = getPrivacyLastUpdatedDate(languageIsoCode);
    return Scaffold(
      appBar: AppBar(
        leading: kIsWeb
            ? LeadingWidget(languageIsoCode: languageIsoCode)
            : null,
        title: Text(translate('privacy_policy')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              translate('privacy_policy'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${translate('last_updated')}: $updatedDate',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              translate(
                'privacy.policy_intro',
                args: <String, Object?>{'appName': translate('title')},
              ),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              translate('privacy.information_we_collect'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              translate('privacy.no_personal_data_collection'),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              translate('location'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              translate(
                'privacy.location_access_request',
                args: <String, Object?>{'appName': translate('title')},
              ),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              translate('privacy.location_data_usage'),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              translate('third_party'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              translate(
                'privacy.third_party_services_info',
                args: <String, Object?>{'appName': translate('title')},
              ),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              translate('consent'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              translate('privacy.consent_agreement'),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              translate('platform_specific'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              translate(
                'privacy.platform_specific_intro',
                args: <String, Object?>{'appName': translate('title')},
              ),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              '${translate('mobile')}:',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              translate(
                'privacy.platform_mobile_description',
                args: <String, Object?>{'appName': translate('title')},
              ),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              '${translate('macos')}:',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              translate('privacy.platform_macos_description'),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              translate('privacy.platform_image_generation_explanation'),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              '${translate('web')}:',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              translate(
                'privacy.platform_web_description',
                args: <String, Object?>{'appName': translate('title')},
              ),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              translate('crashlytics'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              translate(
                'privacy.crashlytics_description',
                args: <String, Object?>{'appName': translate('title')},
              ),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              translate('children_privacy'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              translate(
                'privacy.children_description',
                args: <String, Object?>{'age': age},
              ),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 24),
            Text(
              '🎨 ${translate('image_attribution_and_rights_title')}',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              translate(
                'privacy.image_attribution_and_rights_description',
                args: <String, Object?>{'appName': translate('title')},
              ),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              translate('contact_us'),
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              translate('privacy.contact_us_invitation'),
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            const EmailText(constants.supportEmail),
          ],
        ),
      ),
    );
  }
}
