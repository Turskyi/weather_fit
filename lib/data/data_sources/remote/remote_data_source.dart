import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/weather.dart';
import 'package:weather_repository/weather_repository.dart';

class RemoteDataSource {
  const RemoteDataSource();

  Future<String> getImageUrlFromOpenAiAsFuture(Weather weather) =>
      OpenAI.instance.image.create(
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
