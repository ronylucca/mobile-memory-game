import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_memory_game/models/theme_model.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;
  final bool _isDebugMode = false; // Alterado para false para permitir o áudio
  ThemeModel? _currentTheme;
  
  // Cache para evitar verificar várias vezes o mesmo arquivo
  final Map<String, bool> _assetExistsCache = {};

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal() {
    _setupAudioPlayer();
    _verifyAudioFiles();
  }

  void _setupAudioPlayer() {
    debugPrint('Configurando AudioPlayer com audioplayers 6.4.0');
    
    // Na versão 6.4.0, podemos configurar listeners para eventos
    _audioPlayer.onPlayerStateChanged.listen((state) {
      debugPrint('Estado do player alterado: $state');
    });
    
    _audioPlayer.onPlayerComplete.listen((_) {
      debugPrint('Reprodução de áudio concluída');
    });
    
    // Configurar manipuladores de erros
    _audioPlayer.onLog.listen((log) {
      debugPrint('AudioPlayer log: $log');
    });
    
    // Definir volume inicial
    _audioPlayer.setVolume(0.5);
    
    // Configuração simplificada para usar os métodos disponíveis em audioplayers 6.4.0
    try {
      // Configuração do AudioContext usando os métodos corretos da versão 6.4.0
      final audioContext = AudioContext(
        android: AudioContextAndroid(
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.defaultToSpeaker},
        ),
      );
      
      // Configuração global com o novo contexto
      _audioPlayer.setAudioContext(audioContext);
      
      debugPrint('AudioContext configurado com sucesso');
    } catch (e) {
      debugPrint('Erro ao configurar contexto de áudio global: $e');
    }
  }
  
  // Sons padrão do jogo
  static const String soundAccessTheme = 'assets/audio/access_theme.mp3';
  static const String soundGameStart = 'assets/audio/game_start.mp3';
  static const String soundCardFlip = 'assets/audio/card_flip.mp3';
  static const String soundMatchFound = 'assets/audio/match_found.mp3';
  static const String soundNoMatch = 'assets/audio/no_match.mp3';
  static const String soundGameEnd = 'assets/audio/game_end.mp3';

  // Verifica se os arquivos de áudio padrão existem
  Future<void> _verifyAudioFiles() async {
    debugPrint('Verificando arquivos de áudio...');
    
    final soundFiles = [
      soundAccessTheme,
      soundGameStart,
      soundCardFlip,
      soundMatchFound,
      soundNoMatch,
      soundGameEnd,
    ];
    
    for (final soundFile in soundFiles) {
      final exists = await _doesAssetExist(soundFile);
      debugPrint('Arquivo $soundFile ${exists ? 'existe' : 'não existe'}');
    }
  }
  
  // Verifica se um asset existe
  Future<bool> _doesAssetExist(String assetPath) async {
    // Verifica no cache primeiro
    if (_assetExistsCache.containsKey(assetPath)) {
      return _assetExistsCache[assetPath]!;
    }
    
    try {
      await rootBundle.load(assetPath);
      _assetExistsCache[assetPath] = true;
      return true;
    } catch (e) {
      _assetExistsCache[assetPath] = false;
      return false;
    }
  }

  // Normaliza o caminho do asset para evitar duplicação de 'assets/' no web
  String _normalizeAssetPath(String path) {
    // No ambiente web, o audioplayers adiciona 'assets/' ao caminho,
    // então precisamos remover esse prefixo para evitar a repetição
    if (path.startsWith('assets/')) {
      return path.substring(7); // Remove 'assets/' do início
    }
    return path;
  }

  bool get isMuted => _isMuted;

  // Define o tema atual para usar os sons específicos do tema
  void setCurrentTheme(ThemeModel theme) {
    _currentTheme = theme;
    debugPrint('Tema definido: ${theme.id}');
  }

  // Toca um som específico do tema se disponível, ou o som padrão como fallback
  Future<void> playThemeSound(String soundKey) async {
    if (_isMuted || _isDebugMode) {
      debugPrint('Som não tocado: mudo=$_isMuted, modo debug=$_isDebugMode');
      return;
    }

    String soundPath = '';
    
    // Verifica se temos um tema definido e se ele tem o som específico
    if (_currentTheme != null && _currentTheme!.themeSounds.containsKey(soundKey)) {
      soundPath = _currentTheme!.themeSounds[soundKey]!;
      
      // Verifica se o arquivo existe
      final exists = await _doesAssetExist(soundPath);
      if (exists) {
        debugPrint('Usando som do tema ${_currentTheme!.id}: $soundPath');
        
        try {
          // Na versão 6.4.0, o processo é um pouco diferente
          await _audioPlayer.stop(); // Primeiro, para a reprodução atual
          
          // Cria a Source do arquivo de áudio
          final source = AssetSource(_normalizeAssetPath(soundPath));
          
          // Define a fonte e inicia a reprodução
          await _audioPlayer.play(source);
          
          debugPrint('Som do tema tocado com sucesso: $soundPath');
          return;
        } catch (e) {
          debugPrint('Erro ao tocar som específico do tema: $e. Usando som padrão como fallback.');
          // Se falhar, usamos o som padrão como fallback
        }
      } else {
        debugPrint('Arquivo de som do tema não encontrado: $soundPath. Usando som padrão como fallback.');
      }
    } else if (_currentTheme != null) {
      debugPrint('Som $soundKey não encontrado no tema ${_currentTheme!.id}. Usando som padrão.');
    } else {
      debugPrint('Nenhum tema definido. Usando som padrão.');
    }
    
    // Usa o som padrão como fallback
    switch (soundKey) {
      case 'card_flip':
        soundPath = soundCardFlip;
        break;
      case 'match_found':
        soundPath = soundMatchFound;
        break;
      case 'no_match':
        soundPath = soundNoMatch;
        break;
      case 'game_end':
        soundPath = soundGameEnd;
        break;
      case 'powerup':
        soundPath = 'audio/powerup.mp3'; // Som especial para powerups
        break;
      default:
        debugPrint('Tipo de som $soundKey não reconhecido!');
        return; // Sai se não encontrou um som correspondente
    }
    
    // Verifica se o arquivo de fallback existe
    final exists = await _doesAssetExist(soundPath);
    if (!exists) {
      debugPrint('Arquivo de som padrão não encontrado: $soundPath. Não será reproduzido.');
      return;
    }
    
    debugPrint('Usando som padrão: $soundPath');
    try {
      await _audioPlayer.stop();
      
      // Cria a Source do arquivo de áudio padrão
      final source = AssetSource(_normalizeAssetPath(soundPath));
      
      // Define a fonte e inicia a reprodução
      await _audioPlayer.play(source);
      
      debugPrint('Som padrão tocado com sucesso: $soundPath');
    } catch (e) {
      debugPrint('Erro ao tocar som padrão: $e');
    }
  }

  // Método original para compatibilidade
  Future<void> playSound(String soundPath) async {
    if (_isMuted || _isDebugMode) {
      debugPrint('Som não tocado: mudo=$_isMuted, modo debug=$_isDebugMode');
      return;
    }
    
    // Normaliza o caminho do asset
    final normalizedPath = _normalizeAssetPath(soundPath);
    
    // Verifica se o arquivo existe
    final exists = await _doesAssetExist(normalizedPath);
    if (!exists) {
      debugPrint('Arquivo de som não encontrado: $normalizedPath. Não será reproduzido.');
      return;
    }
    
    try {
      debugPrint('Tentando tocar som: $normalizedPath');
      
      // Para a reprodução atual
      await _audioPlayer.stop();
      
      // Cria a Source do arquivo de áudio
      final source = AssetSource(normalizedPath);
      
      // Define a fonte e inicia a reprodução
      await _audioPlayer.play(source);
      
      debugPrint('Som tocado com sucesso: $normalizedPath');
    } catch (e) {
      debugPrint('Erro ao tocar som: $e');
    }
  }

  // Pausa o som atual
  Future<void> pauseSound() async {
    if (_isDebugMode) return;
    
    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('Erro ao pausar som: $e');
    }
  }

  // Retoma o som pausado
  Future<void> resumeSound() async {
    if (_isMuted || _isDebugMode) return;
    
    try {
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('Erro ao retomar som: $e');
    }
  }

  // Para o som atual
  Future<void> stopSound() async {
    if (_isDebugMode) return;
    
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Erro ao parar som: $e');
    }
  }

  // Alterna o estado de mudo
  void toggleMute() {
    _isMuted = !_isMuted;
    
    if (_isDebugMode) return;
    
    if (_isMuted) {
      _audioPlayer.setVolume(0.0);
    } else {
      _audioPlayer.setVolume(0.5);
    }
  }

  // Define o volume (0.0 a 1.0)
  Future<void> setVolume(double volume) async {
    if (_isDebugMode) return;
    
    try {
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      debugPrint('Erro ao definir volume: $e');
    }
  }

  // Dispõe o AudioPlayer
  void dispose() {
    if (_isDebugMode) return;
    
    _audioPlayer.dispose();
  }

  // Toca som específico de powerup
  Future<void> playPowerupSound() async {
    await playThemeSound('powerup');
  }
} 