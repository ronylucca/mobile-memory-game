import 'package:mobile_memory_game/widgets/power_up_effects.dart';

class PlayerModel {
  final int id;
  final String name;
  int score;
  bool isCurrentTurn;
  
  // Powerups ativos (usando estrutura híbrida otimizada)
  final List<ActivePowerUp> activePowerups;
  
  PlayerModel({
    required this.id,
    required this.name,
    this.score = 0,
    this.isCurrentTurn = false,
    this.activePowerups = const [],
  });

  PlayerModel copyWith({
    int? id,
    String? name,
    int? score,
    bool? isCurrentTurn,
    List<ActivePowerUp>? activePowerups,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      isCurrentTurn: isCurrentTurn ?? this.isCurrentTurn,
      activePowerups: activePowerups ?? this.activePowerups,
    );
  }

  // Verifica se o jogador tem um powerup específico ativo
  bool hasPowerup(PowerUpType type) {
    return activePowerups.any((p) => p.type == type && !p.isExpired);
  }

  // Verifica se pode comprar um powerup
  bool canAfford(PowerUpType type) {
    final powerup = PowerUp.getPowerUp(type);
    return score >= powerup.cost;
  }

  // Obtém o estado de um powerup específico
  ActivePowerUp? getPowerupState(PowerUpType type) {
    try {
      return activePowerups.firstWhere((p) => p.type == type && !p.isExpired);
    } catch (e) {
      return null;
    }
  }

  // Calcula pontos considerando o double points
  int getPointsForMatch() {
    final doublePointsState = getPowerupState(PowerUpType.doublePoints);
    if (doublePointsState != null) {
      final remaining = doublePointsState.state['remaining'] ?? 0;
      if (remaining > 0) {
        return 2; // pontos dobrados
      }
    }
    return 1; // pontos normais
  }

  // Verifica quantos pares restam para double points
  int get doublePointsRemaining {
    final doublePointsState = getPowerupState(PowerUpType.doublePoints);
    return doublePointsState?.state['remaining'] ?? 0;
  }
} 