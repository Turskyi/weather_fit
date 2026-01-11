import 'package:flutter/material.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/weather/ui/weather_page.dart';

import '../constants.dart' as constants;

class LeadingWidget extends StatelessWidget {
  const LeadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Material(
          // Ensures the background remains unchanged.
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // TODO: change with route navigation or add a comment, why.
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (BuildContext _) {
                    return const WeatherPage();
                  },
                  settings: RouteSettings(name: AppRoute.weather.path),
                ),
                (Route<void> _) => false,
              );
            },
            child: SizedBox(
              height: kMinInteractiveDimension,
              width: kMinInteractiveDimension,
              child: Ink.image(
                image: const AssetImage('${constants.imagePath}logo.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
