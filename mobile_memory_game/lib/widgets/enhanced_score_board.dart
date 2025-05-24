import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/player_model.dart';
import 'package:mobile_memory_game/models/theme_model.dart';

class EnhancedScoreBoard extends StatefulWidget {
  final List<PlayerModel> players;
  final ThemeModel theme;
  final int currentPlayerIndex;
  final bool isCompact;

  const EnhancedScoreBoard({
    super.key,
    required this.players,
    required this.theme,
    required this.currentPlayerIndex,
    this.isCompact = false,
  });

  @override
  State<EnhancedScoreBoard> createState() => _EnhancedScoreBoardState();
}

class _EnhancedScoreBoardState extends State<EnhancedScoreBoard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
    
    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
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
              Container(
                width: 2,
                height: 30, // Reduzido de 60 para 30
                margin: const EdgeInsets.symmetric(horizontal: 12), // Reduzido margem
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      widget.theme.primaryColor.withOpacity(0.3),
                      widget.theme.secondaryColor.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
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

  Widget _buildEnhancedPlayerScore(
    PlayerModel player, {
    required bool isCurrentPlayer,
    required bool isLeft,
  }) {
    final nameFontSize = widget.isCompact ? 12.0 : 14.0; // Reduzido
    final scoreFontSize = widget.isCompact ? 18.0 : 20.0; // Reduzido
    final turnFontSize = widget.isCompact ? 9.0 : 10.0; // Reduzido
    
    return AnimatedBuilder(
      animation: isCurrentPlayer ? _pulseAnimation : 
                 const AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        return Transform.scale(
          scale: isCurrentPlayer ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isCurrentPlayer
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.theme.primaryColor.withOpacity(0.2),
                        widget.theme.secondaryColor.withOpacity(0.15),
                      ],
                    )
                  : null,
              border: Border.all(
                color: isCurrentPlayer
                    ? widget.theme.primaryColor.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.2),
                width: isCurrentPlayer ? 2.5 : 1.0,
              ),
              boxShadow: isCurrentPlayer
                  ? [
                      BoxShadow(
                        color: widget.theme.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), // Reduzido
            child: Column(
              children: [
                // Nome do jogador com ícone
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isLeft ? Icons.person : Icons.person_outline,
                      color: isCurrentPlayer
                          ? widget.theme.primaryColor
                          : Colors.grey[600],
                      size: widget.isCompact ? 14 : 16, // Reduzido
                    ),
                    const SizedBox(width: 4), // Reduzido
                    Flexible(
                      child: Text(
                        player.name,
                        style: TextStyle(
                          fontSize: nameFontSize,
                          fontWeight: FontWeight.bold,
                          color: isCurrentPlayer
                              ? widget.theme.primaryColor
                              : Colors.grey[700],
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4), // Reduzido
                
                // Score com efeito de brilho
                AnimatedBuilder(
                  animation: isCurrentPlayer ? _glowAnimation : 
                             const AlwaysStoppedAnimation(1.0),
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, // Reduzido
                        vertical: 3, // Reduzido
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: isCurrentPlayer
                              ? [
                                  widget.theme.primaryColor.withOpacity(0.1),
                                  widget.theme.secondaryColor.withOpacity(0.1),
                                ]
                              : [
                                  Colors.grey.withOpacity(0.05),
                                  Colors.grey.withOpacity(0.05),
                                ],
                        ),
                        boxShadow: isCurrentPlayer
                            ? [
                                BoxShadow(
                                  color: widget.theme.primaryColor.withOpacity(
                                    0.2 * _glowAnimation.value,
                                  ),
                                  blurRadius: 10,
                                  spreadRadius: 2,
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
                                ? widget.theme.primaryColor
                                : Colors.amber[600],
                            size: widget.isCompact ? 16 : 18, // Reduzido
                          ),
                          const SizedBox(width: 4), // Reduzido
                          Text(
                            player.score.toString(),
                            style: TextStyle(
                              fontSize: scoreFontSize,
                              fontWeight: FontWeight.bold,
                              color: isCurrentPlayer
                                  ? widget.theme.primaryColor
                                  : Colors.grey[700],
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 3), // Reduzido
                
                // Indicador de turno
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: widget.isCompact ? 16 : 18, // Reduzido
                  child: isCurrentPlayer
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, // Reduzido
                            vertical: 1, // Reduzido
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                widget.theme.primaryColor,
                                widget.theme.secondaryColor,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.theme.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'SUA VEZ!',
                            style: TextStyle(
                              fontSize: turnFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 