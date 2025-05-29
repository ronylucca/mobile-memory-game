import 'package:flutter/material.dart';
import 'dart:math' as math;

enum PowerUpType {
  hint,      // Mostra brevemente 2 cartas que fazem par
  freeze,    // Pausa o timer por alguns segundos  
  doublePoints, // Próximo acerto vale pontos duplos
  xray,      // Mostra todas as cartas por 1 segundo
  shuffle,   // Embaralha as cartas
  lightning, // Remove automaticamente um par
}

class PowerUp {
  final PowerUpType type;
  final String name;
  final String description;
  final String icon;
  final Duration duration;
  final int cost; // Custo em pontos ou moedas

  const PowerUp({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.duration,
    required this.cost,
  });

  static const List<PowerUp> availablePowerUps = [
    PowerUp(
      type: PowerUpType.hint,
      name: 'Dica',
      description: 'Revela um par por 2 segundos',
      icon: '💡',
      duration: Duration(seconds: 2),
      cost: 50,
    ),
    PowerUp(
      type: PowerUpType.freeze,
      name: 'Congelar',
      description: 'Pausa o timer por 5 segundos',
      icon: '❄️',
      duration: Duration(seconds: 5),
      cost: 75,
    ),
    PowerUp(
      type: PowerUpType.doublePoints,
      name: 'Pontos Duplos',
      description: 'Próximo acerto vale 2x pontos',
      icon: '⭐',
      duration: Duration(seconds: 30),
      cost: 100,
    ),
    PowerUp(
      type: PowerUpType.xray,
      name: 'Raio-X',
      description: 'Mostra todas as cartas por 1 segundo',
      icon: '👁️',
      duration: Duration(seconds: 1),
      cost: 150,
    ),
  ];
}

class PowerUpButton extends StatefulWidget {
  final PowerUp powerUp;
  final bool isAvailable;
  final bool isActive;
  final VoidCallback? onPressed;

  const PowerUpButton({
    super.key,
    required this.powerUp,
    this.isAvailable = true,
    this.isActive = false,
    this.onPressed,
  });

  @override
  State<PowerUpButton> createState() => _PowerUpButtonState();
}

class _PowerUpButtonState extends State<PowerUpButton>
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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
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
    
    if (widget.isAvailable) {
      _pulseController.repeat(reverse: true);
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PowerUpButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isAvailable && !oldWidget.isAvailable) {
      _pulseController.repeat(reverse: true);
      _glowController.repeat(reverse: true);
    } else if (!widget.isAvailable && oldWidget.isAvailable) {
      _pulseController.stop();
      _glowController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Color _getPowerUpColor() {
    switch (widget.powerUp.type) {
      case PowerUpType.hint:
        return Colors.amber;
      case PowerUpType.freeze:
        return Colors.cyan;
      case PowerUpType.doublePoints:
        return Colors.green;
      case PowerUpType.xray:
        return Colors.purple;
      case PowerUpType.shuffle:
        return Colors.orange;
      case PowerUpType.lightning:
        return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPowerUpColor();
    
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
      builder: (context, child) {
        final pulseValue = widget.isAvailable ? _pulseAnimation.value : 1.0;
        final glowValue = widget.isAvailable ? _glowAnimation.value : 0.3;
        
        return Transform.scale(
          scale: pulseValue.clamp(0.8, 1.2),
          child: GestureDetector(
            onTap: widget.isAvailable ? widget.onPressed : null,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isAvailable
                      ? [
                          color.withOpacity(0.8),
                          color.withOpacity(0.6),
                        ]
                      : [
                          Colors.grey.withOpacity(0.3),
                          Colors.grey.withOpacity(0.2),
                        ],
                ),
                boxShadow: widget.isAvailable
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.4 * glowValue),
                          blurRadius: 15 * glowValue,
                          spreadRadius: 3 * glowValue,
                        ),
                      ]
                    : null,
                border: Border.all(
                  color: widget.isActive
                      ? Colors.white
                      : (widget.isAvailable ? color : Colors.grey),
                  width: widget.isActive ? 3 : 2,
                ),
              ),
              child: Stack(
                children: [
                  // Ícone principal
                  Center(
                    child: Text(
                      widget.powerUp.icon,
                      style: TextStyle(
                        fontSize: 24,
                        color: widget.isAvailable ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                  
                  // Custo
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.7),
                      ),
                      child: Text(
                        '${widget.powerUp.cost}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // Indicador ativo
                  if (widget.isActive)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: CustomPaint(
                            painter: ActivePowerUpPainter(),
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
}

class ActivePowerUpPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Efeito pulsante
    for (int i = 0; i < 3; i++) {
      final alpha = 1.0 - (i * 0.3);
      paint.color = Colors.white.withOpacity(0.1 * alpha);
      canvas.drawCircle(center, radius + (i * 5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Widget para efeitos visuais dos power-ups
class PowerUpEffectOverlay extends StatefulWidget {
  final PowerUpType type;
  final VoidCallback? onComplete;

  const PowerUpEffectOverlay({
    super.key,
    required this.type,
    this.onComplete,
  });

  @override
  State<PowerUpEffectOverlay> createState() => _PowerUpEffectOverlayState();
}

class _PowerUpEffectOverlayState extends State<PowerUpEffectOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: _getEffectDuration(),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  Duration _getEffectDuration() {
    switch (widget.type) {
      case PowerUpType.hint:
        return const Duration(milliseconds: 2000);
      case PowerUpType.freeze:
        return const Duration(milliseconds: 500);
      case PowerUpType.doublePoints:
        return const Duration(milliseconds: 1000);
      case PowerUpType.xray:
        return const Duration(milliseconds: 1000);
      case PowerUpType.shuffle:
        return const Duration(milliseconds: 800);
      case PowerUpType.lightning:
        return const Duration(milliseconds: 1500);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return _buildEffect();
      },
    );
  }

  Widget _buildEffect() {
    switch (widget.type) {
      case PowerUpType.freeze:
        return _buildFreezeEffect();
      case PowerUpType.doublePoints:
        return _buildDoublePointsEffect();
      case PowerUpType.xray:
        return _buildXRayEffect();
      case PowerUpType.lightning:
        return _buildLightningEffect();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFreezeEffect() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: _animation.value * 2,
          colors: [
            Colors.cyan.withOpacity(0.0),
            Colors.cyan.withOpacity(0.3 * _animation.value),
            Colors.blue.withOpacity(0.6 * _animation.value),
          ],
        ),
      ),
      child: CustomPaint(
        painter: SnowflakePainter(progress: _animation.value),
        child: Container(),
      ),
    );
  }

  Widget _buildDoublePointsEffect() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: _animation.value,
          colors: [
            Colors.yellow.withOpacity(0.8 * _animation.value),
            Colors.orange.withOpacity(0.4 * _animation.value),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Transform.scale(
          scale: _animation.value,
          child: const Text(
            '2X',
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildXRayEffect() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple.withOpacity(0.1 * _animation.value),
            Colors.pink.withOpacity(0.2 * _animation.value),
            Colors.purple.withOpacity(0.1 * _animation.value),
          ],
        ),
      ),
      child: CustomPaint(
        painter: XRayPainter(progress: _animation.value),
        child: Container(),
      ),
    );
  }

  Widget _buildLightningEffect() {
    return CustomPaint(
      painter: LightningPainter(progress: _animation.value),
      child: Container(),
    );
  }
}

// Painters para efeitos específicos
class SnowflakePainter extends CustomPainter {
  final double progress;
  
  SnowflakePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8 * progress)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + (progress * math.pi * 2);
      final endX = center.dx + math.cos(angle) * 50 * progress;
      final endY = center.dy + math.sin(angle) * 50 * progress;
      
      canvas.drawLine(center, Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class XRayPainter extends CustomPainter {
  final double progress;
  
  XRayPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple.withOpacity(0.6 * progress)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Linhas de scan
    for (int i = 0; i < 10; i++) {
      final y = (size.height / 10) * i + (progress * size.height * 0.1);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LightningPainter extends CustomPainter {
  final double progress;
  
  LightningPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.withOpacity(progress)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final startX = size.width * 0.3;
    final endX = size.width * 0.7;
    final height = size.height * progress;
    
    path.moveTo(startX, 0);
    path.lineTo(startX + 20, height * 0.3);
    path.lineTo(startX - 10, height * 0.6);
    path.lineTo(endX, height);
    
    canvas.drawPath(path, paint);
    
    // Efeito de brilho
    paint.color = Colors.white.withOpacity(0.8 * progress);
    paint.strokeWidth = 2;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 