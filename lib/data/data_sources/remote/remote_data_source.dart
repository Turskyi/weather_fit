import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:weather_fit/entities/weather.dart';
import 'package:weather_repository/weather_repository.dart';

class RemoteDataSource {
  const RemoteDataSource();

  Future<String> getImageUrlFromOpenAiAsFuture(Weather weather) =>
      OpenAI.instance.image.create(
        prompt: '''
A cartoonish drawing of a full-height person wearing a 
${weather.condition == WeatherCondition.clear ? 'light and '
                'breezy' : weather.condition == WeatherCondition.cloudy ? 'casual '
                'and cozy' : weather.condition == WeatherCondition.rainy ? 'waterproof '
                'and warm' : 'stylish and comfortable'} outfit for the weather 
                 with the temperature is 
                ${weather.formattedTemperature}''',
        n: 1,
        size: OpenAIImageSize.size512,
        responseFormat: OpenAIImageResponseFormat.url,
      ).then((OpenAIImageModel aiImage) {
        String? imageUrl = aiImage.data.firstOrNull?.url;
        return imageUrl ?? '';
      }).onError((Object? e, StackTrace stackTrace) {
        debugPrint(
          'Warning: an error occured in $this: $e;\nStackTrace: $stackTrace',
        );
        if (e is RequestFailedException) {
          throw Exception(e.message);
        } else {
          return '';
        }
      });
}
