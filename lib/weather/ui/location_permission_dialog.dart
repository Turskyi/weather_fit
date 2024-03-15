import 'package:flutter/material.dart';

class LocationPermissionDialog extends StatefulWidget {
  const LocationPermissionDialog({super.key});

  @override
  State<LocationPermissionDialog> createState() =>
      _LocationPermissionDialogState();
}

class _LocationPermissionDialogState extends State<LocationPermissionDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Location Permission'),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
                'WeatherFit collects location data to enable "weather updates" '
                'and "outfit recommendations" even when the app is closed or '
                'not in use.'),
            // Include any other details necessary to make it clear to the user.
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Decline'),
        ),
        TextButton(
          child: const Text('Agree'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
