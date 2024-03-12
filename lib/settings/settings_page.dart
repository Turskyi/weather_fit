import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/settings/google_play_badge.dart';
import 'package:weather_fit/weather/cubit/weather_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Settings')),
      body: Stack(
        children: <Widget>[
          const Background(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              children: <Widget>[
                BlocBuilder<WeatherCubit, WeatherState>(
                  buildWhen: (WeatherState previous, WeatherState current) =>
                      previous.weather.temperatureUnits !=
                      current.weather.temperatureUnits,
                  builder: (BuildContext context, WeatherState state) {
                    return Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        title: const Text(
                          'Temperature Units',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Use metric measurements for temperature units.',
                        ),
                        trailing: Switch(
                          value: state.weather.temperatureUnits.isCelsius,
                          onChanged: (_) =>
                              context.read<WeatherCubit>().toggleUnits(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    title: const Text(
                      'Privacy Policy',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const SizedBox(),
                    trailing: const Icon(Icons.privacy_tip),
                    onTap: () => Navigator.pushNamed(
                      context,
                      Platform.isAndroid
                          ? AppRoute.privacyPolicyAndroid.path
                          : AppRoute.privacyPolicy.path,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor:
          Theme.of(context).colorScheme.primaryContainer.brighten(50),
      bottomNavigationBar: kIsWeb
          ? const GooglePlayBadge(
              url:
                  'https://play.google.com/store/apps/details?id=com.turskyi.weather_fit',
              assetPath:
                  'https://play.google.com/intl/en_gb/badges/static/images/badges/en_badge_web_generic.png',
            )
          : null,
    );
  }
}
