import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';

class RemoteDataSource {
  RemoteDataSource();

  Future<String> getImageUrlFromOpenAiAsFuture(Weather weather) async {
    if (kDebugMode) {
      final String dummyImageUrl = _dummyImageUrls[_dummyImageUrlIndex];

      _dummyImageUrlIndex = (_dummyImageUrlIndex + 1) % _dummyImageUrls.length;
      await Future<void>.delayed(const Duration(seconds: 2));
      return dummyImageUrl;
    } else {
      return OpenAI.instance.image.create(
        prompt: '''
Create a cartoon-style drawing of a full-height person wearing an outfit suitable for ${weather.condition.toString().toLowerCase()} weather with a temperature of ${weather.temperature.value}°${weather.temperatureUnits.isCelsius ? 'C' : 'F'}. 
The outfit should be ${weather.condition.isClear ? 'light and breezy' : weather.condition.isCloudy ? 'comfortable and light' : weather.condition.isRainy ? 'waterproof and warm' : 'stylish and comfortable'}.
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

  int _dummyImageUrlIndex = 0;
}
