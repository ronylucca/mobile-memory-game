import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/providers/game_provider.dart';
import 'package:mobile_memory_game/screens/game_result_screen.dart';
import 'package:mobile_memory_game/widgets/memory_card.dart';
import 'package:mobile_memory_game/widgets/score_board.dart';
import 'package:mobile_memory_game/widgets/enhanced_score_board.dart';
import 'package:mobile_memory_game/widgets/enhanced_game_controls.dart';
import 'package:mobile_memory_game/widgets/responsive_game_board.dart';
import 'package:mobile_memory_game/utils/game_utils.dart';
import 'package:mobile_memory_game/utils/responsive_layout.dart';

class GameScreen extends StatefulWidget {
  final String player1Name;
  final String player2Name;
  final ThemeModel theme;

  const GameScreen({
    super.key,
    required this.player1Name,
    required this.player2Name,
    required this.theme,
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
        player1Name: widget.player1Name,
        player2Name: widget.player2Name,
        theme: widget.theme,
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
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isLargeScreen = ResponsiveLayout.isLargeScreen(context);
                          
                          return Column(
                            children: [
                              _buildHeader(gameProvider, isCompact: !isLargeScreen),
                              SizedBox(height: isLargeScreen ? 20 : 12),
                              EnhancedScoreBoard(
                                players: game.players,
                                theme: widget.theme,
                                currentPlayerIndex: game.currentPlayerIndex,
                                isCompact: !isLargeScreen,
                              ),
                              SizedBox(height: isLargeScreen ? 20 : 12),
                              Expanded(
                                child: ResponsiveGameBoard(
                                  cards: game.cards,
                                  theme: widget.theme,
                                  onCardTap: (index) => gameProvider.selectCard(index),
                                ),
                              ),
                              SizedBox(height: isLargeScreen ? 20 : 12),
                              EnhancedGameControls(
                                gameProvider: gameProvider,
                                theme: widget.theme,
                                isCompact: !isLargeScreen,
                                onRestart: () => _showRestartConfirmationDialog(gameProvider),
                              ),
                            ],
                          );
                        },
                      ),
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
          );
        },
      ),
    );
  }

  Widget _buildHeader(GameProvider gameProvider, {bool isCompact = false}) {
    final fontSize = isCompact ? 20.0 : 24.0;
    final iconSize = isCompact ? 22.0 : 24.0;
    
    return SizedBox(
      height: ResponsiveLayout.getHeaderHeight(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: iconSize),
            onPressed: () {
              _showExitConfirmationDialog();
            },
          ),
          Expanded(
            child: Text(
              'Jogo da Memória',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: iconSize),
            onPressed: () {
              _showRestartConfirmationDialog(gameProvider);
            },
          ),
        ],
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