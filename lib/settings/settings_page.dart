import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/res/widgets/background.dart';
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
                        // isThreeLine: true,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
