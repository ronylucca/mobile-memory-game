import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/models/game_model.dart';
import 'package:mobile_memory_game/screens/game_screen.dart';
import 'package:mobile_memory_game/utils/audio_manager.dart';

class PlayerSetupScreen extends StatefulWidget {
  final ThemeModel selectedTheme;

  const PlayerSetupScreen({
    super.key,
    required this.selectedTheme,
  });

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final TextEditingController _player1Controller = TextEditingController(text: 'Jogador 1');
  final TextEditingController _player2Controller = TextEditingController(text: 'Jogador 2');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AudioManager _audioManager = AudioManager();
  
  // Campos para o timer
  GameMode _selectedGameMode = GameMode.zen;
  int _selectedMinutes = 5;
  final List<int> _availableMinutes = [1, 2, 3, 5, 10, 15, 20, 30];

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(widget.selectedTheme.backgroundImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Configurar Jogadores',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: const Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Para centralizar o título
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Tema selecionado: ${widget.selectedTheme.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Nomes dos Jogadores',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildPlayerTextField(
                              controller: _player1Controller,
                              label: 'Jogador 1',
                              icon: Icons.person,
                              color: widget.selectedTheme.primaryColor,
                            ),
                            const SizedBox(height: 20),
                            _buildPlayerTextField(
                              controller: _player2Controller,
                              label: 'Jogador 2',
                              icon: Icons.person,
                              color: widget.selectedTheme.secondaryColor,
                            ),
                            const SizedBox(height: 30),
                            
                            // Seção de modo de jogo
                            const Text(
                              'Modo de Jogo',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Opção Zen
                            _buildGameModeOption(
                              title: 'Modo Zen',
                              subtitle: 'Jogue sem pressa',
                              icon: Icons.self_improvement,
                              mode: GameMode.zen,
                              color: widget.selectedTheme.primaryColor,
                            ),
                            const SizedBox(height: 15),
                            
                            // Opção Timer
                            _buildGameModeOption(
                              title: 'Modo Timer',
                              subtitle: 'Jogue contra o tempo',
                              icon: Icons.timer,
                              mode: GameMode.timer,
                              color: widget.selectedTheme.secondaryColor,
                            ),
                            
                            // Seletor de minutos (apenas para modo timer)
                            if (_selectedGameMode == GameMode.timer) ...[
                              const SizedBox(height: 20),
                              _buildTimerSelector(),
                            ],
                            
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _startGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.selectedTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _selectedGameMode == GameMode.zen 
                                    ? 'Começar Jogo Zen' 
                                    : 'Começar Jogo ($_selectedMinutes min)',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildPlayerTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color),
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color.withOpacity(0.5)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira o nome do jogador';
        }
        return null;
      },
    );
  }

  Widget _buildGameModeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required GameMode mode,
    required Color color,
  }) {
    final isSelected = _selectedGameMode == mode;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGameMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : color.withOpacity(0.7),
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? color.withOpacity(0.8) : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.selectedTheme.secondaryColor.withOpacity(0.3),
        ),
        color: widget.selectedTheme.secondaryColor.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duração do Timer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.selectedTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableMinutes.map((minutes) {
              final isSelected = _selectedMinutes == minutes;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMinutes = minutes;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isSelected 
                        ? widget.selectedTheme.secondaryColor 
                        : widget.selectedTheme.secondaryColor.withOpacity(0.1),
                    border: Border.all(
                      color: widget.selectedTheme.secondaryColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${minutes}min',
                    style: TextStyle(
                      color: isSelected ? Colors.white : widget.selectedTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _startGame() {
    if (_formKey.currentState!.validate()) {
      // Define o tema atual no AudioManager antes de tocar o som
      _audioManager.setCurrentTheme(widget.selectedTheme);
      
      // Toca o som de início do jogo específico do tema
      _audioManager.playThemeSound('game_start');
      
      // Navega para a tela do jogo
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameScreen(
            player1Name: _player1Controller.text,
            player2Name: _player2Controller.text,
            theme: widget.selectedTheme,
            gameMode: _selectedGameMode,
            timerMinutes: _selectedGameMode == GameMode.timer ? _selectedMinutes : null,
          ),
        ),
      );
    }
  }
} 