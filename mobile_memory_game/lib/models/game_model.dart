import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/card_model.dart';
import 'package:mobile_memory_game/models/player_model.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/widgets/power_up_effects.dart';

enum GameStatus { notStarted, inProgress, paused, completed }
enum GameMode { zen, timer }

class GameModel {
  final String id;
  final List<CardModel> cards;
  final List<PlayerModel> players;
  final ThemeModel theme;
  final GameStatus status;
  final int currentPlayerIndex;
  final int totalMoves;
  final int selectedCardIndex;
  final int comboCount;
  final int maxCombo;
  final DateTime? lastMatchTime;
  final Color player1Color;
  final Color player2Color;
  
  // Campos do timer
  final GameMode gameMode;
  final int? timerDurationMinutes; // duração inicial em minutos (null para modo zen)
  final int? timeRemainingSeconds; // tempo restante em segundos (null para modo zen)
  final bool isTimerPaused;

  // Powerups globais (usando estrutura existente)
  final bool isPeekActive; // se todas as cartas estão visíveis
  final DateTime? peekStartTime;
  final bool isSwapTurnActive; // se o próximo erro não troca turno
  final PowerUpType? activePowerUpType; // tipo de powerup global ativo

  // Propriedades específicas para hint
  final bool isHintActive;
  final DateTime? hintStartTime;
  final List<int>? hintCardIndices; // Cartas específicas reveladas pelo hint

  // Debuffs de jogador vs jogador
  final bool isUpsideDownActive; // Se cartas estão de cabeça para baixo
  final int? upsideDownAffectedPlayer; // Qual jogador está afetado (0 ou 1)
  final bool upsideDownShouldExpireAfterTurn; // Se deve expirar após próximo turno do afetado
  final bool isMudActive; // Se efeito de "lama" está ativo
  final int? mudAffectedPlayer; // Qual jogador está afetado (0 ou 1)
  final bool mudShouldExpireAfterTurn; // Se deve expirar após próximo turno do afetado

  // Sistema de powerups
  final bool powerupsEnabled; // Se powerups estão habilitados no jogo

  // Sistema de jogadas bônus (30% de chance por jogada)
  final bool isCurrentMoveBonus; // Se a jogada atual oferece bônus
  final int currentMoveBonusPoints; // Quantos pontos bônus a jogada atual vale (1-3)
  final int bonusCardIndex; // Índice da carta que iniciou o bônus

  GameModel({
    required this.id,
    required this.cards,
    required this.players,
    required this.theme,
    this.status = GameStatus.notStarted,
    this.currentPlayerIndex = 0,
    this.totalMoves = 0,
    this.selectedCardIndex = -1,
    this.comboCount = 0,
    this.maxCombo = 0,
    this.lastMatchTime,
    required this.player1Color,
    required this.player2Color,
    this.gameMode = GameMode.zen,
    this.timerDurationMinutes,
    this.timeRemainingSeconds,
    this.isTimerPaused = false,
    this.isPeekActive = false,
    this.peekStartTime,
    this.isSwapTurnActive = false,
    this.activePowerUpType,
    this.isHintActive = false,
    this.hintStartTime,
    this.hintCardIndices,
    this.isUpsideDownActive = false,
    this.upsideDownAffectedPlayer,
    this.upsideDownShouldExpireAfterTurn = false,
    this.isMudActive = false,
    this.mudAffectedPlayer,
    this.mudShouldExpireAfterTurn = false,
    this.powerupsEnabled = false,
    this.isCurrentMoveBonus = false,
    this.currentMoveBonusPoints = 0,
    this.bonusCardIndex = -1,
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
    int? comboCount,
    int? maxCombo,
    DateTime? lastMatchTime,
    Color? player1Color,
    Color? player2Color,
    GameMode? gameMode,
    int? timerDurationMinutes,
    int? timeRemainingSeconds,
    bool? isTimerPaused,
    bool? isPeekActive,
    DateTime? peekStartTime,
    bool? isSwapTurnActive,
    PowerUpType? activePowerUpType,
    bool? isHintActive,
    DateTime? hintStartTime,
    List<int>? hintCardIndices,
    bool? isUpsideDownActive,
    int? upsideDownAffectedPlayer,
    bool? upsideDownShouldExpireAfterTurn,
    bool? isMudActive,
    int? mudAffectedPlayer,
    bool? mudShouldExpireAfterTurn,
    bool? powerupsEnabled,
    bool? isCurrentMoveBonus,
    int? currentMoveBonusPoints,
    int? bonusCardIndex,
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
      comboCount: comboCount ?? this.comboCount,
      maxCombo: maxCombo ?? this.maxCombo,
      lastMatchTime: lastMatchTime ?? this.lastMatchTime,
      player1Color: player1Color ?? this.player1Color,
      player2Color: player2Color ?? this.player2Color,
      gameMode: gameMode ?? this.gameMode,
      timerDurationMinutes: timerDurationMinutes ?? this.timerDurationMinutes,
      timeRemainingSeconds: timeRemainingSeconds ?? this.timeRemainingSeconds,
      isTimerPaused: isTimerPaused ?? this.isTimerPaused,
      isPeekActive: isPeekActive ?? this.isPeekActive,
      peekStartTime: peekStartTime ?? this.peekStartTime,
      isSwapTurnActive: isSwapTurnActive ?? this.isSwapTurnActive,
      activePowerUpType: activePowerUpType ?? this.activePowerUpType,
      isHintActive: isHintActive ?? this.isHintActive,
      hintStartTime: hintStartTime ?? this.hintStartTime,
      hintCardIndices: hintCardIndices ?? this.hintCardIndices,
      isUpsideDownActive: isUpsideDownActive ?? this.isUpsideDownActive,
      upsideDownAffectedPlayer: upsideDownAffectedPlayer ?? this.upsideDownAffectedPlayer,
      upsideDownShouldExpireAfterTurn: upsideDownShouldExpireAfterTurn ?? this.upsideDownShouldExpireAfterTurn,
      isMudActive: isMudActive ?? this.isMudActive,
      mudAffectedPlayer: mudAffectedPlayer ?? this.mudAffectedPlayer,
      mudShouldExpireAfterTurn: mudShouldExpireAfterTurn ?? this.mudShouldExpireAfterTurn,
      powerupsEnabled: powerupsEnabled ?? this.powerupsEnabled,
      isCurrentMoveBonus: isCurrentMoveBonus ?? this.isCurrentMoveBonus,
      currentMoveBonusPoints: currentMoveBonusPoints ?? this.currentMoveBonusPoints,
      bonusCardIndex: bonusCardIndex ?? this.bonusCardIndex,
    );
  }

  PlayerModel get currentPlayer => players[currentPlayerIndex];

  bool get isGameCompleted =>
      cards.every((card) => card.isMatched) || 
      status == GameStatus.completed ||
      (gameMode == GameMode.timer && timeRemainingSeconds == 0);

  int get player1Score => players[0].score;
  int get player2Score => players[1].score;

  String get winnerName {
    if (!isGameCompleted) return '';
    
    // Se o tempo acabou no modo timer
    if (gameMode == GameMode.timer && timeRemainingSeconds == 0) {
      if (player1Score > player2Score) {
        return players[0].name;
      } else if (player2Score > player1Score) {
        return players[1].name;
      } else {
        return 'Empate';
      }
    }
    
    if (player1Score > player2Score) {
      return players[0].name;
    } else if (player2Score > player1Score) {
      return players[1].name;
    } else {
      return 'Empate';
    }
  }
  
  // Formata o tempo restante em MM:SS
  String get formattedTimeRemaining {
    if (gameMode == GameMode.zen || timeRemainingSeconds == null) return '';
    
    final minutes = timeRemainingSeconds! ~/ 60;
    final seconds = timeRemainingSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Verifica se o peek ainda está ativo (usando estrutura existente)
  bool get isPeekStillActive {
    if (!isPeekActive || peekStartTime == null) return false;
    final xrayPowerup = PowerUp.availablePowerUps.firstWhere((p) => p.type == PowerUpType.xray);
    return DateTime.now().difference(peekStartTime!) < xrayPowerup.duration;
  }

  // Verifica se o hint ainda está ativo
  bool get isHintStillActive {
    if (!isHintActive || hintStartTime == null) return false;
    final hintPowerup = PowerUp.availablePowerUps.firstWhere((p) => p.type == PowerUpType.hint);
    return DateTime.now().difference(hintStartTime!) < hintPowerup.duration;
  }

  // Verifica se um jogador específico está afetado pelo Upside Down
  bool isPlayerAffectedByUpsideDown(int playerIndex) {
    return isUpsideDownActive && upsideDownAffectedPlayer == playerIndex;
  }

  // Verifica se um jogador específico está afetado pelo Mud
  bool isPlayerAffectedByMud(int playerIndex) {
    return isMudActive && mudAffectedPlayer == playerIndex;
  }

  // Verifica se o jogador atual tem algum debuff ativo
  bool get currentPlayerHasDebuff {
    return isPlayerAffectedByUpsideDown(currentPlayerIndex) || 
           isPlayerAffectedByMud(currentPlayerIndex);
  }

  // Obtém o tipo de debuff ativo no jogador (para mostrar no scoreboard)
  PowerUpType? getActiveDebuffForPlayer(int playerIndex) {
    if (isPlayerAffectedByUpsideDown(playerIndex)) return PowerUpType.upsideDown;
    if (isPlayerAffectedByMud(playerIndex)) return PowerUpType.allYourMud;
    return null;
  }
} 