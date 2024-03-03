import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_fit/search/search_page.dart';
import 'package:weather_fit/settings/settings_page.dart';
import 'package:weather_fit/theme/cubit/theme_cubit.dart';
import 'package:weather_fit/weather/cubit/weather_cubit.dart';
import 'package:weather_fit/weather/ui/weather_empty.dart';
import 'package:weather_fit/weather/ui/weather_error.dart';
import 'package:weather_fit/weather/ui/weather_loading.dart';
import 'package:weather_fit/weather/ui/weather_populated.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  @override
  void initState() {
    super.initState();
    Permission.location.request().then((PermissionStatus status) {
// Check if permission is granted
      if (status.isGranted) {
        // Get the current position of the device.
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
            .then((Position position) {
          // Geocode the coordinates and get a `Placemark` object.
          try {
            placemarkFromCoordinates(position.latitude, position.longitude)
                .then((List<Placemark> placemarks) {
              if (placemarks.isNotEmpty && placemarks.first.locality != null) {
                // Assign the city name to the variable.
                String city = placemarks.first.locality!;
                context.read<WeatherCubit>().fetchWeather(city);
              }
            });
          } catch (err) {
            throw Exception(err);
          }
        });
      } else {
        // Permission is denied, handle accordingly
        // Show a snackbar with a message and a button
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Location permission is required for this app.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                // Open the app settings page.
                openAppSettings();
              },
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push<void>(
                SettingsPage.route(context.read<WeatherCubit>()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: BlocConsumer<WeatherCubit, WeatherState>(
          listener: (BuildContext context, WeatherState state) {
            if (state.status.isSuccess) {
              context.read<ThemeCubit>().updateTheme(state.weather);
            }
          },
          builder: (BuildContext context, WeatherState state) {
            switch (state.status) {
              case WeatherStatus.initial:
                return const WeatherEmpty();
              case WeatherStatus.loading:
                if (state.weather.location.isEmpty) {
                  return const WeatherLoading();
                } else {
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      WeatherPopulated(
                        weather: state.weather,
                        units: state.temperatureUnits,
                        onRefresh: () {
                          return context.read<WeatherCubit>().refreshWeather();
                        },
                      ),
                      const WeatherLoading(),
                    ],
                  );
                }
              case WeatherStatus.success:
                return WeatherPopulated(
                  weather: state.weather,
                  units: state.temperatureUnits,
                  onRefresh: () {
                    return context.read<WeatherCubit>().refreshWeather();
                  },
                );
              case WeatherStatus.failure:
                return const WeatherError();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search, semanticLabel: 'Search'),
        onPressed: () async {
          final Object? city =
              await Navigator.of(context).push(SearchPage.route());
          if (context.mounted && city is String) {
            await context.read<WeatherCubit>().fetchWeather(city);
          } else {
            return;
          }
        },
      ),
    );
  }
}
