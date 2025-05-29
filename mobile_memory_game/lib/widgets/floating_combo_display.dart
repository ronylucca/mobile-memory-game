import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/widgets/particle_system.dart';

class FloatingComboDisplay extends StatefulWidget {
  final int comboCount;
  final int maxCombo;
  final ThemeModel theme;
  final int currentPlayerIndex;
  final bool isVisible;

  const FloatingComboDisplay({
    super.key,
    required this.comboCount,
    required this.maxCombo,
    required this.theme,
    required this.currentPlayerIndex,
    this.isVisible = true,
  });

  @override
  State<FloatingComboDisplay> createState() => _FloatingComboDisplayState();
}

class _FloatingComboDisplayState extends State<FloatingComboDisplay>
    with TickerProviderStateMixin {
  late AnimationController _appearController;
  late AnimationController _pulseController;
  late AnimationController _rainbowController;
  late AnimationController _bounceController;
  
  late Animation<double> _appearAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rainbowAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _previousCombo = 0;

  @override
  void initState() {
    super.initState();
    
    _appearController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _rainbowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _appearAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _appearController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rainbowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rainbowController);
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _appearController,
      curve: Curves.elasticOut,
    ));
    
    _previousCombo = widget.comboCount;
    
    if (widget.comboCount >= 2 && widget.isVisible) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _appearController.forward();
    _pulseController.repeat(reverse: true);
    
    if (widget.comboCount >= 2) {
      _rainbowController.repeat();
    }
    
    if (widget.comboCount >= 4) {
      _bounceController.repeat(reverse: true);
    }
  }

  void _stopAnimations() {
    _appearController.reverse();
    _pulseController.stop();
    _rainbowController.stop();
    _bounceController.stop();
  }

  @override
  void didUpdateWidget(FloatingComboDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animar quando combo aumenta
    if (widget.comboCount > _previousCombo && widget.comboCount >= 2) {
      _startAnimations();
      
      // Trigger confetti para combos altos
      if (widget.comboCount >= 3) {
        _triggerConfetti();
      }
    }
    
    // Parar animação quando combo reseta ou fica invisível
    if ((widget.comboCount == 0 && _previousCombo > 0) || !widget.isVisible) {
      _stopAnimations();
    }
    
    // Iniciar animações se combo >= 2 e ficou visível
    if (widget.comboCount >= 2 && widget.isVisible && !oldWidget.isVisible) {
      _startAnimations();
    }
    
    _previousCombo = widget.comboCount;
  }

  void _triggerConfetti() {
    Future.delayed(const Duration(milliseconds: 200), () {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final comboCenter = position + Offset(
          renderBox.size.width / 2,
          renderBox.size.height / 2,
        );
        
        final particleSystem = ParticleSystem.of(context);
        if (particleSystem != null) {
          final intensity = widget.comboCount >= 5 ? 2.5 : 1.8;
          final count = widget.comboCount >= 5 ? 35 : 25;
          
          particleSystem.confetti(
            position: comboCenter,
            count: count,
            spread: 120 * intensity,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _appearController.dispose();
    _pulseController.dispose();
    _rainbowController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comboCount < 2 || !widget.isVisible) {
      return const SizedBox.shrink();
    }
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _appearAnimation,
        _pulseAnimation,
        if (widget.comboCount >= 2) _rainbowAnimation,
      ]),
      builder: (context, child) {
        // Validar valores das animações para evitar erros
        final appearValue = _appearAnimation.value.clamp(0.0, 1.0);
        final pulseValue = _pulseAnimation.value.clamp(0.5, 2.0);
        final scaleValue = (1.0 + (pulseValue - 1.0) * appearValue).clamp(0.1, 3.0);
        
        return Opacity(
          opacity: appearValue,
          child: SlideTransition(
            position: _slideAnimation,
            child: Transform.scale(
              scale: scaleValue,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getGradientColors(),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getComboColor().withOpacity(0.6.clamp(0.0, 1.0)),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3.clamp(0.0, 1.0)),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4.clamp(0.0, 1.0)),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2.clamp(0.0, 1.0)),
                      ),
                      child: Icon(
                        _getComboIcon(),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getComboText(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${widget.comboCount}x',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.whatshot,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  List<Color> _getGradientColors() {
    if (widget.comboCount >= 2) {
      // Efeito rainbow controlado para todos os combos 2x+
      try {
        final rainbowValue = _rainbowAnimation.value.clamp(0.0, 1.0);
        final hue = (rainbowValue * 360) % 360;
        
        // Validar valores HSV
        if (hue.isNaN || hue.isInfinite) {
          return _getFallbackColors();
        }
        
        final color1 = HSVColor.fromAHSV(1.0, hue.clamp(0.0, 360.0), 0.8, 0.9).toColor();
        final color2 = HSVColor.fromAHSV(1.0, (hue + 60).clamp(0.0, 360.0) % 360, 0.8, 0.9).toColor();
        return [color1, color2];
      } catch (e) {
        // Fallback para cores baseadas no nível do combo
        return _getFallbackColors();
      }
    } else {
      // Gradiente do tema para combos menores que 2x (não deveria acontecer)
      return [
        widget.theme.primaryColor,
        widget.theme.secondaryColor,
      ];
    }
  }
  
  List<Color> _getFallbackColors() {
    if (widget.comboCount >= 5) {
      return [Colors.purple.shade600, Colors.pink.shade500];
    } else if (widget.comboCount >= 3) {
      return [Colors.orange.shade600, Colors.red.shade500];
    } else {
      return [widget.theme.primaryColor, widget.theme.secondaryColor];
    }
  }
  
  Color _getComboColor() {
    if (widget.comboCount >= 5) {
      return Colors.purple;
    } else if (widget.comboCount >= 3) {
      return Colors.orange;
    } else {
      return widget.theme.primaryColor;
    }
  }
  
  IconData _getComboIcon() {
    if (widget.comboCount >= 5) {
      return Icons.auto_awesome;
    } else if (widget.comboCount >= 3) {
      return Icons.bolt;
    } else {
      return Icons.trending_up;
    }
  }
  
  String _getComboText() {
    if (widget.comboCount >= 5) {
      return 'ÉPICO!';
    } else if (widget.comboCount >= 3) {
      return 'COMBO!';
    } else {
      return 'SEQUÊNCIA';
    }
  }
} 