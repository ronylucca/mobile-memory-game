import 'package:mobile_memory_game/models/card_model.dart';
import 'package:mobile_memory_game/models/player_model.dart';
import 'package:mobile_memory_game/models/theme_model.dart';

enum GameStatus { notStarted, inProgress, paused, completed }

class GameModel {
  final String id;
  final List<CardModel> cards;
  final List<PlayerModel> players;
  final ThemeModel theme;
  final GameStatus status;
  final int currentPlayerIndex;
  final int totalMoves;
  final int selectedCardIndex;

  GameModel({
    required this.id,
    required this.cards,
    required this.players,
    required this.theme,
    this.status = GameStatus.notStarted,
    this.currentPlayerIndex = 0,
    this.totalMoves = 0,
    this.selectedCardIndex = -1,
  });

  GameModel copyWith({
    String? id,
    List<CardModel>? cards,
    List<PlayerModel>? players,
    ThemeModel? theme,
    GameStatus? status,
    int? currentPlayerIndex,
    int? totalMoves,
    int? selectedCardIndex,
  }) {
    return GameModel(
      id: id ?? this.id,
      cards: cards ?? this.cards,
      players: players ?? this.players,
      theme: theme ?? this.theme,
      status: status ?? this.status,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      totalMoves: totalMoves ?? this.totalMoves,
      selectedCardIndex: selectedCardIndex ?? this.selectedCardIndex,
    );
  }

  PlayerModel get currentPlayer => players[currentPlayerIndex];

  bool get isGameCompleted =>
      cards.every((card) => card.isMatched) || status == GameStatus.completed;

  int get player1Score => players[0].score;
  int get player2Score => players[1].score;

  String get winnerName {
    if (!isGameCompleted) return '';
    
    if (player1Score > player2Score) {
      return players[0].name;
    } else if (player2Score > player1Score) {
      return players[1].name;
    } else {
      return 'Empate';
    }
  }
} 