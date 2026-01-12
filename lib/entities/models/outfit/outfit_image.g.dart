// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outfit_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutfitImage _$OutfitImageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OutfitImage', json, ($checkedConvert) {
      final val = OutfitImage(
        path: $checkedConvert('path', (v) => v as String),
        source: $checkedConvert(
          'source',
          (v) => $enumDecode(_$OutfitImageSourceEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$OutfitImageToJson(OutfitImage instance) =>
    <String, dynamic>{
      'path': instance.path,
      'source': _$OutfitImageSourceEnumMap[instance.source]!,
    };

const _$OutfitImageSourceEnumMap = {
  OutfitImageSource.asset: 'asset',
  OutfitImageSource.file: 'file',
};
