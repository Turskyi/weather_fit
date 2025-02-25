import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GooglePlayBadge extends StatelessWidget {
  const GooglePlayBadge({
    super.key,
    required this.url,
    required this.assetPath,
  });

  final String url;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $url')),
          );
        }
      },
      child: Image.asset(assetPath, width: 240, height: 100),
    );
  }
}
