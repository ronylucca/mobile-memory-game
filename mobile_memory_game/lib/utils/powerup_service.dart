import 'dart:math';
import 'package:mobile_memory_game/widgets/power_up_effects.dart';
import 'package:mobile_memory_game/models/player_model.dart';
import 'package:mobile_memory_game/models/game_model.dart';
import 'package:mobile_memory_game/models/card_model.dart';

/// Serviço oficial de powerups que integra funcionalidade completa com UI existente
class PowerupService {
  static final Random _random = Random();

  /// Ativa um powerup para o jogador atual
  static GameModel activatePowerup(GameModel game, PowerUpType powerupType) {
    final currentPlayer = game.currentPlayer;
    final powerup = PowerUp.getPowerUp(powerupType);

    // Verifica se o jogador pode comprar o powerup
    if (!currentPlayer.canAfford(powerupType)) {
      return game;
    }

    // Desconta os pontos
    final updatedPlayers = List<PlayerModel>.from(game.players);
    final playerIndex = game.currentPlayerIndex;
    
    final updatedPlayer = currentPlayer.copyWith(
      score: currentPlayer.score - powerup.cost,
    );

    // Cria o powerup ativo com estado inicial
    final activePowerup = ActivePowerUp(
      type: powerupType,
      activatedAt: DateTime.now(),
      duration: powerup.duration,
      isPermanent: powerup.isPermanent,
      state: _getInitialState(powerupType),
    );

    // Adiciona o powerup ativo ao jogador
    final playerWithPowerup = updatedPlayer.copyWith(
      activePowerups: [...updatedPlayer.activePowerups, activePowerup],
    );

    updatedPlayers[playerIndex] = playerWithPowerup;

    // Aplica efeitos específicos do powerup
    return _applyPowerupEffect(game.copyWith(players: updatedPlayers), powerupType);
  }

  /// Define estado inicial específico para cada powerup
  static Map<String, dynamic> _getInitialState(PowerUpType type) {
    switch (type) {
      case PowerUpType.doublePoints:
        return {'remaining': 3}; // 3 pares com pontos dobrados
      case PowerUpType.swapTurn:
        return {'used': false}; // Ainda não foi usado
      default:
        return {};
    }
  }

  /// Aplica efeitos específicos de cada powerup no estado do jogo
  static GameModel _applyPowerupEffect(GameModel game, PowerUpType type) {
    switch (type) {
      case PowerUpType.xray:
        return game.copyWith(
          isPeekActive: true,
          peekStartTime: DateTime.now(),
          activePowerUpType: type,
        );
      
      case PowerUpType.freeze:
        if (game.gameMode == GameMode.timer) {
          return game.copyWith(
            isTimerPaused: true,
            activePowerUpType: type,
          );
        }
        return game;
      
      case PowerUpType.swapTurn:
        return game.copyWith(
          isSwapTurnActive: true,
          activePowerUpType: type,
        );
      
      case PowerUpType.shuffle:
        return _shuffleUnmatchedCards(game).copyWith(activePowerUpType: type);
      
      case PowerUpType.lightning:
        return _activateLightning(game).copyWith(activePowerUpType: type);
      
      case PowerUpType.hint:
        return _activateHint(game).copyWith(activePowerUpType: type);
      
      case PowerUpType.upsideDown:
        return _activateUpsideDown(game).copyWith(activePowerUpType: type);
      
      case PowerUpType.allYourMud:
        return _activateAllYourMud(game).copyWith(activePowerUpType: type);
      
      case PowerUpType.doublePoints:
        return game.copyWith(activePowerUpType: type);
      
      default:
        return game;
    }
  }

  /// Embaralha cartas não emparelhadas
  static GameModel _shuffleUnmatchedCards(GameModel game) {
    final unMatchedCards = <CardModel>[];
    final unMatchedIndices = <int>[];
    
    for (int i = 0; i < game.cards.length; i++) {
      if (!game.cards[i].isMatched && !game.cards[i].isFlipped) {
        unMatchedCards.add(game.cards[i]);
        unMatchedIndices.add(i);
      }
    }
    
    if (unMatchedCards.length < 2) return game; // Não vale a pena embaralhar
    
    unMatchedCards.shuffle();
    
    final updatedCards = List<CardModel>.from(game.cards);
    for (int i = 0; i < unMatchedIndices.length; i++) {
      updatedCards[unMatchedIndices[i]] = unMatchedCards[i];
    }

    return game.copyWith(cards: updatedCards);
  }

  /// Ativa o lightning (50% chance de auto-match)
  static GameModel _activateLightning(GameModel game) {
    if (!_random.nextBool()) return game; // 50% chance de falhar

    // Encontra pares disponíveis
    final availableCards = <int>[];
    for (int i = 0; i < game.cards.length; i++) {
      if (!game.cards[i].isMatched && !game.cards[i].isFlipped) {
        availableCards.add(i);
      }
    }

    if (availableCards.length < 2) return game;

    // Agrupa cartas por par
    final cardGroups = <String, List<int>>{};
    for (final index in availableCards) {
      final card = game.cards[index];
      if (!cardGroups.containsKey(card.imagePath)) {
        cardGroups[card.imagePath] = [];
      }
      cardGroups[card.imagePath]!.add(index);
    }

    // Encontra um par completo e o emparelha automaticamente
    for (final group in cardGroups.values) {
      if (group.length >= 2) {
        final firstIndex = group[0];
        final secondIndex = group[1];

        final updatedCards = List<CardModel>.from(game.cards);
        updatedCards[firstIndex] = updatedCards[firstIndex].copyWith(
          isMatched: true,
          matchedByPlayer: game.currentPlayerIndex,
        );
        updatedCards[secondIndex] = updatedCards[secondIndex].copyWith(
          isMatched: true,
          matchedByPlayer: game.currentPlayerIndex,
        );

        // Atualiza pontuação
        final currentPlayer = game.currentPlayer;
        final points = currentPlayer.getPointsForMatch();
        
        final updatedPlayers = List<PlayerModel>.from(game.players);
        updatedPlayers[game.currentPlayerIndex] = currentPlayer.copyWith(
          score: currentPlayer.score + points,
        );

        return game.copyWith(
          cards: updatedCards,
          players: updatedPlayers,
        );
      }
    }

    return game;
  }

  /// Ativa hint (revela um par brevemente)
  static GameModel _activateHint(GameModel game) {
    // Encontra cartas não emparelhadas disponíveis
    final availableCardIndices = <int>[];
    final availablePairs = <int, List<int>>{};
    
    for (int i = 0; i < game.cards.length; i++) {
      final card = game.cards[i];
      if (!card.isMatched && !card.isFlipped) {
        availableCardIndices.add(i);
        
        final pairId = card.pairId;
        if (!availablePairs.containsKey(pairId)) {
          availablePairs[pairId] = [];
        }
        availablePairs[pairId]!.add(i);
      }
    }
    
    // Filtra apenas pares completos (2 cartas)
    final completePairs = availablePairs.entries
        .where((entry) => entry.value.length == 2)
        .toList();
    
    if (completePairs.isEmpty || availableCardIndices.length < 3) {
      // Não há pares disponíveis ou cartas suficientes, hint não faz nada
      return game;
    }
    
    // Escolhe um par aleatório para incluir na dica
    final selectedPair = completePairs[_random.nextInt(completePairs.length)];
    final pairIndices = selectedPair.value;
    
    // Escolhe uma terceira carta aleatória que NÃO seja do par selecionado
    final otherCards = availableCardIndices
        .where((index) => !pairIndices.contains(index))
        .toList();
    
    if (otherCards.isEmpty) {
      // Se não há outras cartas disponíveis, usa apenas o par
      return game.copyWith(
        isHintActive: true,
        hintStartTime: DateTime.now(),
        hintCardIndices: pairIndices,
      );
    }
    
    // Escolhe uma carta adicional aleatória
    final thirdCard = otherCards[_random.nextInt(otherCards.length)];
    
    // Combina o par com a terceira carta e embaralha a ordem
    final hintCards = [...pairIndices, thirdCard];
    hintCards.shuffle();
    
    return game.copyWith(
      isHintActive: true,
      hintStartTime: DateTime.now(),
      hintCardIndices: hintCards,
    );
  }

  /// Ativa Upside Down (cartas de cabeça para baixo no adversário)
  static GameModel _activateUpsideDown(GameModel game) {
    final adversaryIndex = (game.currentPlayerIndex + 1) % 2;
    print('🙃 ATIVANDO UPSIDE DOWN - Jogador ${game.currentPlayerIndex} afetando jogador $adversaryIndex');
    
    // Remove qualquer debuff do jogador atual antes de aplicar no adversário
    return game.copyWith(
      // Limpa debuffs do jogador atual
      isUpsideDownActive: game.upsideDownAffectedPlayer == game.currentPlayerIndex ? false : true,
      upsideDownAffectedPlayer: game.upsideDownAffectedPlayer == game.currentPlayerIndex ? null : adversaryIndex,
      isMudActive: game.mudAffectedPlayer == game.currentPlayerIndex ? false : game.isMudActive,
      mudAffectedPlayer: game.mudAffectedPlayer == game.currentPlayerIndex ? null : game.mudAffectedPlayer,
    );
  }

  /// Ativa All Your Mud (remove debuffs próprios e aplica efeito molhado no adversário)
  static GameModel _activateAllYourMud(GameModel game) {
    final adversaryIndex = (game.currentPlayerIndex + 1) % 2;
    print('🌊 ATIVANDO ALL YOUR MUD - Jogador ${game.currentPlayerIndex} afetando jogador $adversaryIndex');
    
    // Remove TODOS os debuffs do jogador atual e aplica mud no adversário
    return game.copyWith(
      // Limpa TODOS os debuffs do jogador atual
      isUpsideDownActive: game.upsideDownAffectedPlayer == game.currentPlayerIndex ? false : game.isUpsideDownActive,
      upsideDownAffectedPlayer: game.upsideDownAffectedPlayer == game.currentPlayerIndex ? null : game.upsideDownAffectedPlayer,
      isMudActive: true,
      mudAffectedPlayer: adversaryIndex,
    );
  }

  /// Atualiza powerups ativos (remove expirados, atualiza estados)
  static GameModel updateActiveStates(GameModel game) {
    GameModel updatedGame = game;

    // NÃO remove debuffs automaticamente aqui - isso é feito apenas quando há jogadas
    // Os debuffs adversariais são removidos apenas em endTurn() quando o jogador afetado completa uma jogada

    // Atualiza X-ray
    if (updatedGame.isPeekActive && updatedGame.peekStartTime != null) {
      final xrayPowerup = PowerUp.availablePowerUps.firstWhere((p) => p.type == PowerUpType.xray);
      if (DateTime.now().difference(updatedGame.peekStartTime!) >= xrayPowerup.duration) {
        print('👁️ X-RAY EXPIROU POR TEMPO - Desativando automaticamente');
        updatedGame = updatedGame.copyWith(
          isPeekActive: false,
          peekStartTime: null,
        );
      }
    }

    // Atualiza Hint
    if (updatedGame.isHintActive && updatedGame.hintStartTime != null) {
      final hintPowerup = PowerUp.availablePowerUps.firstWhere((p) => p.type == PowerUpType.hint);
      if (DateTime.now().difference(updatedGame.hintStartTime!) >= hintPowerup.duration) {
        print('💡 HINT EXPIROU POR TEMPO - Desativando automaticamente');
        updatedGame = updatedGame.copyWith(
          isHintActive: false,
          hintStartTime: null,
          hintCardIndices: null,
        );
      }
    }

    // Atualiza freeze ativo no timer
    if (updatedGame.gameMode == GameMode.timer && updatedGame.isTimerPaused) {
      final freezePowerup = PowerUp.availablePowerUps.firstWhere((p) => p.type == PowerUpType.freeze);
      bool anyPlayerHasFreeze = false;
      
      for (final player in updatedGame.players) {
        if (player.hasPowerup(PowerUpType.freeze)) {
          anyPlayerHasFreeze = true;
          break;
        }
      }
      
      if (!anyPlayerHasFreeze) {
        updatedGame = updatedGame.copyWith(isTimerPaused: false);
      }
    }

    return updatedGame;
  }

  /// Processa o uso do double points quando um par é encontrado
  static PlayerModel processDoublePointsMatch(PlayerModel player) {
    final doublePointsState = player.getPowerupState(PowerUpType.doublePoints);
    if (doublePointsState != null) {
      final remaining = doublePointsState.state['remaining'] ?? 0;
      if (remaining > 1) {
        // Atualiza estado para decrementar contador
        final updatedPowerups = player.activePowerups.map((p) {
          if (p.type == PowerUpType.doublePoints) {
            return p.updateState({'remaining': remaining - 1});
          }
          return p;
        }).toList();
        
        return player.copyWith(activePowerups: updatedPowerups);
      } else {
        // Remove o powerup quando acabam os usos
        final updatedPowerups = player.activePowerups
            .where((p) => p.type != PowerUpType.doublePoints)
            .toList();
        
        return player.copyWith(activePowerups: updatedPowerups);
      }
    }
    return player;
  }

  /// Verifica se deve trocar o turno (considerando o swapTurn)
  static bool shouldSwapTurn(GameModel game) {
    return !game.isSwapTurnActive;
  }

  /// Usa o swapTurn powerup (marca como usado)
  static GameModel useSwapTurn(GameModel game) {
    if (!game.isSwapTurnActive) return game;

    final updatedPlayers = List<PlayerModel>.from(game.players);
    final currentPlayer = game.currentPlayer;
    
    // Remove o powerup swapTurn após uso
    final updatedPowerups = currentPlayer.activePowerups
        .where((p) => p.type != PowerUpType.swapTurn)
        .toList();
    
    updatedPlayers[game.currentPlayerIndex] = currentPlayer.copyWith(
      activePowerups: updatedPowerups,
    );

    return game.copyWith(
      players: updatedPlayers,
      isSwapTurnActive: false,
    );
  }

  /// Desativa o swap turn powerup (método alias para useSwapTurn)
  static GameModel deactivateSwapTurn(GameModel game) {
    return useSwapTurn(game);
  }

  /// Remove debuffs adversariais quando o jogador afetado completa uma jogada
  static GameModel processEndOfTurnDebuffs(GameModel game) {
    GameModel updatedGame = game;
    
    // Remove debuffs quando o jogador afetado completa sua jogada (seja acerto ou erro)
    if (game.isUpsideDownActive && game.upsideDownAffectedPlayer == game.currentPlayerIndex) {
      print('🔄 REMOVENDO UPSIDE DOWN - Jogador afetado ${game.currentPlayerIndex} completou turno');
      updatedGame = updatedGame.copyWith(
        isUpsideDownActive: false,
        upsideDownAffectedPlayer: null,
        upsideDownShouldExpireAfterTurn: false,
      );
    }

    if (game.isMudActive && game.mudAffectedPlayer == game.currentPlayerIndex) {
      print('🔄 REMOVENDO MUD - Jogador afetado ${game.currentPlayerIndex} completou turno');
      updatedGame = updatedGame.copyWith(
        isMudActive: false,
        mudAffectedPlayer: null,
        mudShouldExpireAfterTurn: false,
      );
    }
    
    return updatedGame;
  }

  /// Remove powerups próprios quando o jogador que ativou completa uma jogada
  static GameModel processEndOfTurnOwnPowerups(GameModel game, int playerIndex) {
    final players = List<PlayerModel>.from(game.players);
    final player = players[playerIndex];
    
    // Remove powerups não temporais (que não dependem de tempo)
    final nonTemporalPowerups = {
      PowerUpType.doublePoints,
      PowerUpType.swapTurn,
      PowerUpType.shuffle,
      PowerUpType.lightning,
    };
    
    // Filtra apenas powerups temporais (que dependem de tempo)
    final updatedPowerups = player.activePowerups.where((powerup) {
      return !nonTemporalPowerups.contains(powerup.type);
    }).toList();
    
    if (updatedPowerups.length != player.activePowerups.length) {
      print('🔄 REMOVENDO POWERUPS PRÓPRIOS - Jogador $playerIndex completou turno');
      players[playerIndex] = player.copyWith(activePowerups: updatedPowerups);
      return game.copyWith(players: players);
    }
    
    return game;
  }
} 