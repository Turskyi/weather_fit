import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weather_fit/privacy_policy/email_text.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/widgets/leading_widget.dart';
import 'package:weather_fit/utils/date_util.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final int age = 6;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double? titleSize = textTheme.titleLarge?.fontSize;
    final double? bodySize = textTheme.bodyLarge?.fontSize;
    return Scaffold(
      appBar: AppBar(
        leading: kIsWeb ? const LeadingWidget() : null,
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Last updated: $kPrivacyLastUpdatedDate',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              'Your privacy is important to us. It is ${constants.appName}\'s '
              'policy to respect your privacy and comply with any applicable '
              'law and regulation regarding any personal information we may '
              'collect about you, including across our app, '
              '${constants.appName}, and its associated services.',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              'Information We Collect',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We do not collect any personal information such as name, email '
              'address, or phone number.',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              'Location Data',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${constants.appName} may optionally request access to your '
              'device\'s approximate location. This access is only requested '
              'if the app cannot automatically determine your location based '
              'on your entered city name. You will be asked to grant '
              'permission before the app attempts to access your location.',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              'If you grant location permission, this data is used locally '
              'within the app to help find relevant weather information for '
              'your current location. This location data is not stored or '
              'transmitted anywhere outside of your device and is used only '
              'temporarily to find your current location. After finding '
              'weather for current location it is discarded. You can choose '
              'not to provide your location, in which case you can continue '
              'using the app by manually entering your city name.',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              'Third-Party Services',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${constants.appName} uses third-party services that may collect '
              'information used to identify you. These services include '
              'Firebase Crashlytics and Google Analytics. The data collected '
              'by these services is used to improve app stability and user '
              'experience. You can find more information about their privacy '
              'practices at their respective websites.',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              'Consent',
              style:
                  TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'By using our services, you consent to the collection and use of '
              'your information as described in this privacy policy.',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              'Platform-Specific Features',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${constants.appName} offers different features depending on the '
              'platform you are using (mobile, macOS, or web). Please note the '
              'following platform-specific details:',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              'Mobile (Android/iOS):',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'On mobile devices, ${constants.appName} provides visual outfit '
              'recommendations based on current weather conditions. These '
              'images are not generated in real time by AI, but instead are '
              'pre-drawn and stored locally within the app. No weather or user '
              'data is sent to external services to generate these outfits.',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              'macOS:',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'On macOS, the app uses approximate location (with permission) '
              'to provide local weather and corresponding outfit '
              'recommendations, similar to mobile. ',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              'On mobile and desktop platforms, outfit images are not '
              'generated in real time using AI. Instead, they are pre-drawn '
              'illustrations bundled with the app. Some of these assets may '
              'have been initially drafted or refined with the help of AI '
              'tools during the creative process, but no user data is shared '
              'with AI services during app usage.',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            Text(
              'Web:',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'On the web, ${constants.appName} displays both text and visual '
              'outfit recommendations, just like on mobile and desktop '
              'platforms. However, home screen widgets are not available on '
              'the web due to current technical limitations.',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              'Crashlytics',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${constants.appName} uses Firebase Crashlytics, a service by '
              'Google, to collect crash reports anonymously to help us improve '
              'app stability and fix bugs. The data collected by Crashlytics '
              'does not include any personal information.',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              'Children\'s Privacy',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Our services are not directed towards children under the age of '
              '$age. We do not knowingly collect personal information from '
              'children under $age. While we strive to minimize data '
              'collection, third-party services we use (such as Firebase '
              'Crashlytics and Google Analytics) may collect some data. '
              'However, this data is collected anonymously and is not linked '
              'to any personal information. If you believe that a child under '
              '$age has provided us with personal information, please contact '
              'us, and we will investigate the matter.',
              style: TextStyle(
                fontSize: bodySize,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '🎨 Image Attribution & Rights',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'All outfit illustrations in ${constants.appName} were created '
              'and edited by artist Anna Turska using a combination of '
              'original design work and AI-assisted drafts (e.g., Bing Image '
              'Creator). These images are bundled with the app and not fetched '
              'from any external source during use. All rights to the final '
              'images are reserved by the developer.',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'For any questions or concerns regarding your privacy, you may '
              'contact us using the following details:',
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
