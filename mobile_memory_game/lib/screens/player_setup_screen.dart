import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/models/game_model.dart';
import 'package:mobile_memory_game/screens/game_screen.dart';
import 'package:mobile_memory_game/screens/ai_game_setup_screen.dart'; // Para AIDifficulty
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
  
  // Campos para IA
  bool _isAIEnabled = false;
  AIDifficulty _selectedAIDifficulty = AIDifficulty.moderate;

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
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
          child: Column(
            children: [
              // Header fixo
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
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
                              fontSize: isSmallScreen ? 24 : 28,
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
                    SizedBox(height: isSmallScreen ? 10 : 20),
                    Text(
                      'Tema selecionado: ${widget.selectedTheme.name}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Conteúdo com scroll
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Form(
                    key: _formKey,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Conteúdo scrollável
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                              child: isSmallScreen 
                                  ? _buildCompactContent()
                                  : _buildStandardContent(),
                            ),
                          ),
                          
                          // Botão fixo na parte inferior
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: _buildStartButton(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Espaçamento inferior
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Conteúdo padrão para telas maiores (sem botão)
  Widget _buildStandardContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Configuração dos Jogadores',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        
        // Jogador 1
        _buildPlayerTextField(
          controller: _player1Controller,
          label: 'Jogador 1',
          icon: Icons.person,
          color: widget.selectedTheme.primaryColor,
        ),
        const SizedBox(height: 20),
        
        // Seção Jogador 2 / IA
        _buildPlayer2Section(),
        
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
      ],
    );
  }

  // Conteúdo compacto para telas menores (sem botão)
  Widget _buildCompactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Configuração dos Jogadores',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildPlayerTextField(
          controller: _player1Controller,
          label: 'Jogador 1',
          icon: Icons.person,
          color: widget.selectedTheme.primaryColor,
        ),
        const SizedBox(height: 15),
        
        // Seção Jogador 2 / IA compacta
        _buildCompactPlayer2Section(),
        
        const SizedBox(height: 25),
        
        // Seção de modo de jogo
        const Text(
          'Modo de Jogo',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        
        // Opções em layout compacto
        _buildCompactGameModeOption(
          title: 'Modo Zen',
          subtitle: 'Sem pressa',
          icon: Icons.self_improvement,
          mode: GameMode.zen,
          color: widget.selectedTheme.primaryColor,
        ),
        const SizedBox(height: 10),
        
        _buildCompactGameModeOption(
          title: 'Modo Timer',
          subtitle: 'Contra o tempo',
          icon: Icons.timer,
          mode: GameMode.timer,
          color: widget.selectedTheme.secondaryColor,
        ),
        
        // Seletor de minutos compacto (apenas para modo timer)
        if (_selectedGameMode == GameMode.timer) ...[
          const SizedBox(height: 15),
          _buildCompactTimerSelector(),
        ],
      ],
    );
  }

  Widget _buildPlayerTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final readableColor = _getReadableBackgroundColor(color);
    
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: readableColor),
        prefixIcon: Icon(icon, color: readableColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: readableColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: readableColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: readableColor.withOpacity(0.5)),
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
    final readableColor = _getReadableBackgroundColor(color);
    
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
            color: isSelected ? readableColor : readableColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? readableColor.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? readableColor : readableColor.withOpacity(0.7),
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
                      color: isSelected ? readableColor : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? readableColor.withOpacity(0.8) : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: readableColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSelector() {
    final readableColor = _getReadableBackgroundColor(widget.selectedTheme.secondaryColor);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: readableColor.withOpacity(0.3),
        ),
        color: readableColor.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duração do Timer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: readableColor,
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
                        ? readableColor 
                        : readableColor.withOpacity(0.1),
                    border: Border.all(
                      color: readableColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${minutes}min',
                    style: TextStyle(
                      color: isSelected ? Colors.white : readableColor,
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

  Widget _buildStartButton() {
    final readableColor = _getReadableBackgroundColor(widget.selectedTheme.primaryColor);
    
    String buttonText;
    if (_isAIEnabled) {
      buttonText = _selectedGameMode == GameMode.zen 
          ? 'Jogar vs IA (Zen)' 
          : 'Jogar vs IA ($_selectedMinutes min)';
    } else {
      buttonText = _selectedGameMode == GameMode.zen 
          ? 'Começar Jogo Zen' 
          : 'Começar Jogo ($_selectedMinutes min)';
    }
    
    return ElevatedButton(
      onPressed: _startGame,
      style: ElevatedButton.styleFrom(
        backgroundColor: readableColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _startGame() {
    if (_formKey.currentState!.validate()) {
      // Define o tema atual no AudioManager antes de tocar o som
      _audioManager.setCurrentTheme(widget.selectedTheme);
      
      // Toca o som de início do jogo específico do tema
      _audioManager.playThemeSound('game_start');
      
      // Navega para a tela do jogo (normal ou com IA)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameScreen(
            player1Name: _player1Controller.text,
            player2Name: _isAIEnabled ? 'IA' : _player2Controller.text,
            theme: widget.selectedTheme,
            gameMode: _selectedGameMode,
            timerMinutes: _selectedGameMode == GameMode.timer ? _selectedMinutes : null,
            isAIEnabled: _isAIEnabled,
            aiDifficulty: _isAIEnabled ? _selectedAIDifficulty : null,
          ),
        ),
      );
    }
  }

  // Método auxiliar para determinar se a cor precisa de contraste
  Color _getReadableTextColor(Color backgroundColor) {
    // Calcula a luminância da cor para determinar se o texto deve ser escuro ou claro
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  // Método auxiliar para obter cor de fundo adequada
  Color _getReadableBackgroundColor(Color themeColor) {
    final luminance = themeColor.computeLuminance();
    // Para cores muito claras, usar uma versão mais escura
    if (luminance > 0.7) {
      return HSLColor.fromColor(themeColor).withLightness(0.3).toColor();
    }
    return themeColor;
  }

  // Game mode option compacto para telas menores
  Widget _buildCompactGameModeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required GameMode mode,
    required Color color,
  }) {
    final isSelected = _selectedGameMode == mode;
    final readableColor = _getReadableBackgroundColor(color);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGameMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? readableColor : readableColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? readableColor.withOpacity(0.15) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? readableColor : readableColor.withOpacity(0.7),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? readableColor : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? readableColor.withOpacity(0.8) : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: readableColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // Timer selector compacto para telas menores
  Widget _buildCompactTimerSelector() {
    final readableColor = _getReadableBackgroundColor(widget.selectedTheme.secondaryColor);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: readableColor.withOpacity(0.3),
        ),
        color: readableColor.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duração do Timer',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: readableColor,
            ),
          ),
          const SizedBox(height: 10),
          // Grid compacto ao invés de Wrap para melhor controle
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.0,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: _availableMinutes.length,
            itemBuilder: (context, index) {
              final minutes = _availableMinutes[index];
              final isSelected = _selectedMinutes == minutes;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMinutes = minutes;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isSelected 
                        ? readableColor 
                        : readableColor.withOpacity(0.1),
                    border: Border.all(
                      color: readableColor,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${minutes}min',
                      style: TextStyle(
                        color: isSelected ? Colors.white : readableColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer2Section() {
    final readableColor = _getReadableBackgroundColor(widget.selectedTheme.secondaryColor);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: readableColor.withOpacity(0.3),
          width: 1,
        ),
        color: readableColor.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _isAIEnabled ? Icons.smart_toy : Icons.person,
                color: readableColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isAIEnabled ? 'IA (Inteligência Artificial)' : 'Jogador 2',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: readableColor,
                  ),
                ),
              ),
              Switch.adaptive(
                value: _isAIEnabled,
                onChanged: (value) {
                  setState(() {
                    _isAIEnabled = value;
                  });
                },
                activeColor: readableColor,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Campo de nome do jogador ou configuração da IA
          if (!_isAIEnabled) 
            _buildPlayerTextField(
              controller: _player2Controller,
              label: 'Nome do Jogador 2',
              icon: Icons.person,
              color: widget.selectedTheme.secondaryColor,
            )
          else
            _buildAIDifficultySelection(),
        ],
      ),
    );
  }

  Widget _buildAIDifficultySelection() {
    final readableColor = _getReadableBackgroundColor(widget.selectedTheme.secondaryColor);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '🤖 Escolha a Dificuldade da IA',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: readableColor,
          ),
        ),
        const SizedBox(height: 12),
        
        ...AIDifficulty.values.map((difficulty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildDifficultyOption(difficulty, readableColor),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDifficultyOption(AIDifficulty difficulty, Color themeColor) {
    final isSelected = _selectedAIDifficulty == difficulty;
    final difficultyInfo = _getDifficultyInfo(difficulty);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAIDifficulty = difficulty;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? difficultyInfo['color'] : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? difficultyInfo['color'].withOpacity(0.1) 
              : Colors.white,
        ),
        child: Row(
          children: [
            Text(
              difficultyInfo['icon'],
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficultyInfo['name'],
                    style: TextStyle(
                      fontSize: 14,
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
                size: 18,
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
          'description': 'IA comete erros frequentes, ideal para iniciantes',
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

  Widget _buildCompactPlayer2Section() {
    final readableColor = _getReadableBackgroundColor(widget.selectedTheme.secondaryColor);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: readableColor.withOpacity(0.3),
          width: 1,
        ),
        color: readableColor.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _isAIEnabled ? Icons.smart_toy : Icons.person,
                color: readableColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isAIEnabled ? 'IA' : 'Jogador 2',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: readableColor,
                  ),
                ),
              ),
              Switch.adaptive(
                value: _isAIEnabled,
                onChanged: (value) {
                  setState(() {
                    _isAIEnabled = value;
                  });
                },
                activeColor: readableColor,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Campo de nome do jogador ou configuração da IA compacta
          if (!_isAIEnabled) 
            _buildPlayerTextField(
              controller: _player2Controller,
              label: 'Nome do Jogador 2',
              icon: Icons.person,
              color: widget.selectedTheme.secondaryColor,
            )
          else
            _buildCompactAIDifficultySelection(),
        ],
      ),
    );
  }

  Widget _buildCompactAIDifficultySelection() {
    final readableColor = _getReadableBackgroundColor(widget.selectedTheme.secondaryColor);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '🤖 Dificuldade da IA',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: readableColor,
          ),
        ),
        const SizedBox(height: 8),
        
        // Dropdown compacto ao invés de lista
        DropdownButtonFormField<AIDifficulty>(
          value: _selectedAIDifficulty,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
          onChanged: (AIDifficulty? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedAIDifficulty = newValue;
              });
            }
          },
          items: AIDifficulty.values.map<DropdownMenuItem<AIDifficulty>>((AIDifficulty difficulty) {
            final info = _getDifficultyInfo(difficulty);
            return DropdownMenuItem<AIDifficulty>(
              value: difficulty,
              child: Row(
                children: [
                  Text(info['icon'], style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    info['name'],
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
} 