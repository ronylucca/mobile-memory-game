import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  late AnimationController _rainbowController;
  
  // Animações
  late Animation<double> _glowAnimation;
  late Animation<double> _successAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rainbowAnimation;
  late Animation<Color?> _successColorAnimation;
  
  bool _wasMatched = false;
  bool _showingMatchFeedback = false;
  bool _isShowingBonusEffect = false; // Controla se está mostrando efeito de bônus
  bool _wasXrayActive = false; // Rastreia se X-ray estava ativo no frame anterior
  bool _xrayJustExpired = false; // Flag para evitar múltiplas chamadas de reset

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
    
    _rainbowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
    
    _rainbowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rainbowController,
      curve: Curves.linear,
    ));
    
    _successColorAnimation = ColorTween(
      begin: Colors.green.shade400,
      end: Colors.green.shade200,
    ).animate(_successController);
    
    // Inicia animação de pulso para cartas matched
    if (widget.card.isMatched) {
      _pulseController.repeat(reverse: true);
    }
    
    // Inicializa o estado do X-ray
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final gameProvider = context.read<GameProvider>();
        _wasXrayActive = gameProvider.game.isPeekStillActive;
      }
    });
  }

  @override
  void didUpdateWidget(EnhancedMemoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final gameProvider = context.read<GameProvider>();
    final game = gameProvider.game;
    
    // Detecta se X-ray foi desativado
    final isXrayActiveNow = game.isPeekStillActive;
    if (_wasXrayActive && !isXrayActiveNow && !widget.card.isFlipped && !widget.card.isMatched && !_xrayJustExpired) {
      // X-ray foi desativado, força carta não clicada a voltar para front (verso)
      _xrayJustExpired = true;
      print('👁️ X-RAY EXPIROU - Carta ${widget.index} voltando ao estado normal');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && _flipCardKey.currentState?.isFront == false) {
          _flipCardKey.currentState?.toggleCard();
          print('👁️ X-RAY RESET - Carta ${widget.index} voltou ao front');
        }
        _xrayJustExpired = false; // Reset da flag após o callback
      });
    }
    _wasXrayActive = isXrayActiveNow;
    
    // Detecta mudanças no estado da carta
    if (oldWidget.card.isFlipped != widget.card.isFlipped) {
      if (widget.card.isFlipped) {
        _flipCardKey.currentState?.toggleCard();
        _startGlowEffect();
        
        // Verifica se é uma jogada bônus e esta é a primeira carta selecionada
        if (game.isCurrentMoveBonus && game.selectedCardIndex == widget.index) {
          setState(() {
            _isShowingBonusEffect = true;
          });
          _rainbowController.repeat();
        }
      } else if (!widget.card.isFlipped) {
        if (_flipCardKey.currentState?.isFront == false) {
          _flipCardKey.currentState?.toggleCard();
        }
        
        // Para o efeito rainbow quando a carta vira para baixo (erro)
        if (_isShowingBonusEffect) {
          setState(() {
            _isShowingBonusEffect = false;
          });
          _rainbowController.stop();
          _rainbowController.reset();
        }
      }
    }
    
    // Detecta match
    if (!_wasMatched && widget.card.isMatched) {
      _wasMatched = true;
      _startSuccessEffect();
      
      // Para o efeito rainbow quando acerta (sucesso)
      if (_isShowingBonusEffect) {
        setState(() {
          _isShowingBonusEffect = false;
        });
        _rainbowController.stop();
        _rainbowController.reset();
      }
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
    _rainbowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useIcons = context.select<GameProvider, bool>((provider) => provider.useIcons);
    final gameProvider = context.watch<GameProvider>();
    final game = gameProvider.game;
    
    // Apenas o X-ray deve forçar a exibição do conteúdo
    // Cartas clicadas seguem a animação natural do FlipCard
    final shouldShowCardDueToXray = game.isPeekStillActive && 
                                   !widget.card.isFlipped && 
                                   !widget.card.isMatched;
                                   
    // Verifica se esta carta específica deve ser mostrada pelo hint
    final shouldShowCardDueToHint = game.isHintStillActive && 
                                   game.hintCardIndices != null &&
                                   game.hintCardIndices!.contains(widget.index) &&
                                   !widget.card.isFlipped && 
                                   !widget.card.isMatched;

    // Verifica se o jogador atual está afetado por debuffs
    final isCurrentPlayerAffectedByUpsideDown = game.isPlayerAffectedByUpsideDown(game.currentPlayerIndex);
    final isCurrentPlayerAffectedByMud = game.isPlayerAffectedByMud(game.currentPlayerIndex);
    
    Widget cardWidget = AnimatedBuilder(
      animation: Listenable.merge([
        _glowAnimation,
        _successAnimation,
        _pulseAnimation,
        _rainbowAnimation,
      ]),
      builder: (context, child) {
        Widget baseCard = Transform.scale(
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
                  // Efeito rainbow para cartas bônus
                  if (_isShowingBonusEffect)
                    BoxShadow(
                      color: _getRainbowColor(_rainbowAnimation.value).withOpacity(0.8),
                      blurRadius: 20.0,
                      offset: const Offset(0, 0),
                      spreadRadius: 8.0,
                    ),
                  // Glow effect quando carta é virada
                  if (_glowAnimation.value > 0 || widget.card.isFlipped)
                    BoxShadow(
                      color: _getPlayerColor(game).withOpacity(
                        0.5 * _glowAnimation.value,
                      ),
                      blurRadius: 15.0 * _glowAnimation.value,
                      offset: const Offset(0, 0),
                      spreadRadius: 3.0 * _glowAnimation.value,
                    ),
                  // Efeito especial para X-ray
                  if (shouldShowCardDueToXray)
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.6),
                      blurRadius: 12.0,
                      offset: const Offset(0, 0),
                      spreadRadius: 4.0,
                    ),
                  // Efeito especial para hint
                  if (shouldShowCardDueToHint)
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.7),
                      blurRadius: 15.0,
                      offset: const Offset(0, 0),
                      spreadRadius: 5.0,
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
                  // Efeito de Mud (água/borrado)
                  if (isCurrentPlayerAffectedByMud)
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.5),
                      blurRadius: 20.0,
                      offset: const Offset(0, 0),
                      spreadRadius: 8.0,
                    ),
                ],
              ),
              child: FlipCard(
                key: _flipCardKey,
                speed: 400,
                direction: FlipDirection.HORIZONTAL,
                flipOnTouch: false,
                // Apenas o X-ray força a exibição do conteúdo como front
                // Hint apenas destaca as cartas sem revelar conteúdo
                // Cartas clicadas seguem o fluxo normal: front -> back
                front: shouldShowCardDueToXray 
                    ? _buildCardBackWithXray(useIcons) 
                    : _buildCardFront(),
                back: _buildCardBack(useIcons),
              ),
            ),
          );

        // Aplica efeito de Upside Down (rotação 180°)
        if (isCurrentPlayerAffectedByUpsideDown) {
          baseCard = Transform.rotate(
            angle: 3.14159, // 180 graus em radianos
            child: baseCard,
          );
        }

        // Aplica efeito de Mud (filtro de blur/água)
        if (isCurrentPlayerAffectedByMud) {
          baseCard = Stack(
            children: [
              baseCard,
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.brown.withOpacity(0.3),
                        Colors.blue.withOpacity(0.2),
                        Colors.brown.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        backgroundBlendMode: BlendMode.multiply,
                        color: Colors.brown.withOpacity(0.2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.water_drop,
                          color: Colors.brown,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return baseCard;
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
    
    // Verifica se esta carta específica deve ser destacada pelo hint
    final shouldShowCardDueToHint = game.isHintStillActive && 
                                   game.hintCardIndices != null &&
                                   game.hintCardIndices!.contains(widget.index) &&
                                   !widget.card.isFlipped && 
                                   !widget.card.isMatched;
    
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
          color: _isShowingBonusEffect
              ? _getRainbowColor(_rainbowAnimation.value) // Borda rainbow para bônus
              : (shouldShowCardDueToHint
                  ? Colors.orange.withOpacity(0.9) // Destaque laranja para hint
                  : (widget.card.isMatched 
                      ? _getMatchedPlayerColor(game)
                      : widget.theme.primaryColor.withOpacity(0.5))),
          width: _isShowingBonusEffect
              ? 4.0 // Borda mais grossa para bônus
              : (shouldShowCardDueToHint ? 3.0 : (widget.card.isMatched ? 2.0 : 1.0)),
        ),
        // Adiciona boxShadow para o hint
        boxShadow: shouldShowCardDueToHint ? [
          BoxShadow(
            color: Colors.orange.withOpacity(0.7),
            blurRadius: 15.0,
            spreadRadius: 5.0,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.yellow.withOpacity(0.4),
            blurRadius: 25.0,
            spreadRadius: 10.0,
            offset: const Offset(0, 0),
          ),
        ] : null,
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
            // Overlay especial para hint ativo (destaque laranja)
            if (shouldShowCardDueToHint)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange.withOpacity(0.3),
                      Colors.yellow.withOpacity(0.2),
                      Colors.orange.withOpacity(0.1),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orange,
                    size: 30,
                  ),
                ),
              ),
            // Indicador de bônus da jogada (mostra quando carta é virada OU quando já foi matched)
            if (game.isCurrentMoveBonus && game.bonusCardIndex == widget.index && 
                (widget.card.isFlipped || widget.card.isMatched))
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: _isShowingBonusEffect
                        ? LinearGradient(
                            colors: [
                              _getRainbowColor(_rainbowAnimation.value),
                              _getRainbowColor((_rainbowAnimation.value + 0.3) % 1.0),
                            ],
                          )
                        : LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: _isShowingBonusEffect
                            ? _getRainbowColor(_rainbowAnimation.value).withOpacity(0.6)
                            : Colors.amber.withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    '+${game.currentMoveBonusPoints}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
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
            // Indicador de bônus (também aparece no back quando é carta bônus)
            if (game.isCurrentMoveBonus && game.bonusCardIndex == widget.index && 
                !_showingMatchFeedback) // Não mostra durante animação de sucesso
              Positioned(
                top: 4,
                left: 4, // Posição diferente para não conflitar com check
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    '+${game.currentMoveBonusPoints}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Versão especial para quando X-ray está ativo
  Widget _buildCardBackWithXray(bool useIcons) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.grey.shade100.withOpacity(0.9),
          ],
        ),
        border: Border.all(
          color: Colors.purple.withOpacity(0.8),
          width: 2.0,
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
            // Overlay especial para X-ray ativo
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.withOpacity(0.3),
                      Colors.blue.withOpacity(0.2),
                      Colors.purple.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
            // Ícone de X-ray
            const Positioned(
              top: 4,
              right: 4,
              child: Icon(
                Icons.visibility,
                color: Colors.white,
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

  Color _getRainbowColor(double value) {
    // Cria um efeito rainbow com HSV para cores mais vibrantes
    final hue = (value * 360) % 360;
    return HSVColor.fromAHSV(1.0, hue, 0.8, 1.0).toColor();
  }
} 