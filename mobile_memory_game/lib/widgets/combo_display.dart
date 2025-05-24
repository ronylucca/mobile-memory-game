import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/theme_model.dart';

class ComboDisplay extends StatefulWidget {
  final int comboCount;
  final int maxCombo;
  final ThemeModel theme;
  final bool isCompact;

  const ComboDisplay({
    super.key,
    required this.comboCount,
    required this.maxCombo,
    required this.theme,
    this.isCompact = false,
  });

  @override
  State<ComboDisplay> createState() => _ComboDisplayState();
}

class _ComboDisplayState extends State<ComboDisplay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  
  int _previousCombo = 0;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: widget.theme.primaryColor,
      end: widget.theme.secondaryColor,
    ).animate(_pulseController);
    
    _previousCombo = widget.comboCount;
    
    if (widget.comboCount >= 2) {
      _scaleController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ComboDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animar quando combo aumenta
    if (widget.comboCount > _previousCombo && widget.comboCount >= 2) {
      _pulseController.forward().then((_) => _pulseController.reverse());
      
      if (!_scaleController.isAnimating) {
        _scaleController.repeat(reverse: true);
      }
    }
    
    // Parar animação quando combo reseta
    if (widget.comboCount == 0 && _previousCombo > 0) {
      _scaleController.stop();
      _scaleController.reset();
    }
    
    _previousCombo = widget.comboCount;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comboCount < 2) {
      return const SizedBox.shrink(); // Não mostra combo menor que 2
    }
    
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCompact ? 12 : 16,
              vertical: widget.isCompact ? 6 : 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getComboColor().withOpacity(0.9),
                  _getComboColor().withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _getComboColor().withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Icon(
                    _getComboIcon(),
                    color: Colors.white,
                    size: widget.isCompact ? 16 : 20,
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getComboText(),
                      style: TextStyle(
                        fontSize: widget.isCompact ? 11 : 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'x${widget.comboCount}',
                      style: TextStyle(
                        fontSize: widget.isCompact ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Color _getComboColor() {
    if (widget.comboCount >= 5) {
      return Colors.purple; // Combo épico
    } else if (widget.comboCount >= 3) {
      return Colors.orange; // Combo alto
    } else {
      return widget.theme.primaryColor; // Combo normal
    }
  }
  
  IconData _getComboIcon() {
    if (widget.comboCount >= 5) {
      return Icons.local_fire_department; // Fogo para combo épico
    } else if (widget.comboCount >= 3) {
      return Icons.bolt; // Raio para combo alto
    } else {
      return Icons.trending_up; // Seta para combo normal
    }
  }
  
  String _getComboText() {
    if (widget.comboCount >= 5) {
      return 'ÉPICO!';
    } else if (widget.comboCount >= 3) {
      return 'COMBO!';
    } else {
      return 'Acertos';
    }
  }
} 