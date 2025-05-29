import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/screens/ai_game_setup_screen.dart';
import 'dart:math' as math;
import 'dart:async';

class AIGameScreen extends StatefulWidget {
  final ThemeModel theme;
  final String playerName;
  final AIDifficulty aiDifficulty;

  const AIGameScreen({
    super.key,
    required this.theme,
    required this.playerName,
    required this.aiDifficulty,
  });

  @override
  State<AIGameScreen> createState() => _AIGameScreenState();
}

class _AIGameScreenState extends State<AIGameScreen> {
  int playerScore = 0;
  int aiScore = 0;
  bool isPlayerTurn = true;
  bool isThinking = false;
  String currentStatus = '';
  Timer? aiThinkingTimer;

  @override
  void initState() {
    super.initState();
    currentStatus = 'Sua vez de jogar!';
  }

  @override
  void dispose() {
    aiThinkingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.theme.primaryColor,
              widget.theme.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header com botão voltar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        'vs IA ${_getDifficultyName()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Scoreboard
              _buildScoreboard(),

              const SizedBox(height: 20),

              // Status atual
              _buildGameStatus(),

              const SizedBox(height: 20),

              // Área do jogo (simplificada por enquanto)
              _buildGameArea(),

              const Spacer(),

              // Botões de ação
              _buildActionButtons(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreboard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Jogador
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.person, color: Colors.white, size: 24),
                const SizedBox(height: 8),
                Text(
                  widget.playerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isPlayerTurn 
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                  child: Text(
                    '$playerScore',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // VS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
              'VS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // IA
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.smart_toy, color: Colors.white, size: 24),
                const SizedBox(height: 8),
                Text(
                  'IA ${_getDifficultyName()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: !isPlayerTurn 
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                  child: Text(
                    '$aiScore',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isThinking) ...[
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            currentStatus,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.1),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.extension,
                color: Colors.white,
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'Área do Jogo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'O jogo completo será implementado aqui.\n'
                'Por enquanto, use os botões abaixo para testar a IA.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isPlayerTurn && !isThinking ? _simulatePlayerMove : null,
              icon: const Icon(Icons.touch_app),
              label: const Text('Simular Jogada'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: widget.theme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: !isPlayerTurn && !isThinking ? _triggerAIMove : null,
              icon: const Icon(Icons.smart_toy),
              label: const Text('IA Jogar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.8),
                foregroundColor: widget.theme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyName() {
    switch (widget.aiDifficulty) {
      case AIDifficulty.easy:
        return 'Fácil';
      case AIDifficulty.moderate:
        return 'Moderado';
      case AIDifficulty.hard:
        return 'Difícil';
    }
  }

  void _simulatePlayerMove() {
    if (!isPlayerTurn || isThinking) return;

    setState(() {
      // Simula uma jogada do jogador
      final random = math.Random();
      final success = random.nextBool(); // 50% chance de acerto
      
      if (success) {
        playerScore += 10;
        currentStatus = 'Bom trabalho! Você fez um par!';
      } else {
        currentStatus = 'Que pena, tente novamente!';
      }
      
      isPlayerTurn = false;
    });

    // Automaticamente triggers IA após 1 segundo
    Timer(const Duration(seconds: 1), () {
      _triggerAIMove();
    });
  }

  void _triggerAIMove() {
    if (isPlayerTurn || isThinking) return;

    setState(() {
      isThinking = true;
      currentStatus = 'IA está pensando...';
    });

    // Simula tempo de pensamento baseado na dificuldade
    final thinkingTime = _getAIThinkingTime();
    
    aiThinkingTimer = Timer(thinkingTime, () {
      _executeAIMove();
    });
  }

  Duration _getAIThinkingTime() {
    switch (widget.aiDifficulty) {
      case AIDifficulty.easy:
        return Duration(milliseconds: 500 + math.Random().nextInt(1000)); // 0.5-1.5s
      case AIDifficulty.moderate:
        return Duration(milliseconds: 1000 + math.Random().nextInt(1500)); // 1-2.5s
      case AIDifficulty.hard:
        return Duration(milliseconds: 1500 + math.Random().nextInt(2000)); // 1.5-3.5s
    }
  }

  void _executeAIMove() {
    if (!mounted) return;

    setState(() {
      isThinking = false;
      
      // Lógica de sucesso baseada na dificuldade
      final successChance = _getAISuccessChance();
      final random = math.Random();
      final success = random.nextDouble() < successChance;
      
      if (success) {
        aiScore += 10;
        currentStatus = 'IA encontrou um par! 🤖';
        
        // IA difícil pode jogar novamente
        if (widget.aiDifficulty == AIDifficulty.hard && random.nextDouble() < 0.3) {
          Timer(const Duration(seconds: 1), () {
            _triggerAIMove();
          });
          return;
        }
      } else {
        currentStatus = 'IA errou! Sua vez!';
      }
      
      isPlayerTurn = true;
    });

    // Update status for player turn
    Timer(const Duration(seconds: 1), () {
      if (mounted && isPlayerTurn) {
        setState(() {
          currentStatus = 'Sua vez de jogar!';
        });
      }
    });
  }

  double _getAISuccessChance() {
    switch (widget.aiDifficulty) {
      case AIDifficulty.easy:
        return 0.3; // 30% chance de acerto
      case AIDifficulty.moderate:
        return 0.6; // 60% chance de acerto
      case AIDifficulty.hard:
        return 0.85; // 85% chance de acerto
    }
  }
} 