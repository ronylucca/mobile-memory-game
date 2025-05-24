import 'package:flutter/material.dart';

class CardModel {
  final int id;
  final String imagePath;
  final String theme;
  final int pairId;
  bool isFlipped;
  bool isMatched;
  int? matchedByPlayer; // ID do jogador que fez o match (0 ou 1)

  CardModel({
    required this.id,
    required this.imagePath,
    required this.theme,
    required this.pairId,
    this.isFlipped = false,
    this.isMatched = false,
    this.matchedByPlayer,
  });

  CardModel copyWith({
    int? id,
    String? imagePath,
    String? theme,
    int? pairId,
    bool? isFlipped,
    bool? isMatched,
    int? matchedByPlayer,
  }) {
    return CardModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      theme: theme ?? this.theme,
      pairId: pairId ?? this.pairId,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
      matchedByPlayer: matchedByPlayer ?? this.matchedByPlayer,
    );
  }
} 