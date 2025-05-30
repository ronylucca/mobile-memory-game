import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/player_model.dart';
import 'package:mobile_memory_game/widgets/power_up_effects.dart';

/// Widget flutuante para exibir powerups ativos e disponíveis de forma compacta
class FloatingPowerupsDisplay extends StatefulWidget {
  final PlayerModel player;
  final bool isCurrentPlayer;
  final Function(PowerUpType) onPowerupPressed;
  final VoidCallback? onToggleExpanded;
  final bool isExpanded;
  final Alignment alignment;

  const FloatingPowerupsDisplay({
    super.key,
    required this.player,
    required this.isCurrentPlayer,
    required this.onPowerupPressed,
    this.onToggleExpanded,
    this.isExpanded = false,
    this.alignment = Alignment.centerRight,
  });

  @override
  State<FloatingPowerupsDisplay> createState() => _FloatingPowerupsDisplayState();
}

class _FloatingPowerupsDisplayState extends State<FloatingPowerupsDisplay>
    with TickerProviderStateMixin {
  late AnimationController _expansionController;
  late AnimationController _pulseController;
  late Animation<double> _expansionAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _expansionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _expansionAnimation = CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeOutBack,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Pulsa se for jogador atual
    if (widget.isCurrentPlayer) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FloatingPowerupsDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Controla expansão
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expansionController.forward();
      } else {
        _expansionController.reverse();
      }
    }
    
    // Controla pulso baseado no jogador atual
    if (widget.isCurrentPlayer != oldWidget.isCurrentPlayer) {
      if (widget.isCurrentPlayer) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _expansionController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_expansionAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isCurrentPlayer ? _pulseAnimation.value : 1.0,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: widget.isExpanded ? 280 : 80,
              maxHeight: widget.isExpanded ? 200 : 80,
            ),
            child: widget.isExpanded ? _buildExpandedView() : _buildCompactView(),
          ),
        );
      },
    );
  }

  Widget _buildCompactView() {
    final activePowerups = widget.player.activePowerups
        .where((p) => !p.isExpired)
        .take(3)
        .toList();

    return GestureDetector(
      onTap: widget.onToggleExpanded,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: widget.isCurrentPlayer
              ? LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.8),
                    Colors.purple.withOpacity(0.8),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.grey.withOpacity(0.6),
                    Colors.grey.withOpacity(0.4),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Ícone principal
            Center(
              child: Icon(
                Icons.bolt,
                color: Colors.white,
                size: 32,
              ),
            ),
            
            // Badge com quantidade de powerups ativos
            if (activePowerups.isNotEmpty)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${activePowerups.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            
            // Indicador de pontos
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.player.score}pts',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: widget.isCurrentPlayer
                  ? LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade400, Colors.grey.shade600],
                    ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(
                  widget.player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.player.score} pts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onToggleExpanded,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          
          // Powerups ativos
          if (widget.player.activePowerups.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ativos:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: widget.player.activePowerups
                        .where((p) => !p.isExpired)
                        .map((activePowerup) => _buildActivePowerupChip(activePowerup))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
          
          // Powerups disponíveis (apenas para jogador atual)
          if (widget.isCurrentPlayer) ...[
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Disponíveis:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: PowerUp.availablePowerUps
                        .where((powerup) => 
                            widget.player.canAfford(powerup.type) &&
                            !widget.player.hasPowerup(powerup.type))
                        .map((powerup) => _buildAvailablePowerupChip(powerup))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivePowerupChip(ActivePowerUp activePowerup) {
    final powerup = PowerUp.getPowerUp(activePowerup.type);
    final remainingTime = activePowerup.isPermanent 
        ? null 
        : activePowerup.remainingTime;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            powerup.icon,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 2),
          Text(
            powerup.name,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          if (remainingTime != null) ...[
            const SizedBox(width: 2),
            Text(
              '${remainingTime}s',
              style: const TextStyle(
                fontSize: 9,
                color: Colors.green,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailablePowerupChip(PowerUp powerup) {
    return GestureDetector(
      onTap: () => widget.onPowerupPressed(powerup.type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              powerup.icon,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 2),
            Text(
              '${powerup.cost}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 