import 'package:flutter/material.dart';

class AnimatedTimer extends StatefulWidget {
  final String timeText;
  final bool isWarning; // últimos 30 segundos
  final bool isCritical; // últimos 10 segundos
  final bool isPaused;
  final VoidCallback? onTap;
  final Color primaryColor;
  final Color secondaryColor;

  const AnimatedTimer({
    super.key,
    required this.timeText,
    this.isWarning = false,
    this.isCritical = false,
    this.isPaused = false,
    this.onTap,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<AnimatedTimer> createState() => _AnimatedTimerState();
}

class _AnimatedTimerState extends State<AnimatedTimer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  String _previousTime = '';

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
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
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
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _previousTime = widget.timeText;
    _slideController.forward();
    
    if (widget.isCritical) {
      _pulseController.repeat(reverse: true);
    }
    
    if (widget.isWarning || widget.isCritical) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Anima quando o tempo muda
    if (widget.timeText != _previousTime) {
      _previousTime = widget.timeText;
      _triggerChangeAnimation();
    }
    
    // Controla as animações baseado no estado
    if (widget.isCritical && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isCritical && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
    
    if ((widget.isWarning || widget.isCritical) && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isWarning && !widget.isCritical && _glowController.isAnimating) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  void _triggerChangeAnimation() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    _slideController.reset();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Color get _timerColor {
    if (widget.isCritical) return Colors.red.shade600;
    if (widget.isWarning) return Colors.orange.shade600;
    return widget.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _glowAnimation,
          _slideAnimation,
          _scaleAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isCritical 
                ? _pulseAnimation.value * _scaleAnimation.value
                : _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isPaused 
                                ? Icons.pause_circle_filled
                                : widget.isCritical 
                                    ? Icons.warning
                                    : Icons.timer,
                            color: _timerColor,
                            size: 20,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.timeText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _timerColor,
                              fontFamily: 'monospace',
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Widget simples para modo zen (sem timer)
class ZenModeIndicator extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;

  const ZenModeIndicator({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.self_improvement,
          color: primaryColor,
          size: 20,
        ),
        const SizedBox(height: 6),
        Text(
          'ZEN',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryColor,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
} 