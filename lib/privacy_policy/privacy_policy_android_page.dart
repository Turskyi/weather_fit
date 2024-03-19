import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_fit/privacy_policy/email_text.dart';

class PrivacyPolicyAndroidPage extends StatelessWidget {
  const PrivacyPolicyAndroidPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy ${kIsWeb ? 'for "WeatherFit" Android '
              'Application' : ''}',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Last updated: ${_formatDate(
                DateTime(2024, DateTime.march, 19),
              )}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your privacy is important to us. It is WeatherFit\'s policy to '
              'respect your privacy and comply with any applicable law and '
              'regulation regarding any personal information we may collect '
              'about you, including across our app, WeatherFit, and its '
              'associated services.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Information We Collect',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'We do not collect any personal information such as name, email '
              'address, or phone number. However, to provide weather '
              'information for your current location, we do request access to '
              'your device\'s location data.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Data Usage and Retention',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'The location data you allow us to access is used solely to '
              'display the weather forecast relevant to your city. This data '
              'is not used for any other purpose and is not stored on our '
              'servers.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Permissions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'WeatherFit requires the following permissions to function '
              'properly:\n\u2022 Location: This permission is necessary to '
              'determine your current location and display the most relevant '
              'weather forecast.\n\u2022 Background Location: This permission '
              'is used to '
              'refresh the weather information on the home widget even when '
              'the app is not actively running.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Crashlytics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'WeatherFit uses Firebase Crashlytics, a service by Google, to '
              'collect crash reports anonymously to help us improve app '
              'stability and fix bugs. The data collected by Crashlytics does '
              'not include any personal information.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Updates and Notification',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'This privacy policy may be updated periodically. Any changes '
              'to the policy will be communicated to you through app updates '
              'or notifications.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'For any questions or concerns regarding your privacy, you may '
              'contact us using the following details:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const EmailText('dmytro@turskyi.com'),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yMMMMd');
    return formatter.format(date);
  }
}
