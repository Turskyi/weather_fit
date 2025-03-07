import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailText extends StatelessWidget {
  const EmailText(this.email, {super.key});

  final String email;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: SelectableText(
        'Email: $email',
        style: const TextStyle(fontSize: 16),
        onTap: () async {
          final Uri emailLaunchUri = Uri(
            scheme: 'mailto',
            path: email,
          );
          if (await canLaunchUrl(emailLaunchUri)) {
            await launchUrl(emailLaunchUri);
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Could not launch email app to send an email to $email',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
