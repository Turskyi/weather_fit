import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_fit/entities/enums/outfit_image_source.dart';

part 'outfit_image.g.dart';

@JsonSerializable()
class OutfitImage extends Equatable {
  const OutfitImage({required this.paths, required this.source});

  const OutfitImage.empty()
    : paths = const <String>[],
      source = OutfitImageSource.asset;

  factory OutfitImage.fromJson(Map<String, Object?> json) {
    return _$OutfitImageFromJson(json);
  }

  Map<String, Object?> toJson() => _$OutfitImageToJson(this);

  final List<String> paths;
  final OutfitImageSource source;

  bool get isEmpty => paths.isEmpty;

  bool get isNotEmpty => paths.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[paths, source];
}
