import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_memory_game/models/card_model.dart';
import 'package:mobile_memory_game/models/game_model.dart';
import 'package:mobile_memory_game/models/player_model.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/utils/audio_manager.dart';

class GameProvider extends ChangeNotifier {
  GameModel? _game;
  CardModel? _firstSelectedCard;
  CardModel? _secondSelectedCard;
  bool _isProcessingTurn = false;
  final AudioManager _audioManager = AudioManager();
  
  // Flag para indicar se estamos usando icons ou imagens reais
  bool _useIcons = true;
  
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
  }) async {
    debugPrint('Inicializando jogo com tema: ${theme.id}');
    
    final players = [
      PlayerModel(id: 1, name: player1Name, isCurrentTurn: true),
      PlayerModel(id: 2, name: player2Name),
    ];

    // Realiza o "cara ou coroa" virtual para decidir quem começa
    final random = Random();
    final starterIndex = random.nextInt(2);
    
    players[0] = players[0].copyWith(isCurrentTurn: starterIndex == 0);
    players[1] = players[1].copyWith(isCurrentTurn: starterIndex == 1);

    // Verifica primeiro se temos imagens disponíveis para este tema
    _useIcons = !(await _checkImagesAvailable(theme));
    
    final cards = _createAndShuffleCards(theme);

    // Gera cores distintas para cada jogador baseadas no tema
    final playerColors = _generatePlayerColors(theme);

    _game = GameModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cards: cards,
      players: players,
      theme: theme,
      status: GameStatus.inProgress,
      currentPlayerIndex: starterIndex,
      player1Color: playerColors[0],
      player2Color: playerColors[1],
    );
    
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
  List<CardModel> _createAndShuffleCards(ThemeModel theme) {
    List<CardModel> cards = [];
    
    // Cria 10 pares de cartas
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
    if (_isProcessingTurn) return;
    
    final card = _game!.cards[index];
    
    // Verifica se a carta já está virada ou já foi encontrada
    if (card.isFlipped || card.isMatched) return;

    // Atualiza a carta selecionada para virada
    final updatedCards = List<CardModel>.from(_game!.cards);
    updatedCards[index] = card.copyWith(isFlipped: true);

    // Toca o som de virar carta do tema
    _audioManager.playThemeSound('card_flip');

    // Atualiza o jogo
    _game = _game!.copyWith(
      cards: updatedCards,
      selectedCardIndex: index,
    );
    
    notifyListeners();

    // Lógica para verificar pares
    if (_firstSelectedCard == null) {
      _firstSelectedCard = updatedCards[index];
    } else {
      _isProcessingTurn = true;
      _secondSelectedCard = updatedCards[index];
      
      // Verifica se as cartas formam um par
      await _checkForMatch();
    }
  }

  // Verifica se as duas cartas selecionadas formam um par
  Future<void> _checkForMatch() async {
    if (_firstSelectedCard == null || _secondSelectedCard == null) return;

    final isMatch = _firstSelectedCard!.pairId == _secondSelectedCard!.pairId;
    
    // Pausa para que o jogador veja a segunda carta
    await Future.delayed(const Duration(milliseconds: 1000));

    final updatedCards = List<CardModel>.from(_game!.cards);
    final firstIndex = _game!.cards.indexWhere((card) => card.id == _firstSelectedCard!.id);
    final secondIndex = _game!.cards.indexWhere((card) => card.id == _secondSelectedCard!.id);

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
      final totalScore = 1 + comboBonus;
      
      debugPrint('COMBO: $currentCombo, Bonus: $comboBonus, Total Score: ${totalScore.round()}');
      
      // Toca o som de par encontrado do tema
      if (currentCombo >= 3) {
        // Som especial para combo alto
        _audioManager.playThemeSound('match_found');
      } else {
        _audioManager.playThemeSound('match_found');
      }
      
      // Atualiza o score do jogador atual
      final players = List<PlayerModel>.from(_game!.players);
      final currentPlayer = players[_game!.currentPlayerIndex];
      players[_game!.currentPlayerIndex] = currentPlayer.copyWith(
        score: currentPlayer.score + totalScore.round(),
      );
      
      _game = _game!.copyWith(
        cards: updatedCards,
        players: players,
        totalMoves: _game!.totalMoves + 1,
        comboCount: currentCombo,
        maxCombo: newMaxCombo,
        lastMatchTime: now,
      );
      
      // Verifica se o jogo acabou
      if (updatedCards.every((card) => card.isMatched)) {
        _endGame();
      }
    } else {
      // As cartas não formam um par, virar de volta
      updatedCards[firstIndex] = _firstSelectedCard!.copyWith(isFlipped: false);
      updatedCards[secondIndex] = _secondSelectedCard!.copyWith(isFlipped: false);
      
      // Toca o som de par não encontrado do tema
      _audioManager.playThemeSound('no_match');
      
      // Reset do combo no erro
      final currentCombo = 0;
      
      // Troca de jogador
      final players = List<PlayerModel>.from(_game!.players);
      final newPlayerIndex = (_game!.currentPlayerIndex + 1) % 2;
      
      players[_game!.currentPlayerIndex] = players[_game!.currentPlayerIndex].copyWith(isCurrentTurn: false);
      players[newPlayerIndex] = players[newPlayerIndex].copyWith(isCurrentTurn: true);
      
      _game = _game!.copyWith(
        cards: updatedCards,
        players: players,
        currentPlayerIndex: newPlayerIndex,
        totalMoves: _game!.totalMoves + 1,
        comboCount: currentCombo, // Reset combo
      );
    }
    
    // Limpa as cartas selecionadas
    _firstSelectedCard = null;
    _secondSelectedCard = null;
    _isProcessingTurn = false;
    
    notifyListeners();
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
      player2Name: _game!.players[1].name,
      theme: _game!.theme,
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

  @override
  void dispose() {
    super.dispose();
  }
} 