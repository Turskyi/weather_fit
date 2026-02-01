// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outfit_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutfitImage _$OutfitImageFromJson(Map<String, dynamic> json) => $checkedCreate(
  'OutfitImage',
  json,
  ($checkedConvert) {
    final val = OutfitImage(
      paths: $checkedConvert(
        'paths',
        (v) =>
            (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      ),
      source: $checkedConvert(
        'source',
        (v) => $enumDecode(_$OutfitImageSourceEnumMap, v),
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$OutfitImageToJson(OutfitImage instance) =>
    <String, dynamic>{
      'paths': instance.paths,
      'source': _$OutfitImageSourceEnumMap[instance.source]!,
    };

const _$OutfitImageSourceEnumMap = {
  OutfitImageSource.asset: 'asset',
  OutfitImageSource.file: 'file',
  OutfitImageSource.network: 'network',
};
