import 'package:json_annotation/json_annotation.dart';

import '../domain/models/block.dart';

part 'level_model.g.dart';

@JsonSerializable()
class LevelModel {
  final int id;
  final String difficulty;
  final int targetMoves;
  final List<BlockDto> blocks;

  LevelModel({
    required this.id,
    required this.difficulty,
    required this.targetMoves,
    required this.blocks,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) =>
      _$LevelModelFromJson(json);
  Map<String, dynamic> toJson() => _$LevelModelToJson(this);
}

@JsonSerializable()
class BlockDto {
  final String id;
  final int x;
  final int y;
  final int length;
  final String orientation; // 'h' or 'v'
  final bool isTarget;

  BlockDto({
    required this.id,
    required this.x,
    required this.y,
    required this.length,
    required this.orientation,
    this.isTarget = false,
  });

  factory BlockDto.fromJson(Map<String, dynamic> json) =>
      _$BlockDtoFromJson(json);
  Map<String, dynamic> toJson() => _$BlockDtoToJson(this);

  Block toDomain() {
    return Block(
      id: id,
      isTarget: isTarget,
      orientation: orientation.toLowerCase().startsWith('h')
          ? BlockOrientation.horizontal
          : BlockOrientation.vertical,
      length: length,
      row: y,
      col: x,
    );
  }
}
