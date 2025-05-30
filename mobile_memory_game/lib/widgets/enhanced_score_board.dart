import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/player_model.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/models/game_model.dart';
import 'package:mobile_memory_game/widgets/floating_combo_display.dart';
import 'package:mobile_memory_game/widgets/animated_timer.dart';
import 'package:mobile_memory_game/widgets/power_up_effects.dart';
import 'package:provider/provider.dart';
import 'package:mobile_memory_game/providers/game_provider.dart';

class EnhancedScoreBoard extends StatefulWidget {
  final List<PlayerModel> players;
  final ThemeModel theme;
  final int currentPlayerIndex;
  final bool isCompact;
  final int comboCount;
  final int maxCombo;
  
  // Campos do timer
  final GameMode gameMode;
  final String? formattedTimeRemaining;
  final bool isTimerPaused;
  final VoidCallback? onTimerTap;

  const EnhancedScoreBoard({
    super.key,
    required this.players,
    required this.theme,
    required this.currentPlayerIndex,
    this.isCompact = false,
    this.comboCount = 0,
    this.maxCombo = 0,
    this.gameMode = GameMode.zen,
    this.formattedTimeRemaining,
    this.isTimerPaused = false,
    this.onTimerTap,
  });

  @override
  State<EnhancedScoreBoard> createState() => _EnhancedScoreBoardState();
}

class _EnhancedScoreBoardState extends State<EnhancedScoreBoard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _comboGlowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _comboGlowAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _comboGlowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _comboGlowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_comboGlowController);

    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
    
    // Iniciar efeito combo se necessário
    if (widget.comboCount >= 2) {
      _comboGlowController.repeat();
    }
  }

  @override
  void didUpdateWidget(EnhancedScoreBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Controlar animação do combo
    if (widget.comboCount >= 2 && oldWidget.comboCount < 2) {
      _comboGlowController.repeat();
    } else if (widget.comboCount < 2 && oldWidget.comboCount >= 2) {
      _comboGlowController.stop();
      _comboGlowController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _comboGlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verticalPadding = widget.isCompact ? 6.0 : 8.0; // Reduzido pela metade
    final horizontalPadding = widget.isCompact ? 16.0 : 20.0;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: widget.theme.primaryColor.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 4),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildEnhancedPlayerScore(
                  widget.players[0],
                  isCurrentPlayer: widget.currentPlayerIndex == 0,
                  isLeft: true,
                ),
              ),
              
              // Timer/Zen no centro entre os jogadores
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildTimerSection(),
              ),
              
              Expanded(
                child: _buildEnhancedPlayerScore(
                  widget.players[1],
                  isCurrentPlayer: widget.currentPlayerIndex == 1,
                  isLeft: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    return Center(
      child: widget.gameMode == GameMode.zen
          ? ZenModeIndicator(
              primaryColor: widget.theme.primaryColor,
              secondaryColor: widget.theme.secondaryColor,
            )
          : widget.formattedTimeRemaining != null
              ? AnimatedTimer(
                  timeText: widget.formattedTimeRemaining!,
                  isWarning: _isWarningTime(),
                  isCritical: _isCriticalTime(),
                  isPaused: widget.isTimerPaused,
                  onTap: widget.onTimerTap,
                  primaryColor: widget.theme.primaryColor,
                  secondaryColor: widget.theme.secondaryColor,
                )
              : const SizedBox(),
    );
  }

  bool _isWarningTime() {
    if (widget.formattedTimeRemaining == null) return false;
    
    // Extrai os segundos totais do formato MM:SS
    final parts = widget.formattedTimeRemaining!.split(':');
    if (parts.length != 2) return false;
    
    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = int.tryParse(parts[1]) ?? 0;
    final totalSeconds = minutes * 60 + seconds;
    
    return totalSeconds <= 30 && totalSeconds > 10; // Warning nos últimos 30 segundos
  }

  bool _isCriticalTime() {
    if (widget.formattedTimeRemaining == null) return false;
    
    // Extrai os segundos totais do formato MM:SS
    final parts = widget.formattedTimeRemaining!.split(':');
    if (parts.length != 2) return false;
    
    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = int.tryParse(parts[1]) ?? 0;
    final totalSeconds = minutes * 60 + seconds;
    
    return totalSeconds <= 10; // Critical nos últimos 10 segundos
  }

  Widget _buildEnhancedPlayerScore(
    PlayerModel player, {
    required bool isCurrentPlayer,
    required bool isLeft,
  }) {
    final nameFontSize = widget.isCompact ? 12.0 : 14.0;
    final scoreFontSize = widget.isCompact ? 18.0 : 20.0;
    final turnFontSize = widget.isCompact ? 9.0 : 10.0;
    
    // Verifica se deve mostrar efeito combo
    final showComboEffect = isCurrentPlayer && widget.comboCount >= 2;
    
    return AnimatedBuilder(
      animation: isCurrentPlayer ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        // Cores rainbow para combo - implementando de forma segura
        Color comboColor1 = widget.theme.primaryColor;
        Color comboColor2 = widget.theme.secondaryColor;
        
        if (showComboEffect && widget.comboCount >= 2) { // Iniciar rainbow no 2x
          try {
            final comboValue = _comboGlowAnimation.value.clamp(0.0, 1.0);
            final hue = (comboValue * 360) % 360;
            
            // Validar valores HSV
            if (hue.isNaN || hue.isInfinite) {
              comboColor1 = _getFallbackColor1(widget.comboCount);
              comboColor2 = _getFallbackColor2(widget.comboCount);
            } else {
              comboColor1 = HSVColor.fromAHSV(1.0, hue.clamp(0.0, 360.0), 0.7, 0.9).toColor();
              comboColor2 = HSVColor.fromAHSV(1.0, (hue + 60).clamp(0.0, 360.0) % 360, 0.7, 0.9).toColor();
            }
          } catch (e) {
            // Fallback para cores fixas em caso de erro
            comboColor1 = _getFallbackColor1(widget.comboCount);
            comboColor2 = _getFallbackColor2(widget.comboCount);
          }
        }
        
        // Validar valores das animações
        final pulseValue = isCurrentPlayer ? _pulseAnimation.value.clamp(0.5, 2.0) : 1.0;
        
        return Transform.scale(
          scale: pulseValue,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isCurrentPlayer
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: showComboEffect
                          ? [
                              comboColor1.withOpacity(0.3.clamp(0.0, 1.0)),
                              comboColor2.withOpacity(0.2.clamp(0.0, 1.0)),
                            ]
                          : [
                              widget.theme.primaryColor.withOpacity(0.2.clamp(0.0, 1.0)),
                              widget.theme.secondaryColor.withOpacity(0.15.clamp(0.0, 1.0)),
                            ],
                    )
                  : null,
              border: Border.all(
                color: isCurrentPlayer
                    ? (showComboEffect ? comboColor1.withOpacity(0.6.clamp(0.0, 1.0)) : widget.theme.primaryColor.withOpacity(0.4.clamp(0.0, 1.0)))
                    : Colors.grey.withOpacity(0.2.clamp(0.0, 1.0)),
                width: isCurrentPlayer ? (showComboEffect ? 3.0 : 2.5) : 1.0,
              ),
              boxShadow: isCurrentPlayer
                  ? [
                      BoxShadow(
                        color: showComboEffect 
                            ? comboColor1.withOpacity(0.4.clamp(0.0, 1.0))
                            : widget.theme.primaryColor.withOpacity(0.3.clamp(0.0, 1.0)),
                        blurRadius: showComboEffect ? 10 : 8,
                        offset: const Offset(0, 2),
                      ),
                      if (showComboEffect) ...[
                        BoxShadow(
                          color: comboColor2.withOpacity(0.4.clamp(0.0, 1.0)),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3.clamp(0.0, 1.0)),
                          blurRadius: 15,
                          offset: const Offset(0, -2),
                          spreadRadius: 1,
                        ),
                      ],
                    ]
                  : null,
            ),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Column(
              children: [
                // Nome do jogador com indicador de turno
                Row(
                  mainAxisAlignment: isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCurrentPlayer)
                      Icon(
                        Icons.play_arrow_rounded,
                        color: showComboEffect ? comboColor1 : widget.theme.primaryColor,
                        size: 16,
                      ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              player.name,
                              style: TextStyle(
                                fontSize: nameFontSize,
                                fontWeight: FontWeight.bold,
                                color: isCurrentPlayer
                                    ? (showComboEffect ? comboColor1 : widget.theme.primaryColor)
                                    : Colors.grey[700],
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Indicador de debuff
                          _buildDebuffIndicator(player),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Score com efeito de brilho
                AnimatedBuilder(
                  animation: isCurrentPlayer ? _glowAnimation : 
                             const AlwaysStoppedAnimation(1.0),
                  builder: (context, child) {
                    // Validar valores da animação de brilho
                    final glowValue = isCurrentPlayer ? _glowAnimation.value.clamp(0.0, 1.0) : 1.0;
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: isCurrentPlayer
                              ? (showComboEffect
                                  ? [
                                      comboColor1.withOpacity(0.15.clamp(0.0, 1.0)),
                                      comboColor2.withOpacity(0.15.clamp(0.0, 1.0)),
                                    ]
                                  : [
                                      widget.theme.primaryColor.withOpacity(0.1.clamp(0.0, 1.0)),
                                      widget.theme.secondaryColor.withOpacity(0.1.clamp(0.0, 1.0)),
                                    ])
                              : [
                                  Colors.grey.withOpacity(0.05.clamp(0.0, 1.0)),
                                  Colors.grey.withOpacity(0.05.clamp(0.0, 1.0)),
                                ],
                        ),
                        boxShadow: isCurrentPlayer
                            ? [
                                BoxShadow(
                                  color: showComboEffect
                                      ? comboColor1.withOpacity((0.3 * glowValue).clamp(0.0, 1.0))
                                      : widget.theme.primaryColor.withOpacity((0.2 * glowValue).clamp(0.0, 1.0)),
                                  blurRadius: showComboEffect ? 15 : 10,
                                  spreadRadius: showComboEffect ? 3 : 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: isCurrentPlayer
                                ? (showComboEffect ? comboColor1 : widget.theme.primaryColor)
                                : Colors.amber[600],
                            size: widget.isCompact ? 16 : 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            player.score.toString(),
                            style: TextStyle(
                              fontSize: scoreFontSize,
                              fontWeight: FontWeight.bold,
                              color: isCurrentPlayer
                                  ? (showComboEffect ? comboColor1 : widget.theme.primaryColor)
                                  : Colors.grey[700],
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 3),
                
                // Indicador de turno
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: widget.isCompact ? 16 : 18,
                  child: isCurrentPlayer
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: showComboEffect
                                  ? [comboColor1, comboColor2]
                                  : [
                                      widget.theme.primaryColor,
                                      widget.theme.secondaryColor,
                                    ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: showComboEffect 
                                    ? comboColor1.withOpacity(0.4.clamp(0.0, 1.0))
                                    : widget.theme.primaryColor.withOpacity(0.3.clamp(0.0, 1.0)),
                                blurRadius: showComboEffect ? 10 : 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            showComboEffect && widget.comboCount >= 3 ? 'COMBO!' : 'SUA VEZ!',
                            style: TextStyle(
                              fontSize: turnFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getFallbackColor1(int comboCount) {
    if (comboCount >= 5) {
      return Colors.purple.shade600;
    } else if (comboCount >= 3) {
      return Colors.orange.shade600;
    } else {
      return widget.theme.primaryColor;
    }
  }

  Color _getFallbackColor2(int comboCount) {
    if (comboCount >= 5) {
      return Colors.pink.shade500;
    } else if (comboCount >= 3) {
      return Colors.red.shade500;
    } else {
      return widget.theme.secondaryColor;
    }
  }

  Widget _buildDebuffIndicator(PlayerModel player) {
    final gameProvider = context.watch<GameProvider>();
    final game = gameProvider.game;
    
    // Encontra o índice do jogador
    final playerIndex = widget.players.indexOf(player);
    if (playerIndex == -1) return const SizedBox.shrink();
    
    // Verifica qual debuff está ativo no jogador
    final activeDebuff = game.getActiveDebuffForPlayer(playerIndex);
    
    if (activeDebuff == null) return const SizedBox.shrink();
    
    final powerup = PowerUp.getPowerUp(activeDebuff);
    
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: _getDebuffColor(activeDebuff).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getDebuffColor(activeDebuff),
          width: 1,
        ),
      ),
      child: Text(
        powerup.icon,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Color _getDebuffColor(PowerUpType debuffType) {
    switch (debuffType) {
      case PowerUpType.upsideDown:
        return Colors.red;
      case PowerUpType.allYourMud:
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
} 