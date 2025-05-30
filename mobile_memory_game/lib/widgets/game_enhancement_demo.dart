import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/achievement_model.dart';
import 'package:mobile_memory_game/models/player_model.dart';
import 'package:mobile_memory_game/widgets/achievement_popup.dart';
import 'package:mobile_memory_game/widgets/power_up_effects.dart';
import 'package:mobile_memory_game/widgets/powerup_panel.dart';
import 'package:mobile_memory_game/widgets/floating_powerups_display.dart';

// Widget de demonstração das funcionalidades do novo sistema de powerups
class GameEnhancementDemo extends StatefulWidget {
  const GameEnhancementDemo({super.key});

  @override
  State<GameEnhancementDemo> createState() => _GameEnhancementDemoState();
}

class _GameEnhancementDemoState extends State<GameEnhancementDemo> {
  // Simulação de dois jogadores para demonstrar o sistema completo
  late PlayerModel _player1;
  late PlayerModel _player2;
  int _currentPlayerIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _initializePlayers();
  }
  
  void _initializePlayers() {
    _player1 = PlayerModel(
      id: 1,
      name: 'Jogador 1',
      score: 15, // Pontos suficientes para testar powerups
      isCurrentTurn: true,
    );
    
    _player2 = PlayerModel(
      id: 2,
      name: 'Jogador 2',
      score: 10,
      isCurrentTurn: false,
    );
  }
  
  PlayerModel get _currentPlayer => _currentPlayerIndex == 0 ? _player1 : _player2;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo: Sistema de Powerups'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _resetDemo,
            icon: const Icon(Icons.refresh),
            tooltip: 'Resetar Demo',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Controles da demo
            _buildDemoControls(),
            
            const SizedBox(height: 20),
            
            // Painéis de powerups dos jogadores
            _buildPlayerPowerupsSection(),
            
            const SizedBox(height: 20),
            
            // Sistema flutuante de powerups
            _buildFloatingPowerupsDemo(),
            
            const SizedBox(height: 20),
            
            // Informações dos powerups
            _buildPowerupsInfo(),
            
            const SizedBox(height: 20),
            
            // Botões de demonstração
            _buildDemoButtons(),
            
            const SizedBox(height: 20),
            
            // Comparação dos sistemas
            _buildSystemComparisonDemo(),
            
            const SizedBox(height: 20),
            
            // Conquistas
            _buildAchievementsPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoControls() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎮 Controles da Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _switchPlayer,
                    icon: const Icon(Icons.swap_horiz),
                    label: Text('Trocar para ${_currentPlayerIndex == 0 ? "Jogador 2" : "Jogador 1"}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentPlayerIndex == 0 ? Colors.blue : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addPoints,
                  icon: const Icon(Icons.add),
                  label: const Text('+ Pontos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Jogador Atual: ${_currentPlayer.name} (${_currentPlayer.score} pontos)',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerPowerupsSection() {
    return Column(
      children: [
        // Player 1
        PowerupPanel(
          player: _player1,
          isCurrentPlayer: _currentPlayerIndex == 0,
          onPowerupPressed: _activatePowerup,
        ),
        
        const SizedBox(height: 12),
        
        // Player 2
        PowerupPanel(
          player: _player2,
          isCurrentPlayer: _currentPlayerIndex == 1,
          onPowerupPressed: _activatePowerup,
        ),
      ],
    );
  }

  Widget _buildFloatingPowerupsDemo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✨ Sistema Flutuante de Powerups',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Este sistema substitui os painéis fixos, economizando espaço para as cartas:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // Demonstração do sistema flutuante
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.withOpacity(0.1), Colors.blue.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Stack(
                children: [
                  // Simulação do tabuleiro
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '🎮 Área do Jogo\n(Cartas maiores)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  
                  // Player 1 flutuante (esquerda)
                  Positioned(
                    left: 12,
                    top: 60,
                    child: FloatingPowerupsDisplay(
                      player: _player1,
                      isCurrentPlayer: _currentPlayerIndex == 0,
                      onPowerupPressed: _activatePowerup,
                      isExpanded: false,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  
                  // Player 2 flutuante (direita)
                  Positioned(
                    right: 12,
                    top: 60,
                    child: FloatingPowerupsDisplay(
                      player: _player2,
                      isCurrentPlayer: _currentPlayerIndex == 1,
                      onPowerupPressed: _activatePowerup,
                      isExpanded: false,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 Vantagens do Sistema Flutuante:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  Text('• Cartas 30% maiores - melhor visibilidade'),
                  Text('• Interface limpa - foco no jogo'),
                  Text('• Acesso rápido - um toque para expandir'),
                  Text('• Animações suaves - feedback visual'),
                  Text('• Estado em tempo real - powerups ativos visíveis'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerupsInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Powerups Disponíveis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...PowerUp.availablePowerUps.map((powerup) => 
              _buildPowerupDescription(powerup)
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Dicas:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('• Powerups ativos aparecem com borda verde'),
                  Text('• Alguns powerups são permanentes até serem usados'),
                  Text('• Custos são balanceados por impacto no jogo'),
                  Text('• Apenas o jogador atual pode ativar powerups'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerupDescription(PowerUp powerup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Text(
            powerup.icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${powerup.name} (${powerup.cost} pts)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  powerup.description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButtons() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎮 Demonstrações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _showXRayEffect,
                  icon: const Text('👁️'),
                  label: const Text('Efeito Raio-X'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showFreezeEffect,
                  icon: const Text('❄️'),
                  label: const Text('Efeito Congelar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showLightningEffect,
                  icon: const Text('⚡'),
                  label: const Text('Efeito Raio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showDoublePointsEffect,
                  icon: const Text('⭐'),
                  label: const Text('Pontos Duplos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addPointsToCurrentPlayer,
                  icon: const Text('💰'),
                  label: const Text('Dar Pontos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _simulatePowerupExpiration,
                  icon: const Text('⏰'),
                  label: const Text('Simular Expiração'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemComparisonDemo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚖️ Comparação: Antes vs Depois',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                // Sistema Antigo
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              '❌ Sistema Antigo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '• Painéis fixos\n• Ocupa 25% da tela\n• Cartas menores\n• Interface poluída',
                              style: TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Simulação do sistema antigo
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            '📱 Espaço limitado\nCartas pequenas',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Sistema Novo
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              '✅ Sistema Novo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '• Powerups flutuantes\n• 0% espaço fixo\n• Cartas 30% maiores\n• Interface limpa',
                              style: TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Simulação do sistema novo
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.withOpacity(0.2), Colors.blue.withOpacity(0.2)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Text(
                                '🎮 Espaço otimizado\nCartas grandes',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Positioned(
                              left: 4,
                              top: 4,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.bolt, color: Colors.white, size: 12),
                              ),
                            ),
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.bolt, color: Colors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 Resultados da Otimização:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('✨ +30% tamanho das cartas'),
                  Text('🎯 -100% espaço fixo dos painéis'),
                  Text('⚡ +200% velocidade de acesso'),
                  Text('🎨 Interface mais limpa e focada'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsPreview() {
    final achievements = AchievementManager.defaultAchievements.take(3);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏆 Conquistas Recentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...achievements.map((achievement) => _buildAchievementPreview(achievement)),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementPreview(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
        border: Border(
          left: BorderSide(
            width: 4,
            color: _getAchievementColor(achievement.rarity),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(achievement.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _getAchievementColor(achievement.rarity),
            ),
            child: Text(
              '+${achievement.rewardXP} XP',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAchievementColor(AchievementRarity rarity) {
    switch (rarity) {
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

  // Métodos para demonstrar efeitos visuais
  void _showXRayEffect() {
    _showPowerUpEffect(PowerUpType.xray);
  }

  void _showFreezeEffect() {
    _showPowerUpEffect(PowerUpType.freeze);
  }

  void _showLightningEffect() {
    _showPowerUpEffect(PowerUpType.lightning);
  }

  void _showDoublePointsEffect() {
    _showPowerUpEffect(PowerUpType.doublePoints);
  }

  void _showPowerUpEffect(PowerUpType type) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => PowerUpEffectOverlay(
        type: type,
        onComplete: () => overlayEntry.remove(),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    final powerup = PowerUp.getPowerUp(type);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demonstrando efeito: ${powerup.name}'),
        backgroundColor: Colors.purple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _activatePowerup(PowerUpType powerupType) {
    final powerup = PowerUp.getPowerUp(powerupType);
    
    if (!_currentPlayer.canAfford(powerupType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Pontos insuficientes para este powerup!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_currentPlayer.hasPowerup(powerupType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Este powerup já está ativo!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Simula ativação do powerup
    setState(() {
      // Desconta pontos
      if (_currentPlayerIndex == 0) {
        _player1 = _player1.copyWith(score: _player1.score - powerup.cost);
        
        // Adiciona powerup ativo
        final activePowerup = ActivePowerUp(
          type: powerupType,
          activatedAt: DateTime.now(),
          duration: powerup.duration,
          isPermanent: powerup.isPermanent,
        );
        
        _player1 = _player1.copyWith(
          activePowerups: [..._player1.activePowerups, activePowerup],
        );
      } else {
        _player2 = _player2.copyWith(score: _player2.score - powerup.cost);
        
        // Adiciona powerup ativo
        final activePowerup = ActivePowerUp(
          type: powerupType,
          activatedAt: DateTime.now(),
          duration: powerup.duration,
          isPermanent: powerup.isPermanent,
        );
        
        _player2 = _player2.copyWith(
          activePowerups: [..._player2.activePowerups, activePowerup],
        );
      }
    });

    // Mostra efeito visual
    _showPowerUpEffect(powerupType);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${powerup.name} ativado! Custou ${powerup.cost} pontos.'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // Simula expiração automática para powerups não permanentes
    if (!powerup.isPermanent) {
      Future.delayed(powerup.duration, () {
        if (mounted) {
          _removePowerup(powerupType);
        }
      });
    }
  }

  void _removePowerup(PowerUpType type) {
    setState(() {
      if (_currentPlayerIndex == 0) {
        _player1 = _player1.copyWith(
          activePowerups: _player1.activePowerups
              .where((p) => p.type != type)
              .toList(),
        );
      } else {
        _player2 = _player2.copyWith(
          activePowerups: _player2.activePowerups
              .where((p) => p.type != type)
              .toList(),
        );
      }
    });
  }

  void _switchPlayer() {
    setState(() {
      _currentPlayerIndex = 1 - _currentPlayerIndex;
      _player1 = _player1.copyWith(isCurrentTurn: _currentPlayerIndex == 0);
      _player2 = _player2.copyWith(isCurrentTurn: _currentPlayerIndex == 1);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔄 Trocou para ${_currentPlayer.name}'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _addPointsToCurrentPlayer() {
    setState(() {
      if (_currentPlayerIndex == 0) {
        _player1 = _player1.copyWith(score: _player1.score + 10);
      } else {
        _player2 = _player2.copyWith(score: _player2.score + 10);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('💰 +10 pontos para ${_currentPlayer.name}!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _addPoints() {
    _addPointsToCurrentPlayer();
  }

  void _simulatePowerupExpiration() {
    if (_currentPlayer.activePowerups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Nenhum powerup ativo para expirar'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final firstPowerup = _currentPlayer.activePowerups.first;
    _removePowerup(firstPowerup.type);
    
    final powerup = PowerUp.getPowerUp(firstPowerup.type);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⏰ ${powerup.name} expirou!'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetDemo() {
    setState(() {
      _initializePlayers();
      _currentPlayerIndex = 0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 Demo resetado! Todos os powerups removidos.'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Como integrar no menu principal do jogo
class EnhancedMainMenu extends StatelessWidget {
  const EnhancedMainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple, Colors.blue],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Memory Game Enhanced',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Botões do menu principal
                _buildMenuButton(
                  context,
                  'Jogar',
                  Icons.play_arrow,
                  Colors.green,
                  () => Navigator.pushNamed(context, '/game'),
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  'Conquistas',
                  Icons.emoji_events,
                  Colors.orange,
                  () => _showAchievements(context),
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  'Power-ups',
                  Icons.bolt,
                  Colors.yellow,
                  () => _showPowerUpShop(context),
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  'Estatísticas',
                  Icons.bar_chart,
                  Colors.blue,
                  () => _showStats(context),
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  'Demo Funcionalidades',
                  Icons.science,
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameEnhancementDemo(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 8,
        ),
      ),
    );
  }

  void _showAchievements(BuildContext context) {
    // TODO: Implementar tela de conquistas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tela de conquistas em desenvolvimento!')),
    );
  }

  void _showPowerUpShop(BuildContext context) {
    // TODO: Implementar loja de power-ups
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loja de power-ups em desenvolvimento!')),
    );
  }

  void _showStats(BuildContext context) {
    // TODO: Implementar dashboard de estatísticas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dashboard de estatísticas em desenvolvimento!')),
    );
  }
} 