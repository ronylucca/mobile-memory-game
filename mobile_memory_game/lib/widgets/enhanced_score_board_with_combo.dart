import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/player_model.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/models/game_model.dart';
import 'package:mobile_memory_game/widgets/enhanced_score_board.dart';
import 'package:mobile_memory_game/widgets/floating_combo_display.dart';

class EnhancedScoreBoardWithCombo extends StatelessWidget {
  final List<PlayerModel> players;
  final ThemeModel theme;
  final int currentPlayerIndex;
  final bool isCompact;
  final int comboCount;
  final int maxCombo;
  
  // Campos do timer
  final GameMode gameMode;
  final String? formattedTimeRemaining;
  final bool isTimerPaused;
  final VoidCallback? onTimerTap;

  const EnhancedScoreBoardWithCombo({
    super.key,
    required this.players,
    required this.theme,
    required this.currentPlayerIndex,
    this.isCompact = false,
    this.comboCount = 0,
    this.maxCombo = 0,
    this.gameMode = GameMode.zen,
    this.formattedTimeRemaining,
    this.isTimerPaused = false,
    this.onTimerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Scoreboard principal
        EnhancedScoreBoard(
          players: players,
          theme: theme,
          currentPlayerIndex: currentPlayerIndex,
          isCompact: isCompact,
          comboCount: comboCount, // Passar combo para mostrar efeito no scoreboard
          maxCombo: maxCombo,
          gameMode: gameMode,
          formattedTimeRemaining: formattedTimeRemaining,
          isTimerPaused: isTimerPaused,
          onTimerTap: onTimerTap,
        ),
        
        // Combo flutuante posicionado de forma segura sobre o scoreboard
        if (comboCount >= 2)
          Positioned(
            top: -25, // Posição mais baixa para não sobrepor o header
            left: currentPlayerIndex == 0 ? 10 : null,
            right: currentPlayerIndex == 1 ? 10 : null,
            child: FloatingComboDisplay(
              comboCount: comboCount,
              maxCombo: maxCombo,
              theme: theme,
              currentPlayerIndex: currentPlayerIndex,
              isVisible: true,
            ),
          ),
      ],
    );
  }
} 