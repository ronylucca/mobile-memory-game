import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/models/game_model.dart';
import 'package:mobile_memory_game/providers/game_provider.dart';
import 'package:mobile_memory_game/screens/game_result_screen.dart';
import 'package:mobile_memory_game/screens/ai_game_setup_screen.dart';
import 'package:mobile_memory_game/utils/responsive_layout.dart';
import 'package:mobile_memory_game/widgets/enhanced_score_board_with_combo.dart';
import 'package:mobile_memory_game/widgets/responsive_game_board.dart';
import 'package:mobile_memory_game/widgets/particle_system.dart';
import 'package:mobile_memory_game/widgets/enhanced_game_controls.dart';
import 'package:mobile_memory_game/widgets/floating_powerups_display.dart';
import 'package:mobile_memory_game/widgets/floating_powerups_manager.dart';

class GameScreen extends StatefulWidget {
  final ThemeModel theme;
  final List<String> playerNames;
  final GameMode gameMode;
  final int gridSize;
  final int? gameDuration;
  final AIDifficulty? aiDifficulty;
  final bool powerupsEnabled;

  const GameScreen({
    super.key,
    required this.theme,
    required this.playerNames,
    this.gameMode = GameMode.zen,
    this.gridSize = 4,
    this.gameDuration,
    this.aiDifficulty,
    this.powerupsEnabled = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameProvider _gameProvider;
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 5));
  bool _hasShownResult = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _gameProvider = GameProvider();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      await _gameProvider.initializeGame(
        player1Name: widget.playerNames[0],
        player2Name: widget.playerNames[1],
        theme: widget.theme,
        gameMode: widget.gameMode,
        timerMinutes: widget.gameDuration,
        isAIEnabled: widget.aiDifficulty != null,
        aiDifficulty: widget.aiDifficulty,
        powerupsEnabled: widget.powerupsEnabled,
      );
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao inicializar o jogo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao inicializar o jogo. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _gameProvider,
      child: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (_isInitializing) {
            return Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.theme.backgroundImage),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            );
          }

          final game = gameProvider.game;
          
          if (game.isGameCompleted && !_hasShownResult) {
            _confettiController.play();
            _hasShownResult = true;
            
            // Dispara celebração épica de partículas
            Future.delayed(const Duration(milliseconds: 500), () {
              final screenSize = MediaQuery.of(context).size;
              final particleSystem = ParticleSystem.of(context);
              if (particleSystem != null) {
                // Múltiplas explosões de confetti
                for (int i = 0; i < 5; i++) {
                  Future.delayed(Duration(milliseconds: i * 300), () {
                    particleSystem.confetti(
                      position: Offset(
                        screenSize.width * (0.2 + i * 0.15),
                        screenSize.height * 0.3,
                      ),
                      count: 35,
                      spread: 200,
                    );
                  });
                }
                
                // Trail de estrelas pelo centro
                Future.delayed(const Duration(milliseconds: 800), () {
                  particleSystem.starTrail(
                    start: Offset(0, screenSize.height * 0.5),
                    end: Offset(screenSize.width, screenSize.height * 0.5),
                    color: widget.theme.primaryColor,
                    count: 15,
                  );
                });
              }
            });
            
            // Navega para a tela de resultado após um breve atraso
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => GameResultScreen(
                    game: game,
                  ),
                ),
              );
            });
          }
          
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.theme.backgroundImage),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: SafeArea(
                child: ParticleSystem(
                  enabled: true,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isLargeScreen = ResponsiveLayout.isLargeScreen(context);
                          
                          return Column(
                            children: [
                              EnhancedGameControls(
                                gameProvider: gameProvider,
                                theme: widget.theme,
                                isCompact: !isLargeScreen,
                                onRestart: () => _showRestartConfirmationDialog(gameProvider),
                                onBack: () => _showExitConfirmationDialog(),
                              ),
                              SizedBox(height: isLargeScreen ? 20 : 12),
                              EnhancedScoreBoardWithCombo(
                                players: game.players,
                                theme: widget.theme,
                                currentPlayerIndex: game.currentPlayerIndex,
                                isCompact: !isLargeScreen,
                                comboCount: game.comboCount,
                                maxCombo: game.maxCombo,
                                gameMode: game.gameMode,
                                formattedTimeRemaining: game.formattedTimeRemaining,
                                isTimerPaused: game.isTimerPaused,
                                onTimerTap: () => gameProvider.toggleTimerPause(),
                              ),
                              SizedBox(height: isLargeScreen ? 20 : 12),
                              
                              Expanded(
                                child: ResponsiveGameBoard(
                                  cards: game.cards,
                                  theme: widget.theme,
                                  onCardTap: (index) => gameProvider.selectCard(index),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    
                    // Sistema de powerups flutuante (apenas se habilitado)
                    if (widget.powerupsEnabled)
                      FloatingPowerupsManager(
                        player1: game.players[0],
                        player2: game.players[1],
                        currentPlayerIndex: game.currentPlayerIndex,
                        onPowerupPressed: (type) => gameProvider.activatePowerup(type),
                      ),
                    
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        particleDrag: 0.05,
                        emissionFrequency: 0.05,
                        numberOfParticles: 20,
                        gravity: 0.1,
                        colors: [
                          widget.theme.primaryColor,
                          widget.theme.secondaryColor,
                          Colors.red,
                          Colors.green,
                          Colors.blue,
                          Colors.yellow,
                        ],
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do Jogo'),
        content: const Text('Tem certeza que deseja sair? O progresso atual será perdido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _showRestartConfirmationDialog(GameProvider gameProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar Jogo'),
        content: const Text('Tem certeza que deseja reiniciar o jogo? O progresso atual será perdido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              gameProvider.restartGame();
              Navigator.of(context).pop();
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }
} 