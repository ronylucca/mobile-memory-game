import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:mobile_memory_game/models/card_model.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/utils/audio_manager.dart';
import 'package:mobile_memory_game/providers/game_provider.dart';
import 'package:mobile_memory_game/widgets/particle_system.dart';
import 'package:provider/provider.dart';

class EnhancedMemoryCard extends StatefulWidget {
  final CardModel card;
  final ThemeModel theme;
  final Function(int) onCardTap;
  final int index;
  final GlobalKey<FlipCardState>? flipCardKey;
  final Size? cardSize;

  const EnhancedMemoryCard({
    super.key,
    required this.card,
    required this.theme,
    required this.onCardTap,
    required this.index,
    this.flipCardKey,
    this.cardSize,
  });

  @override
  State<EnhancedMemoryCard> createState() => _EnhancedMemoryCardState();
}

class _EnhancedMemoryCardState extends State<EnhancedMemoryCard>
    with TickerProviderStateMixin {
  final AudioManager _audioManager = AudioManager();
  late GlobalKey<FlipCardState> _flipCardKey;
  
  // Controllers para animações
  late AnimationController _glowController;
  late AnimationController _successController;
  late AnimationController _pulseController;
  
  // Animações
  late Animation<double> _glowAnimation;
  late Animation<double> _successAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _successColorAnimation;
  
  bool _wasMatched = false;
  bool _showingMatchFeedback = false;

  @override
  void initState() {
    super.initState();
    _flipCardKey = widget.flipCardKey ?? GlobalKey<FlipCardState>();
    _wasMatched = widget.card.isMatched;
    
    // Inicializa controllers
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Configura animações
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _successAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _successColorAnimation = ColorTween(
      begin: Colors.green.shade400,
      end: Colors.green.shade200,
    ).animate(_successController);
    
    // Inicia animação de pulso para cartas matched
    if (widget.card.isMatched) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(EnhancedMemoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Detecta mudanças no estado da carta
    if (oldWidget.card.isFlipped != widget.card.isFlipped) {
      if (widget.card.isFlipped) {
        _flipCardKey.currentState?.toggleCard();
        _startGlowEffect();
      } else if (!widget.card.isFlipped) {
        if (_flipCardKey.currentState?.isFront == false) {
          _flipCardKey.currentState?.toggleCard();
        }
      }
    }
    
    // Detecta match
    if (!_wasMatched && widget.card.isMatched) {
      _wasMatched = true;
      _startSuccessEffect();
    }
  }

  void _startGlowEffect() {
    _glowController.forward().then((_) {
      _glowController.reverse();
    });
  }

  void _startSuccessEffect() {
    setState(() {
      _showingMatchFeedback = true;
    });
    
    // Dispara partículas de explosão na posição da carta
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final cardCenter = position + Offset(
        renderBox.size.width / 2,
        renderBox.size.height / 2,
      );
      
      // Busca o ParticleSystem mais próximo
      final particleSystem = ParticleSystem.of(context);
      if (particleSystem != null) {
        final gameProvider = context.read<GameProvider>();
        final game = gameProvider.game;
        final playerColor = _getMatchedPlayerColor(game);
        
        // Explosão de partículas na cor do jogador
        particleSystem.explode(
          position: cardCenter,
          color: playerColor,
          count: 12,
          intensity: 1.0,
        );
        
        // Sparkles adicionais
        Future.delayed(const Duration(milliseconds: 200), () {
          particleSystem.sparkle(
            position: cardCenter,
            color: playerColor.withOpacity(0.8),
            count: 6,
          );
        });
      }
    }
    
    _successController.forward().then((_) {
      _successController.reverse().then((_) {
        setState(() {
          _showingMatchFeedback = false;
        });
        _pulseController.repeat(reverse: true);
      });
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _successController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useIcons = context.select<GameProvider, bool>((provider) => provider.useIcons);
    final gameProvider = context.watch<GameProvider>();
    final game = gameProvider.game;
    
    Widget cardWidget = AnimatedBuilder(
      animation: Listenable.merge([
        _glowAnimation,
        _successAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
            scale: _showingMatchFeedback
                ? _successAnimation.value
                : (widget.card.isMatched ? _pulseAnimation.value : 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  // Sombra base
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5.0,
                    offset: const Offset(2, 2),
                  ),
                  // Glow effect quando carta é virada
                  if (_glowAnimation.value > 0 || widget.card.isFlipped)
                    BoxShadow(
                      color: _getPlayerColor(game).withOpacity(
                        0.5 * _glowAnimation.value,
                      ),
                      blurRadius: 15.0 * _glowAnimation.value,
                      spreadRadius: 3.0 * _glowAnimation.value,
                    ),
                  // Efeito de sucesso
                  if (_showingMatchFeedback)
                    BoxShadow(
                      color: Colors.green.withOpacity(0.6),
                      blurRadius: 20.0,
                      spreadRadius: 5.0,
                    ),
                  // Glow permanente para cartas matched com cor do jogador
                  if (widget.card.isMatched && !_showingMatchFeedback)
                    BoxShadow(
                      color: _getMatchedPlayerColor(game).withOpacity(0.4),
                      blurRadius: 8.0,
                      spreadRadius: 2.0,
                    ),
                ],
              ),
              child: FlipCard(
                key: _flipCardKey,
                speed: 400,
                direction: FlipDirection.HORIZONTAL,
                flipOnTouch: false,
                front: _buildCardFront(),
                back: _buildCardBack(useIcons),
              ),
            ),
          );
        },
    );
    
    // Se um tamanho específico foi fornecido, use-o
    if (widget.cardSize != null) {
      cardWidget = SizedBox(
        width: widget.cardSize!.width,
        height: widget.cardSize!.height,
        child: cardWidget,
      );
    }
    
    return GestureDetector(
      onTap: () {
        if (!widget.card.isFlipped && !widget.card.isMatched) {
          widget.onCardTap(widget.index);
          _audioManager.playThemeSound('card_flip');
        }
      },
      child: cardWidget,
    );
  }

  Widget _buildCardFront() {
    final gameProvider = context.watch<GameProvider>();
    final game = gameProvider.game;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF404040),
            const Color(0xFF303030),
          ],
        ),
        border: Border.all(
          color: widget.card.isMatched 
              ? _getMatchedPlayerColor(game)
              : widget.theme.primaryColor.withOpacity(0.5),
          width: widget.card.isMatched ? 2.0 : 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                widget.theme.cardBackImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.question_mark,
                    size: 40,
                    color: widget.theme.primaryColor,
                  );
                },
              ),
            ),
            // Overlay para cartas matched com cor do jogador
            if (widget.card.isMatched)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getMatchedPlayerColor(game).withOpacity(0.2),
                      _getMatchedPlayerColor(game).withOpacity(0.1),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(bool useIcons) {
    final gameProvider = context.watch<GameProvider>();
    final game = gameProvider.game;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _showingMatchFeedback
              ? [
                  _successColorAnimation.value!,
                  Colors.green.shade300,
                ]
              : [
                  Colors.white,
                  Colors.grey.shade50,
                ],
        ),
        border: Border.all(
          color: _showingMatchFeedback
              ? Colors.green.shade400
              : (widget.card.isMatched 
                  ? _getMatchedPlayerColor(game)
                  : widget.theme.secondaryColor),
          width: widget.card.isMatched ? 2.0 : 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: useIcons 
                    ? _getIconForPairId(widget.card.pairId)
                    : Image.asset(
                        widget.card.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return _getIconForPairId(widget.card.pairId);
                        },
                      ),
              ),
            ),
            // Efeito de sucesso com partículas
            if (_showingMatchFeedback)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.withOpacity(0.3),
                        Colors.transparent,
                        Colors.green.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),
            // Ícone de sucesso
            if (_showingMatchFeedback)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _getIconForPairId(int pairId) {
    final icons = [
      Icons.favorite,
      Icons.star,
      Icons.emoji_emotions,
      Icons.pets,
      Icons.flight,
      Icons.beach_access,
      Icons.cake,
      Icons.directions_bike,
      Icons.music_note,
      Icons.emoji_nature,
    ];
    
    final iconIndex = (pairId - 1) % icons.length;
    
    return Icon(
      icons[iconIndex],
      size: 40,
      color: _showingMatchFeedback 
          ? Colors.white 
          : widget.theme.primaryColor,
    );
  }
  
  // Obtém a cor do jogador atual (para glow quando vira carta)
  Color _getPlayerColor(dynamic game) {
    return game.currentPlayerIndex == 0 
        ? game.player1Color 
        : game.player2Color;
  }
  
  // Obtém a cor do jogador que fez o match desta carta
  Color _getMatchedPlayerColor(dynamic game) {
    if (widget.card.matchedByPlayer == null) {
      return Colors.green; // Fallback
    }
    
    return widget.card.matchedByPlayer == 0 
        ? game.player1Color 
        : game.player2Color;
  }
} 