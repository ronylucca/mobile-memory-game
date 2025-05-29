import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/achievement_model.dart';

class AchievementPopup extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementPopup({
    super.key,
    required this.achievement,
    this.onDismiss,
  });

  @override
  State<AchievementPopup> createState() => _AchievementPopupState();
}

class _AchievementPopupState extends State<AchievementPopup>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _confettiController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));
    
    _startAnimations();
    
    // Auto dismiss após 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismissPopup();
      }
    });
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _slideController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    _glowController.repeat(reverse: true);
    
    if (widget.achievement.rarity == AchievementRarity.epic ||
        widget.achievement.rarity == AchievementRarity.legendary) {
      _confettiController.forward();
    }
  }

  void _dismissPopup() async {
    _glowController.stop();
    _confettiController.stop();
    
    await _scaleController.reverse();
    await _slideController.reverse();
    
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Color _getRarityColor() {
    switch (widget.achievement.rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  List<Color> _getRarityGradient() {
    final baseColor = _getRarityColor();
    return [
      baseColor.withOpacity(0.8),
      baseColor.withOpacity(0.6),
      baseColor.withOpacity(0.9),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _slideAnimation,
        _scaleAnimation,
        _glowAnimation,
        _confettiAnimation,
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value.clamp(0.0, 1.5),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getRarityGradient(),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getRarityColor().withOpacity(
                      (0.6 * _glowAnimation.value).clamp(0.0, 1.0)
                    ),
                    blurRadius: 30 * _glowAnimation.value.clamp(0.0, 2.0),
                    spreadRadius: 5 * _glowAnimation.value.clamp(0.0, 1.5),
                    offset: const Offset(0, 8),
                  ),
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Confetti effect para conquistas épicas/lendárias
                  if (widget.achievement.rarity == AchievementRarity.epic ||
                      widget.achievement.rarity == AchievementRarity.legendary)
                    _buildConfettiEffect(),
                  
                  // Conteúdo principal
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header com "Conquista Desbloqueada!"
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Text(
                            '🏆 CONQUISTA DESBLOQUEADA!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Ícone da conquista
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.achievement.icon,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Nome da conquista
                        Text(
                          widget.achievement.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Descrição
                        Text(
                          widget.achievement.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.3,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Reward XP
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '+${widget.achievement.rewardXP} XP',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Botão de fechar (opcional)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _dismissPopup,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfettiEffect() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _confettiAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: ConfettiPainter(
              progress: _confettiAnimation.value,
              colors: [
                Colors.yellow,
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.purple,
                Colors.orange,
              ],
            ),
          );
        },
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  
  ConfettiPainter({
    required this.progress,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (int i = 0; i < 20; i++) {
      final x = (size.width * 0.1) + (size.width * 0.8 * (i / 20));
      final y = size.height * 0.1 + (size.height * 0.8 * progress);
      
      paint.color = colors[i % colors.length].withOpacity(1 - progress);
      
      canvas.drawCircle(
        Offset(x, y),
        3 * (1 - progress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Função helper para mostrar o popup
class AchievementNotifier {
  static OverlayEntry? _currentOverlay;

  static void show(BuildContext context, Achievement achievement) {
    // Remove popup anterior se existir
    dismiss();
    
    _currentOverlay = OverlayEntry(
      builder: (context) => AchievementPopup(
        achievement: achievement,
        onDismiss: dismiss,
      ),
    );
    
    Overlay.of(context).insert(_currentOverlay!);
  }

  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
} 