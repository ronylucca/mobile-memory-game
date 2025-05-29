import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/achievement_model.dart';
import 'package:mobile_memory_game/widgets/achievement_popup.dart';
import 'package:mobile_memory_game/widgets/power_up_effects.dart';

// Widget de demonstração das funcionalidades
class GameEnhancementDemo extends StatefulWidget {
  const GameEnhancementDemo({super.key});

  @override
  State<GameEnhancementDemo> createState() => _GameEnhancementDemoState();
}

class _GameEnhancementDemoState extends State<GameEnhancementDemo> {
  int _playerCoins = 500;
  List<PowerUp> _availablePowerUps = PowerUp.availablePowerUps;
  PowerUpType? _activePowerUp;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo: Melhorias do Jogo'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status do jogador
            _buildPlayerStatus(),
            
            const SizedBox(height: 20),
            
            // Power-ups
            _buildPowerUpsSection(),
            
            const SizedBox(height: 20),
            
            // Botões de demo
            _buildDemoButtons(),
            
            const SizedBox(height: 20),
            
            // Conquistas
            _buildAchievementsPreview(),
            
            const SizedBox(height: 20),
            
            // Ideias futuras
            _buildFutureIdeas(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStatus() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👤 Status do Jogador',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💰 Moedas: $_playerCoins'),
                    const Text('⭐ XP: 1,250'),
                    const Text('🏆 Nível: 5 (Experiente)'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('🔥 Streak: 12'),
                    const Text('🎯 Precisão: 89%'),
                    const Text('⚡ Melhor Combo: 8x'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerUpsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Power-ups Disponíveis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _availablePowerUps.map((powerUp) {
                final canAfford = _playerCoins >= powerUp.cost;
                final isActive = _activePowerUp == powerUp.type;
                
                return PowerUpButton(
                  powerUp: powerUp,
                  isAvailable: canAfford,
                  isActive: isActive,
                  onPressed: () => _usePowerUp(powerUp),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              'Toque em um power-up para ativá-lo!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
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
                  onPressed: _showComboAchievement,
                  icon: const Text('🔥'),
                  label: const Text('Conquista de Combo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showSpeedAchievement,
                  icon: const Text('💨'),
                  label: const Text('Conquista de Velocidade'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showLegendaryAchievement,
                  icon: const Text('👑'),
                  label: const Text('Conquista Lendária'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addCoins,
                  icon: const Text('💰'),
                  label: const Text('Adicionar Moedas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
        border: Border.left(
          width: 4,
          color: _getAchievementColor(achievement.rarity),
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

  Widget _buildFutureIdeas() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 Próximas Funcionalidades',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildIdeaItem('🎵', 'Música Dinâmica', 'Trilha que se adapta ao seu desempenho'),
            _buildIdeaItem('👥', 'Multiplayer Online', 'Desafie jogadores do mundo todo'),
            _buildIdeaItem('📈', 'Dashboard Avançado', 'Estatísticas detalhadas de progresso'),
            _buildIdeaItem('🎨', 'Editor de Temas', 'Crie seus próprios temas personalizados'),
            _buildIdeaItem('🏃', 'Modo Survival', 'Veja quantas rodadas consegue passar'),
            _buildIdeaItem('🎪', 'Eventos Especiais', 'Torneios e desafios sazonais'),
          ],
        ),
      ),
    );
  }

  Widget _buildIdeaItem(String icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
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

  void _usePowerUp(PowerUp powerUp) {
    if (_playerCoins >= powerUp.cost) {
      setState(() {
        _playerCoins -= powerUp.cost;
        _activePowerUp = powerUp.type;
      });
      
      // Mostrar overlay de efeito
      _showPowerUpEffect(powerUp.type);
      
      // Desativar após a duração
      Future.delayed(powerUp.duration, () {
        if (mounted) {
          setState(() {
            _activePowerUp = null;
          });
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${powerUp.name} ativado!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Moedas insuficientes!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
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
  }

  void _showComboAchievement() {
    final achievement = AchievementManager.defaultAchievements
        .where((a) => a.type == AchievementType.combo)
        .first;
    
    AchievementNotifier.show(context, achievement);
  }

  void _showSpeedAchievement() {
    final achievement = AchievementManager.defaultAchievements
        .where((a) => a.type == AchievementType.speed)
        .first;
    
    AchievementNotifier.show(context, achievement);
  }

  void _showLegendaryAchievement() {
    final achievement = AchievementManager.defaultAchievements
        .where((a) => a.rarity == AchievementRarity.legendary)
        .first;
    
    AchievementNotifier.show(context, achievement);
  }

  void _addCoins() {
    setState(() {
      _playerCoins += 200;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💰 +200 moedas adicionadas!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
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