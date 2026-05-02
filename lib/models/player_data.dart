import 'dart:ui';

import 'package:equatable/equatable.dart';

final class PlayerData extends Equatable {
  final String name;
  final int score;
  final Color color;

  @override
  List<Object?> get props => [name, score, color];

  const PlayerData({
    required this.name,
    required this.score,
    required this.color,
  });

  PlayerData copyWith({
    String? name,
    int? score,
    Color? color,
  }) {
    return PlayerData(
      name: name ?? this.name,
      score: score ?? this.score,
      color: color ?? this.color,
    );
  }
}
