import 'dart:math';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart';

class RemoteDataSource {
  const RemoteDataSource();

  Future<String> getImageUrlFromOpenAiAsFuture(Weather weather) {
    if (kDebugMode) {
      final Random random = Random();
      final int randomIndex = random.nextInt(_dummyImageUrls.length);
      print('Deb: randomIndex: $randomIndex');
      return Future<String>.value(_dummyImageUrls[randomIndex]);
    } else {
      return OpenAI.instance.image.create(
        prompt: '''
Create a cartoon-style drawing of a full-height person wearing an outfit suitable for ${weather.condition.toString().toLowerCase()} weather with a temperature of ${weather.temperature.value}°${weather.temperatureUnits == TemperatureUnits.celsius ? 'C' : 'F'}. 
The outfit should be ${weather.condition == WeatherCondition.clear ? 'light and breezy' : weather.condition == WeatherCondition.cloudy ? 'comfortable and light' : weather.condition == WeatherCondition.rainy ? 'waterproof and warm' : 'stylish and comfortable'}.
Avoid adding any extra accessories like scarves or heavy jackets unless it is below 15°C.''',
        n: 1,
        size: OpenAIImageSize.size512,
      ).then((OpenAIImageModel aiImage) {
        final String? imageUrl = aiImage.data.firstOrNull?.url;
        return imageUrl ?? '';
      }).onError((Object? e, StackTrace stackTrace) {
        debugPrint(
          'Warning: an error occurred in $this: $e;\nStackTrace: $stackTrace',
        );
        if (e is RequestFailedException) {
          throw Exception(e.message);
        } else {
          return '';
        }
      });
    }
  }

  final List<String> _dummyImageUrls = const <String>[
    'https://cdn.tatlerasia.com/tatlerasia/i/2022/03/25170240-benjamin-rcgd-sketch_cover_1125x1500.jpg',
    'https://cdn.greenvelope.com/blog/wp-content/uploads/beach-formal-or-garden-attire.jpg',
    'https://i.pinimg.com/736x/6b/e7/30/6be73098da8d78fb665dee9d356fbccd.jpg',
    'https://thumbs.dreamstime.com/b/hand-drawn-beautiful-young-woman-bag-fashion-look-stylish-girl-walking-paris-street-background-black-feather-jacket-sketch-175096613.jpg',
  ];
}
