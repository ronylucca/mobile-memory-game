import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/providers/game_provider.dart';

class EnhancedGameControls extends StatefulWidget {
  final GameProvider gameProvider;
  final ThemeModel theme;
  final bool isCompact;
  final VoidCallback onRestart;
  final VoidCallback? onBack;

  const EnhancedGameControls({
    super.key,
    required this.gameProvider,
    required this.theme,
    required this.onRestart,
    this.onBack,
    this.isCompact = false,
  });

  @override
  State<EnhancedGameControls> createState() => _EnhancedGameControlsState();
}

class _EnhancedGameControlsState extends State<EnhancedGameControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = widget.isCompact ? 12.0 : 16.0;
    final fontSize = widget.isCompact ? 15.0 : 17.0;
    final iconSize = widget.isCompact ? 20.0 : 24.0;
    
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
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: widget.theme.primaryColor.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 4),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Row(
          children: [
            // Botão de voltar
            if (widget.onBack != null) ...[
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  padding: EdgeInsets.all(widget.isCompact ? 8 : 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.grey[700],
                    size: iconSize,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            
            // Informações do jogo
            Expanded(
              child: Row(
                children: [
                  // Ícone de movimentos
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          widget.theme.primaryColor.withOpacity(0.1),
                          widget.theme.secondaryColor.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: widget.theme.primaryColor,
                      size: iconSize,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Contador de movimentos
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Movimentos',
                        style: TextStyle(
                          fontSize: fontSize - 2,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${widget.gameProvider.game.totalMoves}',
                        style: TextStyle(
                          fontSize: fontSize + 2,
                          fontWeight: FontWeight.bold,
                          color: widget.theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Separador vertical
            Container(
              width: 1.5,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.grey.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            
            // Botão de reiniciar
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: GestureDetector(
                    onTapDown: (_) => _animationController.forward(),
                    onTapUp: (_) => _animationController.reverse(),
                    onTapCancel: () => _animationController.reverse(),
                    onTap: widget.onRestart,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.isCompact ? 16 : 20,
                        vertical: widget.isCompact ? 10 : 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.theme.primaryColor,
                            widget.theme.secondaryColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.theme.primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: iconSize,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Reiniciar',
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 