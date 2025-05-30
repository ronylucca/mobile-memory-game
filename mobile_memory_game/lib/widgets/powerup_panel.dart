import 'package:flutter/material.dart';
import 'package:mobile_memory_game/widgets/power_up_effects.dart';
import 'package:mobile_memory_game/models/player_model.dart';

class PowerupPanel extends StatelessWidget {
  final PlayerModel player;
  final Function(PowerUpType) onPowerupPressed;
  final bool isCurrentPlayer;

  const PowerupPanel({
    super.key,
    required this.player,
    required this.onPowerupPressed,
    this.isCurrentPlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCurrentPlayer 
            ? [Colors.blue.withOpacity(0.3), Colors.purple.withOpacity(0.3)]
            : [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer ? Colors.blue : Colors.grey,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header com nome e pontos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                player.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCurrentPlayer ? Colors.blue : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${player.score} pts',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Powerups ativos
          if (player.activePowerups.isNotEmpty) ...[
            _buildActivePowerups(),
            const SizedBox(height: 8),
          ],
          
          // Botões de powerups disponíveis (apenas para jogador atual)
          if (isCurrentPlayer) _buildAvailablePowerups(),
        ],
      ),
    );
  }

  Widget _buildActivePowerups() {
    return Wrap(
      spacing: 4,
      children: player.activePowerups.map((activePowerup) {
        final powerup = PowerUp.getPowerUp(activePowerup.type);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                powerup.icon,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
              Text(
                activePowerup.isPermanent 
                  ? powerup.name
                  : '${activePowerup.remainingTime}s',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvailablePowerups() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: PowerUp.availablePowerUps.map((powerup) {
        final isAvailable = player.canAfford(powerup.type);
        final isActive = player.hasPowerup(powerup.type);
        
        return PowerUpButton(
          powerUp: powerup,
          isAvailable: isAvailable && !isActive,
          isActive: isActive,
          onPressed: () => onPowerupPressed(powerup.type),
        );
      }).toList(),
    );
  }
} 