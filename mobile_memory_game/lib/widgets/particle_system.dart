import 'package:flutter/material.dart';
import 'dart:math' as math;

enum ParticleType {
  explosion,
  confetti, 
  sparkle,
  trail,
  star
}

class Particle {
  late Offset position;
  late Offset velocity;
  late double life;
  late double maxLife;
  late Color color;
  late double size;
  late double rotation;
  late double rotationSpeed;
  late ParticleType type;
  late double gravity;
  late double alpha;

  Particle({
    required this.position,
    required this.velocity,
    required this.life,
    required this.color,
    required this.size,
    required this.type,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    this.gravity = 0.0,
  }) {
    maxLife = life;
    alpha = 1.0;
  }

  void update(double deltaTime) {
    // Atualiza posição
    position += velocity * deltaTime;
    
    // Aplica gravidade
    velocity = Offset(velocity.dx, velocity.dy + gravity * deltaTime);
    
    // Atualiza rotação
    rotation += rotationSpeed * deltaTime;
    
    // Reduz vida
    life -= deltaTime;
    
    // Fade out baseado na vida restante
    alpha = (life / maxLife).clamp(0.0, 1.0);
    
    // Reduz tamanho para partículas de explosão
    if (type == ParticleType.explosion) {
      size *= 0.98;
    }
  }

  bool get isDead => life <= 0;
}

class ParticleSystem extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const ParticleSystem({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();

  static _ParticleSystemState? of(BuildContext context) {
    return context.findAncestorStateOfType<_ParticleSystemState>();
  }
}

class _ParticleSystemState extends State<ParticleSystem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 16), // ~60 FPS
      vsync: this,
    );
    _controller.addListener(_updateParticles);
    _startAnimation();
  }

  void _startAnimation() {
    _controller.repeat();
  }

  void _updateParticles() {
    if (!widget.enabled) return;
    
    setState(() {
      final deltaTime = 0.016; // 60 FPS aproximadamente
      
      // Atualiza partículas existentes
      for (int i = _particles.length - 1; i >= 0; i--) {
        _particles[i].update(deltaTime);
        
        // Remove partículas mortas
        if (_particles[i].isDead) {
          _particles.removeAt(i);
        }
      }
    });
  }

  // MÉTODO PÚBLICO: Explosão de partículas
  void explode({
    required Offset position,
    Color? color,
    int count = 15,
    double intensity = 1.0,
  }) {
    final baseColor = color ?? Colors.orange;
    
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * math.pi;
      final speed = 100 + _random.nextDouble() * 200 * intensity;
      final velocity = Offset(
        math.cos(angle) * speed,
        math.sin(angle) * speed,
      );

      final particle = Particle(
        position: position,
        velocity: velocity,
        life: 1.0 + _random.nextDouble() * 0.5,
        color: _randomizeColor(baseColor),
        size: 3 + _random.nextDouble() * 4,
        type: ParticleType.explosion,
        gravity: 200,
        rotationSpeed: _random.nextDouble() * 10 - 5,
      );

      _particles.add(particle);
    }
  }

  // MÉTODO PÚBLICO: Chuva de confetti
  void confetti({
    required Offset position,
    int count = 25,
    double spread = 100,
  }) {
    final colors = [
      Colors.red, Colors.blue, Colors.green, Colors.yellow,
      Colors.purple, Colors.orange, Colors.pink, Colors.cyan
    ];

    for (int i = 0; i < count; i++) {
      final velocity = Offset(
        (_random.nextDouble() - 0.5) * spread,
        -50 - _random.nextDouble() * 100,
      );

      final particle = Particle(
        position: position + Offset(
          (_random.nextDouble() - 0.5) * 50,
          (_random.nextDouble() - 0.5) * 20,
        ),
        velocity: velocity,
        life: 2.0 + _random.nextDouble() * 1.0,
        color: colors[_random.nextInt(colors.length)],
        size: 4 + _random.nextDouble() * 6,
        type: ParticleType.confetti,
        gravity: 150,
        rotationSpeed: _random.nextDouble() * 20 - 10,
      );

      _particles.add(particle);
    }
  }

  // MÉTODO PÚBLICO: Sparkles (estrelinhas)
  void sparkle({
    required Offset position,
    Color? color,
    int count = 8,
  }) {
    final baseColor = color ?? Colors.white;

    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = 20 + _random.nextDouble() * 40;
      final velocity = Offset(
        math.cos(angle) * speed,
        math.sin(angle) * speed,
      );

      final particle = Particle(
        position: position,
        velocity: velocity,
        life: 0.8 + _random.nextDouble() * 0.4,
        color: _randomizeColor(baseColor),
        size: 2 + _random.nextDouble() * 3,
        type: ParticleType.sparkle,
        rotationSpeed: _random.nextDouble() * 15,
      );

      _particles.add(particle);
    }
  }

  // MÉTODO PÚBLICO: Trail de estrelas
  void starTrail({
    required Offset start,
    required Offset end,
    Color? color,
    int count = 10,
  }) {
    final baseColor = color ?? Colors.yellow;
    final direction = end - start;
    
    for (int i = 0; i < count; i++) {
      final t = i / count;
      final position = start + direction * t;
      
      final velocity = Offset(
        (_random.nextDouble() - 0.5) * 50,
        (_random.nextDouble() - 0.5) * 50,
      );

      final particle = Particle(
        position: position,
        velocity: velocity,
        life: 0.5 + _random.nextDouble() * 0.5,
        color: _randomizeColor(baseColor),
        size: 2 + _random.nextDouble() * 2,
        type: ParticleType.star,
        rotationSpeed: _random.nextDouble() * 10,
      );

      _particles.add(particle);
    }
  }

  Color _randomizeColor(Color baseColor) {
    final hsv = HSVColor.fromColor(baseColor);
    return hsv.withSaturation(
      (hsv.saturation + (_random.nextDouble() - 0.5) * 0.3).clamp(0.0, 1.0)
    ).withValue(
      (hsv.value + (_random.nextDouble() - 0.5) * 0.2).clamp(0.0, 1.0)
    ).toColor();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.enabled)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ParticlePainter(_particles),
              ),
            ),
          ),
      ],
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);

      switch (particle.type) {
        case ParticleType.explosion:
          canvas.drawCircle(Offset.zero, particle.size, paint);
          break;
          
        case ParticleType.confetti:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: particle.size,
                height: particle.size * 1.5,
              ),
              Radius.circular(particle.size * 0.2),
            ),
            paint,
          );
          break;
          
        case ParticleType.sparkle:
          _drawStar(canvas, paint, particle.size);
          break;
          
        case ParticleType.star:
          _drawStar(canvas, paint, particle.size);
          break;
          
        case ParticleType.trail:
          canvas.drawCircle(Offset.zero, particle.size, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    const points = 5;
    const outerRadius = 1.0;
    const innerRadius = 0.4;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points;
      final radius = (i % 2 == 0) ? outerRadius : innerRadius;
      final x = math.cos(angle) * radius * size;
      final y = math.sin(angle) * radius * size;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return particles != oldDelegate.particles;
  }
} 