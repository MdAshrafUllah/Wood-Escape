// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LevelModel _$LevelModelFromJson(Map<String, dynamic> json) => LevelModel(
  id: (json['id'] as num).toInt(),
  difficulty: json['difficulty'] as String,
  targetMoves: (json['targetMoves'] as num).toInt(),
  blocks: (json['blocks'] as List<dynamic>)
      .map((e) => BlockDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LevelModelToJson(LevelModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'difficulty': instance.difficulty,
      'targetMoves': instance.targetMoves,
      'blocks': instance.blocks,
    };

BlockDto _$BlockDtoFromJson(Map<String, dynamic> json) => BlockDto(
  id: json['id'] as String,
  x: (json['x'] as num).toInt(),
  y: (json['y'] as num).toInt(),
  length: (json['length'] as num).toInt(),
  orientation: json['orientation'] as String,
  isTarget: json['isTarget'] as bool? ?? false,
);

Map<String, dynamic> _$BlockDtoToJson(BlockDto instance) => <String, dynamic>{
  'id': instance.id,
  'x': instance.x,
  'y': instance.y,
  'length': instance.length,
  'orientation': instance.orientation,
  'isTarget': instance.isTarget,
};
