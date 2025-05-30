import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_memory_game/models/player_model.dart';
import 'package:mobile_memory_game/widgets/power_up_effects.dart';
import 'package:mobile_memory_game/widgets/floating_powerups_display.dart';
import 'package:mobile_memory_game/providers/game_provider.dart';

/// Widget para posicionar powerups flutuantes dos dois jogadores
class FloatingPowerupsManager extends StatefulWidget {
  final PlayerModel player1;
  final PlayerModel player2;
  final int currentPlayerIndex;
  final Function(PowerUpType) onPowerupPressed;

  const FloatingPowerupsManager({
    super.key,
    required this.player1,
    required this.player2,
    required this.currentPlayerIndex,
    required this.onPowerupPressed,
  });

  @override
  State<FloatingPowerupsManager> createState() => _FloatingPowerupsManagerState();
}

class _FloatingPowerupsManagerState extends State<FloatingPowerupsManager> {
  bool _isPlayer1Expanded = false;
  bool _isPlayer2Expanded = false;

  void _onPowerupPressed(PowerUpType powerupType) {
    // Chama a função original
    widget.onPowerupPressed(powerupType);
    
    // Adiciona efeito visual
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.showPowerupEffect(context, powerupType);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        // Esconde widgets de powerups quando X-ray ou Hint estão ativos
        final shouldHidePowerups = gameProvider.game.isPeekStillActive || 
                                  gameProvider.game.isHintStillActive;
        
        if (shouldHidePowerups) {
          return const SizedBox.shrink(); // Widget vazio quando escondido
        }
        
        return Stack(
          children: [
            // Player 1 - Lado esquerdo
            Positioned(
              left: 16,
              top: MediaQuery.of(context).size.height * 0.3,
              child: FloatingPowerupsDisplay(
                player: widget.player1,
                isCurrentPlayer: widget.currentPlayerIndex == 0,
                onPowerupPressed: _onPowerupPressed,
                isExpanded: _isPlayer1Expanded,
                alignment: Alignment.centerLeft,
                onToggleExpanded: () {
                  setState(() {
                    _isPlayer1Expanded = !_isPlayer1Expanded;
                    if (_isPlayer1Expanded) {
                      _isPlayer2Expanded = false; // Fecha o outro
                    }
                  });
                },
              ),
            ),
            
            // Player 2 - Lado direito
            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height * 0.3,
              child: FloatingPowerupsDisplay(
                player: widget.player2,
                isCurrentPlayer: widget.currentPlayerIndex == 1,
                onPowerupPressed: _onPowerupPressed,
                isExpanded: _isPlayer2Expanded,
                alignment: Alignment.centerRight,
                onToggleExpanded: () {
                  setState(() {
                    _isPlayer2Expanded = !_isPlayer2Expanded;
                    if (_isPlayer2Expanded) {
                      _isPlayer1Expanded = false; // Fecha o outro
                    }
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }
} 