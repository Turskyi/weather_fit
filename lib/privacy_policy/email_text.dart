import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_fit/res/constants.dart' as constants;

class EmailText extends StatelessWidget {
  const EmailText(this.email, {super.key});

  final String email;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: SelectableText(
        '${translate('email')}: $email',
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
        ),
        onTap: () async {
          final Uri emailLaunchUri = Uri(
            scheme: constants.mailToScheme,
            path: email,
          );
          if (await canLaunchUrl(emailLaunchUri)) {
            await launchUrl(emailLaunchUri);
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  translate(
                    'error.launch_email_app_to_address',
                    args: <String, Object?>{'emailAddress': email},
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
