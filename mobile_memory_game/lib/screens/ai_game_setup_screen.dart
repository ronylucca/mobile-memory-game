import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/screens/ai_game_screen.dart';

enum AIDifficulty {
  easy,
  moderate,
  hard,
}

class AIGameSetupScreen extends StatefulWidget {
  const AIGameSetupScreen({super.key});

  @override
  State<AIGameSetupScreen> createState() => _AIGameSetupScreenState();
}

class _AIGameSetupScreenState extends State<AIGameSetupScreen> {
  AIDifficulty selectedDifficulty = AIDifficulty.moderate;
  ThemeModel? selectedTheme;
  String playerName = 'Você';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Jogar vs IA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Para balancear o back button
                  ],
                ),
                
                const SizedBox(height: 30),

                // Campo nome do jogador
                _buildPlayerNameSection(),
                
                const SizedBox(height: 30),
                
                // Seleção de dificuldade
                _buildDifficultySelection(),
                
                const SizedBox(height: 30),
                
                // Seleção de tema
                _buildThemeSelection(),
                
                const SizedBox(height: 40),
                
                // Botão iniciar jogo
                _buildStartGameButton(),
                
                const Spacer(),
                
                // Informações da IA
                _buildAIInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerNameSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👤 Seu Nome',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Digite seu nome',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  playerName = value.isNotEmpty ? value : 'Você';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySelection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🤖 Dificuldade da IA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...AIDifficulty.values.map((difficulty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildDifficultyOption(difficulty),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyOption(AIDifficulty difficulty) {
    final isSelected = selectedDifficulty == difficulty;
    final difficultyInfo = _getDifficultyInfo(difficulty);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDifficulty = difficulty;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? difficultyInfo['color'] : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          color: isSelected 
              ? difficultyInfo['color'].withOpacity(0.1) 
              : Colors.white,
        ),
        child: Row(
          children: [
            Text(
              difficultyInfo['icon'],
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficultyInfo['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? difficultyInfo['color'] : Colors.black87,
                    ),
                  ),
                  Text(
                    difficultyInfo['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: difficultyInfo['color'],
              ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getDifficultyInfo(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return {
          'name': 'Fácil',
          'description': 'IA comete erros frequentes, bom para iniciantes',
          'icon': '😊',
          'color': Colors.green,
        };
      case AIDifficulty.moderate:
        return {
          'name': 'Moderado',
          'description': 'IA equilibrada, comete alguns erros ocasionais',
          'icon': '🤔',
          'color': Colors.orange,
        };
      case AIDifficulty.hard:
        return {
          'name': 'Difícil',
          'description': 'IA muito inteligente, raramente comete erros',
          'icon': '🧠',
          'color': Colors.red,
        };
    }
  }

  Widget _buildThemeSelection() {
    final themes = ThemeModel.getAllThemes();
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎨 Escolha um Tema',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final theme = themes[index];
                  final isSelected = selectedTheme?.id == theme.id;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTheme = theme;
                        });
                      },
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? theme.primaryColor : Colors.grey[300]!,
                            width: isSelected ? 3 : 1,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.primaryColor.withOpacity(isSelected ? 1.0 : 0.7),
                              theme.secondaryColor.withOpacity(isSelected ? 1.0 : 0.7),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 20,
                              ),
                            const SizedBox(height: 4),
                            Text(
                              theme.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartGameButton() {
    final canStartGame = selectedTheme != null;
    
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: canStartGame ? _startAIGame : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canStartGame ? Colors.white : Colors.grey[300],
          foregroundColor: canStartGame ? Colors.green[700] : Colors.grey[600],
          elevation: canStartGame ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              canStartGame ? Icons.play_arrow : Icons.block,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              canStartGame ? 'Iniciar Batalha vs IA!' : 'Selecione um tema',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.1),
      ),
      child: Column(
        children: [
          const Text(
            '🤖 Sobre a IA',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A IA adapta sua estratégia baseada na dificuldade escolhida. '
            'Ela observa suas jogadas e tenta formar combos!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _startAIGame() {
    if (selectedTheme != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AIGameScreen(
            theme: selectedTheme!,
            playerName: playerName,
            aiDifficulty: selectedDifficulty,
          ),
        ),
      );
    }
  }
} 