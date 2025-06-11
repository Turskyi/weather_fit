import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_fit/privacy_policy/email_text.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/widgets/leading_widget.dart';
import 'package:weather_fit/utils/date_util.dart';

class PrivacyPolicyAndroidPage extends StatelessWidget {
  const PrivacyPolicyAndroidPage({super.key});

  @override
  Widget build(BuildContext context) {
    final int age = 6;
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    final double? titleSize = textTheme.titleLarge?.fontSize;
    final double? bodySize = textTheme.bodyLarge?.fontSize;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy ${kIsWeb ? 'for "${constants.appName}" Android '
              'Application' : ''}',
        ),
        leading: kIsWeb ? const LeadingWidget() : null,
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
              'device\'s approximate location (coarse location). This access '
              'is only requested if the app cannot automatically determine '
              'your location based on your entered city name. You will be '
              'asked to grant permission before the app attempts to access '
              'your location.',
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
              'Security Measures',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We take reasonable measures to protect your information from '
              'unauthorized access, disclosure, or modification.',
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
              'AI-Generated Content',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${constants.appName} no longer uses artificial intelligence '
              '(AI) to generate outfit images in real time. Instead, all '
              'images are now pre-drawn and bundled with the app. While some '
              'images may have been assisted by AI tools during the design '
              'process, no user data is sent to external AI services during '
              'usage.\n\nIf you have concerns or wish to provide feedback on '
              'any content, please use the "Feedback" option in the app’s '
              'settings.',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: bodySize,
                  color: themeData.colorScheme.onSurface,
                ),
                children: <TextSpan>[
                  const TextSpan(text: 'Outfit illustrations were created by '),
                  TextSpan(
                    text: 'Anna Turska',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launchUrl(
                            Uri.parse(
                              'https://www.instagram.com/anartistart/',
                            ),
                          ),
                  ),
                  const TextSpan(
                    text: ', using a mix of hand-drawn elements and AI tools.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Updates and Notification',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This privacy policy may be updated periodically. Any changes '
              'to the policy will be communicated to you through app updates '
              'or notifications.',
              style: TextStyle(fontSize: bodySize),
            ),
            const SizedBox(height: 20),
            Text(
              'Contact Us',
              style:
                  TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold),
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
