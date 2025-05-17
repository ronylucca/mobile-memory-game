class PlayerModel {
  final int id;
  final String name;
  int score;
  bool isCurrentTurn;

  PlayerModel({
    required this.id,
    required this.name,
    this.score = 0,
    this.isCurrentTurn = false,
  });

  PlayerModel copyWith({
    int? id,
    String? name,
    int? score,
    bool? isCurrentTurn,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      isCurrentTurn: isCurrentTurn ?? this.isCurrentTurn,
    );
  }
} 