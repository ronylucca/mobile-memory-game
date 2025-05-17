import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/providers/game_provider.dart';
import 'package:mobile_memory_game/screens/game_result_screen.dart';
import 'package:mobile_memory_game/widgets/memory_card.dart';
import 'package:mobile_memory_game/widgets/score_board.dart';
import 'package:mobile_memory_game/utils/game_utils.dart';

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
                      child: Column(
                        children: [
                          _buildHeader(gameProvider),
                          const SizedBox(height: 20),
                          ScoreBoard(
                            players: game.players,
                            theme: widget.theme,
                            currentPlayerIndex: game.currentPlayerIndex,
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: _buildGameBoard(gameProvider),
                          ),
                          const SizedBox(height: 20),
                          _buildGameControls(gameProvider),
                        ],
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

  Widget _buildHeader(GameProvider gameProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _showExitConfirmationDialog();
          },
        ),
        Expanded(
          child: Text(
            'Jogo da Memória',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            _showRestartConfirmationDialog(gameProvider);
          },
        ),
      ],
    );
  }

  Widget _buildGameBoard(GameProvider gameProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcula o número de colunas baseado na orientação e tamanho da tela
        final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
        final crossAxisCount = isPortrait ? 4 : 5; // 4 colunas no modo retrato, 5 no modo paisagem
        
        // Calcula o tamanho das cartas baseado no espaço disponível
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        
        // Calcula o tamanho ideal das cartas
        final cardWidth = (availableWidth - (crossAxisCount + 1) * 8) / crossAxisCount;
        final cardHeight = cardWidth * 1.4; // Proporção 1:1.4 para as cartas
        
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1 / 1.4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: gameProvider.game.cards.length,
          itemBuilder: (context, index) {
            final card = gameProvider.game.cards[index];
            return FlipCard(
              key: ValueKey(card.id),
              flipOnTouch: !card.isMatched && !card.isFlipped && !gameProvider.isProcessing,
              front: _buildCardFace(
                card,
                gameProvider,
                cardWidth,
                cardHeight,
                isBack: true,
              ),
              back: _buildCardFace(
                card,
                gameProvider,
                cardWidth,
                cardHeight,
                isBack: false,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCardFace(
    CardModel card,
    GameProvider gameProvider,
    double width,
    double height, {
    required bool isBack,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagem de fundo
            Image.asset(
              isBack ? widget.theme.cardBackImage : card.imagePath,
              fit: BoxFit.cover,
            ),
            // Overlay para cartas viradas
            if (!isBack && card.isFlipped)
              Container(
                color: Colors.black.withOpacity(0.3),
              ),
            // Overlay para cartas combinadas
            if (card.isMatched)
              Container(
                color: Colors.green.withOpacity(0.3),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameControls(GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Movimentos: ${gameProvider.game.totalMoves}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Reiniciar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.theme.primaryColor,
              foregroundColor: Colors.white,
            ),
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