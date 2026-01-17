import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_fit/entities/enums/outfit_image_source.dart';

part 'outfit_image.g.dart';

@JsonSerializable()
class OutfitImage extends Equatable {
  const OutfitImage({required this.path, required this.source});

  const OutfitImage.empty() : path = '', source = OutfitImageSource.asset;

  factory OutfitImage.fromJson(Map<String, dynamic> json) =>
      _$OutfitImageFromJson(json);

  Map<String, dynamic> toJson() => _$OutfitImageToJson(this);

  final String path;
  final OutfitImageSource source;

  bool get isEmpty => path.isEmpty;

  bool get isNotEmpty => path.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[path, source];
}
