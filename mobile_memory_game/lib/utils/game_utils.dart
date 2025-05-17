import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/theme_model.dart';

class GameUtils {
  
  // Realiza o "cara ou coroa" virtual
  static int coinToss() {
    final random = Random();
    return random.nextInt(2);
  }
  
  // Formata o tempo em formato mm:ss
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = remainingSeconds.toString().padLeft(2, '0');
    
    return '$minutesStr:$secondsStr';
  }
  
  // Obtém a cor de acordo com o tema
  static Color getColorForTheme(ThemeModel theme, {bool isSecondary = false}) {
    return isSecondary ? theme.secondaryColor : theme.primaryColor;
  }
  
  // Embaralha uma lista usando o algoritmo Fisher-Yates
  static List<T> shuffleList<T>(List<T> list) {
    final random = Random();
    final shuffledList = List<T>.from(list);
    
    for (var i = shuffledList.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = shuffledList[i];
      shuffledList[i] = shuffledList[j];
      shuffledList[j] = temp;
    }
    
    return shuffledList;
  }
  
  // Calcula o tamanho da carta com base no tamanho da tela
  static Size calculateCardSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Definindo a proporção ideal para as cartas em modo retrato e paisagem
    const aspectRatio = 3 / 4; // Proporção altura/largura
    
    // Calculando o tamanho da carta com base no layout do grid (5x4)
    final cardWidth = (screenWidth - 48) / 5; // 5 cartas por linha, com espaçamento
    final cardHeight = cardWidth * aspectRatio;
    
    // Verificando se a altura resultante é adequada para a tela
    final gridHeight = cardHeight * 4 + 32; // 4 cartas por coluna, com espaçamento
    
    if (gridHeight > screenHeight * 0.6) {
      // Ajusta o tamanho com base na altura disponível
      final availableHeight = screenHeight * 0.6;
      final adjustedHeight = (availableHeight - 32) / 4; // 4 linhas, com espaçamento
      final adjustedWidth = adjustedHeight / aspectRatio;
      
      return Size(adjustedWidth, adjustedHeight);
    }
    
    return Size(cardWidth, cardHeight);
  }
  
  // Obtém um gradiente baseado no tema
  static LinearGradient getGradientForTheme(ThemeModel theme) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.primaryColor.withOpacity(0.7),
        theme.secondaryColor.withOpacity(0.7),
      ],
    );
  }
} 