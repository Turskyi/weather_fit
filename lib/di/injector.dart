import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:weather_fit/env/env.dart';
import 'package:weather_fit/weather_bloc_observer.dart';

Future<void> injectDependencies() async {
  // Initializes the package with that API key, all methods now are ready for
  // use.
  OpenAI.apiKey = Env.apiKey;
  OpenAI.showResponsesLogs = kDebugMode;
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const WeatherBlocObserver();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
}
