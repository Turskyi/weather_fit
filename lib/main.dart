import 'package:flutter/material.dart';
import 'package:weather_fit/data/data_sources/remote/remote_data_source.dart';
import 'package:weather_fit/data/repositories/ai_repository.dart';
import 'package:weather_fit/di/injector.dart';
import 'package:weather_fit/weather_app.dart';
import 'package:weather_repository/weather_repository.dart';

/// The [main] is the ultimate detail — the lowest-level policy.
/// It is the initial entry point of the system.
/// Nothing, other than the operating system, depends on it.
/// Here you should [injectDependencies].
/// Think of [main] as a plugin to the [WeatherApp] — a plugin that sets up
/// the initial conditions and configurations, gathers all the outside
/// resources, and then hands control over to the high-level policy of the
/// [WeatherApp].
/// When [main] is released, it has utterly no effect on any of the other
/// components in the system. They don’t know about [main], and they don’t care
/// when it changes.
void main() async {
  await injectDependencies();
  runApp(
    WeatherApp(
      weatherRepository: WeatherRepository(),
      aiRepository: const AiRepository(RemoteDataSource()),
    ),
  );
}
