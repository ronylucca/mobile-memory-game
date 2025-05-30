import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_memory_game/models/card_model.dart';
import 'package:mobile_memory_game/models/game_model.dart';
import 'package:mobile_memory_game/models/player_model.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/widgets/power_up_effects.dart'; // Sistema unificado
import 'package:mobile_memory_game/screens/ai_game_setup_screen.dart'; // Para AIDifficulty
import 'package:mobile_memory_game/utils/audio_manager.dart';
import 'package:mobile_memory_game/utils/powerup_service.dart';

class GameProvider extends ChangeNotifier {
  GameModel? _game;
  CardModel? _firstSelectedCard;
  CardModel? _secondSelectedCard;
  bool _isProcessingTurn = false;
  final AudioManager _audioManager = AudioManager();
  
  // Flag para indicar se estamos usando icons ou imagens reais
  bool _useIcons = true;
  
  // Timer fields
  Timer? _gameTimer;
  Timer? _powerupTimer; // Timer separado para powerups
  
  // IA fields
  bool _isAIEnabled = false;
  AIDifficulty? _aiDifficulty;
  Timer? _aiThinkingTimer;
  String? _originalPlayer2Name; // Armazena o nome original do player 2
  
  GameModel get game {
    if (_game == null) {
      throw StateError('O jogo não foi inicializado. Chame initializeGame() primeiro.');
    }
    return _game!;
  }

  bool get isProcessingTurn => _isProcessingTurn;
  bool get useIcons => _useIcons;
  bool get isGameInitialized => _game != null;

  // Inicializa um novo jogo
  Future<void> initializeGame({
    required String player1Name,
    required String player2Name,
    required ThemeModel theme,
    GameMode gameMode = GameMode.zen,
    int? timerMinutes,
    bool isAIEnabled = false,
    AIDifficulty? aiDifficulty,
    bool powerupsEnabled = false,
  }) async {
    debugPrint('Inicializando jogo com tema: ${theme.id}');
    
    _isAIEnabled = isAIEnabled;
    _aiDifficulty = aiDifficulty;
    _originalPlayer2Name = player2Name;
    
    // Pontos iniciais: 3 se powerups estão habilitados, 0 caso contrário
    final initialScore = powerupsEnabled ? 3 : 0;
    
    final players = [
      PlayerModel(id: 1, name: player1Name, isCurrentTurn: true, score: initialScore),
      PlayerModel(id: 2, name: isAIEnabled ? 'IA ${_getAIDifficultyName()}' : player2Name, score: initialScore),
    ];

    // Realiza o "cara ou coroa" virtual para decidir quem começa
    final random = Random();
    final starterIndex = random.nextInt(2);
    
    players[0] = players[0].copyWith(isCurrentTurn: starterIndex == 0);
    players[1] = players[1].copyWith(isCurrentTurn: starterIndex == 1);

    // Verifica primeiro se temos imagens disponíveis para este tema
    _useIcons = !(await _checkImagesAvailable(theme));
    
    final cards = _createAndShuffleCards(theme, powerupsEnabled: powerupsEnabled);

    // Gera cores distintas para cada jogador baseadas no tema
    final playerColors = _generatePlayerColors(theme);

    // Configura o timer se for modo timer
    int? timeRemainingSeconds;
    if (gameMode == GameMode.timer && timerMinutes != null) {
      timeRemainingSeconds = timerMinutes * 60;
    }

    _game = GameModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cards: cards,
      players: players,
      theme: theme,
      status: GameStatus.inProgress,
      currentPlayerIndex: starterIndex,
      player1Color: playerColors[0],
      player2Color: playerColors[1],
      gameMode: gameMode,
      timerDurationMinutes: timerMinutes,
      timeRemainingSeconds: timeRemainingSeconds,
      isTimerPaused: false,
      powerupsEnabled: powerupsEnabled,
    );
    
    // Inicia o timer se for modo timer
    if (gameMode == GameMode.timer) {
      _startTimer();
    }
    
    // Sempre inicia o timer de powerups (independente do modo)
    _startPowerupTimer();
    
    // Define o tema atual no AudioManager
    debugPrint('Definindo tema atual no AudioManager: ${theme.id}');
    _audioManager.setCurrentTheme(theme);

    // Adiciona um pequeno atraso para garantir que o áudio seja inicializado corretamente
    debugPrint('Adicionando atraso antes de reproduzir o som inicial');
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Toca o som de início de jogo específico do tema
    debugPrint('Tocando som de início de jogo do tema ${theme.id}');
    _audioManager.playThemeSound('game_start');
    
    notifyListeners();
    
    // Se a IA começa jogando, ativa ela após um breve atraso
    if (_isAIEnabled && starterIndex == 1) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _makeAIMove();
      });
    }
  }
  
  // Gera cores distintas para cada jogador baseadas no tema
  List<Color> _generatePlayerColors(ThemeModel theme) {
    final primaryHSL = HSLColor.fromColor(theme.primaryColor);
    final secondaryHSL = HSLColor.fromColor(theme.secondaryColor);
    
    // Player 1: Versão mais saturada do primaryColor
    final player1Color = primaryHSL.withSaturation(
      (primaryHSL.saturation + 0.2).clamp(0.0, 1.0)
    ).withLightness(
      (primaryHSL.lightness - 0.1).clamp(0.0, 1.0)
    ).toColor();
    
    // Player 2: Versão mais saturada do secondaryColor  
    final player2Color = secondaryHSL.withSaturation(
      (secondaryHSL.saturation + 0.2).clamp(0.0, 1.0)
    ).withLightness(
      (secondaryHSL.lightness - 0.1).clamp(0.0, 1.0)
    ).toColor();
    
    return [player1Color, player2Color];
  }
  
  // Verifica se as imagens do tema estão disponíveis
  Future<bool> _checkImagesAvailable(ThemeModel theme) async {
    try {
      // Tenta verificar se pelo menos a primeira imagem existe
      final assetPath = '${theme.folderPath}/card_1.png';
      await rootBundle.load(assetPath);
      return true; // Se não lançar exceção, a imagem existe
    } catch (e) {
      debugPrint('Imagens não encontradas para o tema ${theme.id}, usando ícones: $e');
      return false;
    }
  }

  // Cria e embaralha as cartas
  List<CardModel> _createAndShuffleCards(ThemeModel theme, {bool powerupsEnabled = false}) {
    List<CardModel> cards = [];
    
    // Cria 10 pares de cartas (sem marcação prévia de bônus)
    for (int i = 0; i < 10; i++) {
      final pairId = i + 1;
      final imagePath = '${theme.folderPath}/card_$pairId.png';
      
      // Cria duas cartas com o mesmo ID de par
      cards.add(CardModel(
        id: i * 2 + 1,
        imagePath: imagePath,
        theme: theme.id,
        pairId: pairId,
        isFlipped: false, // Garante que as cartas começam viradas para baixo
        isMatched: false,
      ));
      
      cards.add(CardModel(
        id: i * 2 + 2,
        imagePath: imagePath,
        theme: theme.id,
        pairId: pairId,
        isFlipped: false, // Garante que as cartas começam viradas para baixo
        isMatched: false,
      ));
    }
    
    // Embaralha as cartas
    cards.shuffle();
    
    return cards;
  }

  // Lida com a seleção de uma carta
  Future<void> selectCard(int index) async {
    // 🛡️ PROTEÇÕES CRÍTICAS CONTRA CONDIÇÕES DE CORRIDA
    if (_isProcessingTurn) {
      debugPrint('⚠️ SELEÇÃO BLOQUEADA - Turno ainda sendo processado');
      return;
    }
    
    if (_game == null) {
      debugPrint('⚠️ ERRO - Jogo não inicializado');
      return;
    }

    if (index < 0 || index >= _game!.cards.length) {
      debugPrint('⚠️ ERRO - Índice de carta inválido: $index');
      return;
    }
    
    final card = _game!.cards[index];
    
    // Verifica se a carta já está virada ou já foi encontrada
    if (card.isFlipped || card.isMatched) {
      debugPrint('⚠️ CARTA JÁ SELECIONADA - Ignorando seleção');
      return;
    }

    debugPrint('🎯 SELECIONANDO CARTA ${card.id} (índice $index)');

    // Atualiza a carta selecionada para virada
    final updatedCards = List<CardModel>.from(_game!.cards);
    updatedCards[index] = card.copyWith(isFlipped: true);

    // Toca o som de virar carta do tema
    _audioManager.playThemeSound('card_flip');

    // Lógica para verificar pares
    if (_firstSelectedCard == null) {
      debugPrint('📝 PRIMEIRA CARTA SELECIONADA');
      _firstSelectedCard = updatedCards[index];
      
      // Gera bônus aleatório para esta jogada (30% de chance sempre)
      bool isBonusMove = false;
      int bonusPoints = 0;
      
      final random = Random();
      isBonusMove = random.nextDouble() < 0.3; // 30% de chance
      if (isBonusMove) {
        bonusPoints = 1 + random.nextInt(3); // 1, 2 ou 3 pontos
        debugPrint('🎁 JOGADA BÔNUS! Vale +$bonusPoints pontos extras');
      }
      
      // Atualiza o jogo com informações da jogada
      _game = _game!.copyWith(
        cards: updatedCards,
        selectedCardIndex: index,
        isCurrentMoveBonus: isBonusMove,
        currentMoveBonusPoints: bonusPoints,
        bonusCardIndex: isBonusMove ? index : -1, // Armazena qual carta iniciou o bônus
      );
      
      // Se é a IA fazendo a primeira jogada, programa a segunda automaticamente
      if (_isAIEnabled && _game!.currentPlayerIndex == 1) {
        Future.delayed(const Duration(milliseconds: 600), () {
          _makeAIMove();
        });
      }
    } else {
      debugPrint('📝 SEGUNDA CARTA SELECIONADA - Iniciando verificação de par');
      
      // 🛡️ PROTEÇÃO ADICIONAL: Verifica se primeira carta ainda é válida
      if (_firstSelectedCard == null) {
        debugPrint('⚠️ ERRO - Primeira carta foi limpa inesperadamente');
        return;
      }
      
      _isProcessingTurn = true;
      _secondSelectedCard = updatedCards[index];
      
      // Atualiza as cartas sem mudar o estado de bônus
      _game = _game!.copyWith(
        cards: updatedCards,
        selectedCardIndex: index,
      );
      
      // 🚀 NOTIFICA IMEDIATAMENTE PARA MOSTRAR A SEGUNDA CARTA
      notifyListeners();
      
      // Verifica se as cartas formam um par
      await _checkForMatch();
      
      // Note: _checkForMatch já chama notifyListeners() no final
      return; // Evita notifyListeners() duplo
    }
    
    notifyListeners();
  }

  // Verifica se as duas cartas selecionadas formam um par
  Future<void> _checkForMatch() async {
    if (_firstSelectedCard == null || _secondSelectedCard == null) return;

    final isMatch = _firstSelectedCard!.pairId == _secondSelectedCard!.pairId;
    
    // Pausa para que o jogador veja a segunda carta
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // ⚠️ VERIFICAÇÃO CRÍTICA: Garante que ainda estamos processando o turno
    // Se outro processo já limpou o estado, não prosseguir
    if (!_isProcessingTurn || _firstSelectedCard == null || _secondSelectedCard == null) {
      debugPrint('⚠️ TURNO CANCELADO - Estado foi limpo durante delay');
      return;
    }

    final updatedCards = List<CardModel>.from(_game!.cards);
    final firstIndex = _game!.cards.indexWhere((card) => card.id == _firstSelectedCard!.id);
    final secondIndex = _game!.cards.indexWhere((card) => card.id == _secondSelectedCard!.id);

    // Verificação adicional de índices válidos
    if (firstIndex == -1 || secondIndex == -1) {
      debugPrint('⚠️ ERRO: Cartas não encontradas no estado atual');
      _resetTurnState();
      return;
    }

    if (isMatch) {
      // As cartas formam um par, mantém viradas e marca como encontradas
      // Adiciona a informação de qual jogador fez o match
      updatedCards[firstIndex] = _firstSelectedCard!.copyWith(
        isMatched: true, 
        isFlipped: true, 
        matchedByPlayer: _game!.currentPlayerIndex
      );
      updatedCards[secondIndex] = _secondSelectedCard!.copyWith(
        isMatched: true, 
        isFlipped: true, 
        matchedByPlayer: _game!.currentPlayerIndex
      );
      
      // Sistema de Combo (não muda de jogador no acerto)
      final now = DateTime.now();
      final currentCombo = _game!.comboCount + 1;
      final newMaxCombo = currentCombo > _game!.maxCombo ? currentCombo : _game!.maxCombo;
      
      // Calcula bonus por combo (cada acerto consecutivo vale mais)
      final comboBonus = currentCombo > 1 ? (currentCombo - 1) * 0.5 : 0;
      
      // Pontos bônus da jogada atual (se aplicável)
      final moveBonusPoints = _game!.isCurrentMoveBonus ? _game!.currentMoveBonusPoints : 0;
      final baseScore = 1 + comboBonus + moveBonusPoints;
      
      // Aplica powerup de double points
      final currentPlayer = _game!.currentPlayer;
      final scoreMultiplier = currentPlayer.doublePointsRemaining > 0 ? 2 : 1;
      final totalScore = (baseScore * scoreMultiplier).round();
      
      debugPrint('COMBO: $currentCombo, Bonus: $comboBonus, Move Bonus: $moveBonusPoints, Multiplier: ${scoreMultiplier}x, Total Score: $totalScore');
      
      // Som especial para jogadas bônus
      if (moveBonusPoints > 0) {
        debugPrint('🎁 PAR BÔNUS ENCONTRADO! +$moveBonusPoints pontos extras');
        _audioManager.playThemeSound('bonus_match'); // Som especial para bônus
      }
      
      // Toca o som de par encontrado do tema
      if (currentCombo >= 3) {
        // Som especial para combo alto
        _audioManager.playThemeSound('match_found');
      } else {
        _audioManager.playThemeSound('match_found');
      }
      
      // Atualiza o score do jogador atual e processa double points
      final players = List<PlayerModel>.from(_game!.players);
      final updatedCurrentPlayer = PowerupService.processDoublePointsMatch(currentPlayer.copyWith(
        score: currentPlayer.score + totalScore,
      ));
      players[_game!.currentPlayerIndex] = updatedCurrentPlayer;
      
      _game = _game!.copyWith(
        cards: updatedCards,
        players: players,
        totalMoves: _game!.totalMoves + 1,
        comboCount: currentCombo,
        maxCombo: newMaxCombo,
        lastMatchTime: now,
        // Reset do estado de bônus após completar a jogada
        isCurrentMoveBonus: false,
        currentMoveBonusPoints: 0,
        bonusCardIndex: -1,
      );
      
      // Processa debuffs do jogador atual (remove se estava afetado)
      _game = PowerupService.processEndOfTurnDebuffs(_game!);
      
      // Processa powerups próprios do jogador atual (remove não temporais)
      _game = PowerupService.processEndOfTurnOwnPowerups(_game!, _game!.currentPlayerIndex);
      
      // ✅ RESET SEGURO DO ESTADO
      _resetTurnState();
      
      // Verifica se o jogo acabou
      if (updatedCards.every((card) => card.isMatched)) {
        _endGame();
      } else {
        // Se acertou e é IA, ela joga novamente (mesma regra do jogador humano)
        if (_isAIEnabled && _game!.currentPlayerIndex == 1 && !_game!.isGameCompleted) {
          Future.delayed(const Duration(milliseconds: 1200), () {
            _makeAIMove();
          });
        }
      }
    } else {
      // As cartas não formam um par, virar de volta COM DELAY EXTRA
      debugPrint('❌ PAR NÃO ENCONTRADO - Virando cartas de volta');
      
      // ⚡ CORREÇÃO CRÍTICA: Garante que as cartas voltem ao estado correto
      updatedCards[firstIndex] = _firstSelectedCard!.copyWith(isFlipped: false);
      updatedCards[secondIndex] = _secondSelectedCard!.copyWith(isFlipped: false);
      
      // Toca o som de par não encontrado do tema
      _audioManager.playThemeSound('no_match');
      
      // Reset do combo no erro
      final currentCombo = 0;
      
      // Verifica se deve trocar de jogador (considerando Swap Turn powerup)
      bool shouldChangeTurn = PowerupService.shouldSwapTurn(_game!);
      
      final players = List<PlayerModel>.from(_game!.players);
      int newPlayerIndex = _game!.currentPlayerIndex;
      
      if (shouldChangeTurn) {
        // Troca de jogador normal
        newPlayerIndex = (_game!.currentPlayerIndex + 1) % 2;
        players[_game!.currentPlayerIndex] = players[_game!.currentPlayerIndex].copyWith(isCurrentTurn: false);
        players[newPlayerIndex] = players[newPlayerIndex].copyWith(isCurrentTurn: true);
      } else {
        // Swap Turn foi usado, desativa o powerup
        _game = PowerupService.deactivateSwapTurn(_game!);
      }
      
      _game = _game!.copyWith(
        cards: updatedCards,
        players: players,
        currentPlayerIndex: newPlayerIndex,
        totalMoves: _game!.totalMoves + 1,
        comboCount: currentCombo, // Reset combo
        // Reset do estado de bônus após erro na jogada
        isCurrentMoveBonus: false,
        currentMoveBonusPoints: 0,
        bonusCardIndex: -1,
      );
      
      // Processa debuffs do jogador que errou (remove se estava afetado)
      _game = PowerupService.processEndOfTurnDebuffs(_game!);
      
      // Processa powerups próprios do jogador que errou (remove não temporais)
      _game = PowerupService.processEndOfTurnOwnPowerups(_game!, _game!.currentPlayerIndex);
      
      // ✅ RESET SEGURO DO ESTADO COM DELAY PARA ANIMAÇÃO
      await Future.delayed(const Duration(milliseconds: 100));
      _resetTurnState();
      
      // ⏱️ DELAY ADICIONAL ANTES DE NOTIFICAR PARA GARANTIR ANIMAÇÃO
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    notifyListeners();
    
    // Se é o turno da IA e ela errou (mudou de jogador), ativa ela
    if (_isAIEnabled && _game!.currentPlayerIndex == 1 && !_game!.isGameCompleted) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _makeAIMove();
      });
    }
  }

  // ✅ NOVO MÉTODO: Reset seguro do estado do turno
  void _resetTurnState() {
    debugPrint('🔄 RESETANDO ESTADO DO TURNO');
    _firstSelectedCard = null;
    _secondSelectedCard = null;
    _isProcessingTurn = false;
  }

  // 🛡️ NOVO MÉTODO: Valida e corrige estado das cartas
  void _validateAndFixCardStates() {
    if (_game == null) return;
    
    bool needsUpdate = false;
    final updatedCards = List<CardModel>.from(_game!.cards);
    
    for (int i = 0; i < updatedCards.length; i++) {
      final card = updatedCards[i];
      
      // Verifica cartas que estão viradas mas não deveriam estar
      if (card.isFlipped && !card.isMatched) {
        // Se não é uma das cartas atualmente selecionadas, deve estar desvirada
        final isFirstSelected = _firstSelectedCard?.id == card.id;
        final isSecondSelected = _secondSelectedCard?.id == card.id;
        
        if (!isFirstSelected && !isSecondSelected && !_isProcessingTurn) {
          debugPrint('🔧 CORRIGINDO CARTA ${card.id} - Estava virada incorretamente');
          updatedCards[i] = card.copyWith(isFlipped: false);
          needsUpdate = true;
        }
      }
    }
    
    if (needsUpdate) {
      _game = _game!.copyWith(cards: updatedCards);
      debugPrint('✅ ESTADO DAS CARTAS CORRIGIDO');
      notifyListeners();
    }
  }

  // Finaliza o jogo
  void _endGame() async {
    _game = _game!.copyWith(status: GameStatus.completed);
    
    // Toca o som de fim de jogo do tema
    _audioManager.playThemeSound('game_end');
    
    // Salva a pontuação no armazenamento local
    _saveScore();
    
    notifyListeners();
  }

  // Salva a pontuação no armazenamento local
  Future<void> _saveScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final highScores = prefs.getStringList('high_scores') ?? [];
      
      // Adiciona a nova pontuação
      final newScore = '${_game!.winnerName}: ${max(_game!.player1Score, _game!.player2Score)}';
      highScores.add(newScore);
      
      // Ordena e mantém apenas as 10 maiores pontuações
      highScores.sort((a, b) {
        final scoreA = int.parse(a.split(': ')[1]);
        final scoreB = int.parse(b.split(': ')[1]);
        return scoreB.compareTo(scoreA);
      });
      
      if (highScores.length > 10) {
        highScores.removeRange(10, highScores.length);
      }
      
      await prefs.setStringList('high_scores', highScores);
    } catch (e) {
      debugPrint('Erro ao salvar pontuação: $e');
    }
  }

  // Reinicia o jogo
  void restartGame() {
    initializeGame(
      player1Name: _game!.players[0].name,
      player2Name: _originalPlayer2Name ?? _game!.players[1].name,
      theme: _game!.theme,
      gameMode: _game!.gameMode,
      timerMinutes: _game!.timerDurationMinutes,
      isAIEnabled: _isAIEnabled,
      aiDifficulty: _aiDifficulty,
      powerupsEnabled: _game!.powerupsEnabled,
    );
  }

  // Pausa o jogo
  void pauseGame() {
    if (_game!.status == GameStatus.inProgress) {
      _game = _game!.copyWith(status: GameStatus.paused);
      notifyListeners();
    }
  }

  // Retoma o jogo
  void resumeGame() {
    if (_game!.status == GameStatus.paused) {
      _game = _game!.copyWith(status: GameStatus.inProgress);
      notifyListeners();
    }
  }

  // Inicia o timer
  void _startTimer() {
    _gameTimer?.cancel(); // Cancela timer anterior se existir
    
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_game?.gameMode == GameMode.timer && 
          _game?.timeRemainingSeconds != null && 
          !(_game?.isTimerPaused ?? true)) {
        
        final newTime = _game!.timeRemainingSeconds! - 1;
        
        if (newTime <= 0) {
          // Tempo acabou
          _gameTimer?.cancel();
          _game = _game!.copyWith(
            timeRemainingSeconds: 0,
            status: GameStatus.completed,
          );
          
          // Toca som de fim de tempo
          _audioManager.playThemeSound('game_over');
        } else {
          _game = _game!.copyWith(timeRemainingSeconds: newTime);
          
          // Aviso sonoro nos últimos 10 segundos
          if (newTime <= 10) {
            _audioManager.playThemeSound('warning');
          }
        }
        
        notifyListeners();
      }
    });
  }

  // Pausa/Resume timer
  void toggleTimerPause() {
    if (_game?.gameMode == GameMode.timer) {
      _game = _game!.copyWith(isTimerPaused: !_game!.isTimerPaused);
      notifyListeners();
    }
  }

  // Para o timer
  void _stopTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  // Para o timer de powerups
  void _stopPowerupTimer() {
    _powerupTimer?.cancel();
    _powerupTimer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    _stopPowerupTimer();
    _aiThinkingTimer?.cancel();
    super.dispose();
  }
  
  // Métodos de suporte à IA
  String _getAIDifficultyName() {
    switch (_aiDifficulty) {
      case AIDifficulty.easy:
        return 'Fácil';
      case AIDifficulty.moderate:
        return 'Moderado';
      case AIDifficulty.hard:
        return 'Difícil';
      case null:
        return 'Moderado';
    }
  }
  
  // Simula a jogada da IA
  void _makeAIMove() {
    if (!_isAIEnabled || _game!.currentPlayerIndex != 1 || _isProcessingTurn) return;
    
    final random = Random();
    final difficulty = _aiDifficulty ?? AIDifficulty.moderate;
    
    // Verifica se a IA deve usar powerups antes de fazer a jogada
    if (_game!.powerupsEnabled && _shouldAIUsePowerup(random)) {
      PowerUpType? powerupToUse = _selectAIPowerup(random);
      if (powerupToUse != null) {
        debugPrint('🤖 IA decidiu usar powerup: ${PowerUp.getPowerUp(powerupToUse).name}');
        // Delay pequeno antes de usar powerup
        Future.delayed(const Duration(milliseconds: 300), () {
          activatePowerup(powerupToUse);
          // Depois do powerup, faz a jogada normal
          Future.delayed(const Duration(milliseconds: 500), () {
            _executeAICardMove(difficulty, random);
          });
        });
        return;
      }
    }
    
    // Se não usou powerup, faz jogada normal
    _executeAICardMove(difficulty, random);
  }

  // Verifica se a IA deve usar powerup (baseado no score e situação)
  bool _shouldAIUsePowerup(Random random) {
    final player = _game!.players[1]; // IA é sempre player 1
    final opponent = _game!.players[0];
    
    // IA usa powerups mais frequentemente quando está atrás no score
    final scoreDifference = opponent.score - player.score;
    double powerupChance;
    
    if (scoreDifference > 20) {
      powerupChance = 0.4; // 40% quando muito atrás
    } else if (scoreDifference > 10) {
      powerupChance = 0.25; // 25% quando atrás
    } else if (scoreDifference > 0) {
      powerupChance = 0.15; // 15% quando um pouco atrás
    } else {
      powerupChance = 0.05; // 5% quando na frente ou empatado
    }
    
    return random.nextDouble() < powerupChance;
  }

  // Seleciona qual powerup a IA deve usar
  PowerUpType? _selectAIPowerup(Random random) {
    final player = _game!.players[1]; // IA é sempre player 1
    
    // Lista de powerups que a IA pode pagar
    final affordablePowerups = <PowerUpType>[];
    
    for (final powerup in PowerUp.availablePowerUps) {
      if (player.canAfford(powerup.type) && !player.hasPowerup(powerup.type)) {
        affordablePowerups.add(powerup.type);
      }
    }
    
    if (affordablePowerups.isEmpty) return null;
    
    // Prioriza powerups adversariais quando o oponente não tem debuffs
    final opponent = _game!.players[0];
    final scoreDifference = opponent.score - player.score;
    if (scoreDifference > 0) {
      // Prefere powerups ofensivos quando está atrás
      final offensivePowerups = affordablePowerups.where((type) =>
        type == PowerUpType.upsideDown || 
        type == PowerUpType.allYourMud
      ).toList();
      
      if (offensivePowerups.isNotEmpty && random.nextDouble() < 0.7) {
        return offensivePowerups[random.nextInt(offensivePowerups.length)];
      }
    }
    
    // Caso contrário, escolhe aleatoriamente dentre os disponíveis
    return affordablePowerups[random.nextInt(affordablePowerups.length)];
  }

  // Executa a jogada normal da IA (separado da lógica de powerup)
  void _executeAICardMove(AIDifficulty difficulty, Random random) {
    // Calcula chance de sucesso baseada na dificuldade
    double successRate;
    int minThinkTime, maxThinkTime;
    
    switch (difficulty) {
      case AIDifficulty.easy:
        successRate = 0.20;  // 35% mais fácil que o antigo fácil (30% - 35% = ~20%)
        minThinkTime = 300;  // Mais rápido para primeira carta
        maxThinkTime = 800;
        break;
      case AIDifficulty.moderate:
        successRate = 0.30;  // Dificuldade que antes era fácil
        minThinkTime = 500;
        maxThinkTime = 1200;
        break;
      case AIDifficulty.hard:
        successRate = 0.45;  // Dificuldade que antes era moderado (60%) menos 25%
        minThinkTime = 800;
        maxThinkTime = 1500;
        break;
    }

    // Reduz taxa de sucesso se a IA está afetada por debuffs
    if (_game!.isPlayerAffectedByUpsideDown(1)) {
      successRate *= 0.75; // 25% de redução por Upside Down
    }
    if (_game!.isPlayerAffectedByMud(1)) {
      successRate *= 0.75; // 25% de redução por Mud
    }
    
    // Se é a primeira carta do turno da IA, usa tempo menor
    int thinkTime;
    if (_firstSelectedCard == null) {
      // Primeira carta: tempo mais curto
      thinkTime = (minThinkTime * 0.5).round() + random.nextInt((maxThinkTime * 0.5).round());
    } else {
      // Segunda carta: tempo normal
      thinkTime = minThinkTime + random.nextInt(maxThinkTime - minThinkTime);
    }
    
    _aiThinkingTimer = Timer(Duration(milliseconds: thinkTime), () {
      final availableCards = <int>[];
      
      // Encontra cartas disponíveis (não viradas e não combinadas)
      for (int i = 0; i < _game!.cards.length; i++) {
        final card = _game!.cards[i];
        if (!card.isFlipped && !card.isMatched) {
          availableCards.add(i);
        }
      }
      
      if (availableCards.isEmpty) return;
      
      int selectedIndex;
      
      if (_firstSelectedCard == null) {
        // Primeira carta: sempre aleatória
        selectedIndex = availableCards[random.nextInt(availableCards.length)];
      } else {
        // Segunda carta: decide se faz jogada inteligente baseado na dificuldade
        bool makeSmartMove = random.nextDouble() < successRate;
        
        if (makeSmartMove) {
          // Tenta encontrar o par da primeira carta
          final matchingCards = availableCards.where((index) {
            return _game!.cards[index].pairId == _firstSelectedCard!.pairId;
          }).toList();
          
          if (matchingCards.isNotEmpty) {
            selectedIndex = matchingCards.first;
          } else {
            selectedIndex = availableCards[random.nextInt(availableCards.length)];
          }
        } else {
          // Jogada aleatória (IA erra intencionalmente)
          final nonMatchingCards = availableCards.where((index) {
            return _game!.cards[index].pairId != _firstSelectedCard!.pairId;
          }).toList();
          
          if (nonMatchingCards.isNotEmpty) {
            selectedIndex = nonMatchingCards[random.nextInt(nonMatchingCards.length)];
          } else {
            selectedIndex = availableCards[random.nextInt(availableCards.length)];
          }
        }
      }
      
      // Executa a jogada
      selectCard(selectedIndex);
    });
  }

  // ==================== POWERUP METHODS ====================

  /// Ativa um powerup para o jogador atual
  void activatePowerup(PowerUpType powerupType) {
    if (_game == null) return;

    final currentPlayer = _game!.currentPlayer;
    final powerup = PowerUp.getPowerUp(powerupType);

    debugPrint('🔥 TENTANDO ATIVAR POWERUP: ${powerup.name}');
    debugPrint('   Jogador: ${currentPlayer.name}');
    debugPrint('   Pontos do jogador: ${currentPlayer.score}');
    debugPrint('   Custo do powerup: ${powerup.cost}');

    // Verifica se o jogador pode comprar o powerup
    if (!currentPlayer.canAfford(powerupType)) {
      debugPrint('⚠️ FALHA: Jogador não tem pontos suficientes para ${powerup.name}');
      return;
    }

    // Estado antes da aplicação
    debugPrint('📋 ESTADO ANTES:');
    debugPrint('   isPeekActive: ${_game!.isPeekActive}');
    debugPrint('   isTimerPaused: ${_game!.isTimerPaused}');
    debugPrint('   isSwapTurnActive: ${_game!.isSwapTurnActive}');

    // Aplica o powerup
    _game = PowerupService.activatePowerup(_game!, powerupType);
    
    // Estado após a aplicação
    debugPrint('📋 ESTADO DEPOIS:');
    debugPrint('   isPeekActive: ${_game!.isPeekActive}');
    debugPrint('   isTimerPaused: ${_game!.isTimerPaused}');
    debugPrint('   isSwapTurnActive: ${_game!.isSwapTurnActive}');
    debugPrint('   activePowerUpType: ${_game!.activePowerUpType}');
    
    // Toca som de powerup
    _audioManager.playPowerupSound();
    
    debugPrint('✅ POWERUP ${powerup.name} ATIVADO PARA ${currentPlayer.name}');
    debugPrint('   Novos pontos: ${_game!.currentPlayer.score}');
    
    notifyListeners();
  }

  /// Exibe efeito visual do powerup (chame este método da UI)
  void showPowerupEffect(BuildContext context, PowerUpType powerupType) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => PowerUpEffectOverlay(
        type: powerupType,
        onComplete: () {
          overlayEntry.remove();
        },
      ),
    );
    
    overlay.insert(overlayEntry);
  }

  /// Atualiza powerups ativos (chame periodicamente)
  void updatePowerups() {
    if (_game == null) return;

    _game = PowerupService.updateActiveStates(_game!);
    notifyListeners();
  }

  /// Verifica se o jogador atual pode comprar um powerup
  bool canAffordPowerup(PowerUpType powerupType) {
    if (_game == null) return false;
    return _game!.currentPlayer.canAfford(powerupType);
  }

  /// Verifica se o jogador atual tem um powerup ativo
  bool hasPowerup(PowerUpType powerupType) {
    if (_game == null) return false;
    return _game!.currentPlayer.hasPowerup(powerupType);
  }

  /// Verifica se pode ativar um powerup (affordável e não ativo)
  bool canActivatePowerup(PowerUpType powerupType) {
    if (_game == null) return false;
    return canAffordPowerup(powerupType) && !hasPowerup(powerupType);
  }

  // Inicia o timer de powerups (independente do modo)
  void _startPowerupTimer() {
    _powerupTimer?.cancel(); // Cancela timer anterior se existir
    
    _powerupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_game != null) {
        updatePowerups();
        
        // 🛡️ VALIDAÇÃO PERIÓDICA DO ESTADO DAS CARTAS
        // Executa a cada 2 segundos para não sobrecarregar
        if (timer.tick % 2 == 0) {
          _validateAndFixCardStates();
        }
      }
    });
  }
} 