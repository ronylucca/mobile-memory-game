import 'package:flutter/material.dart';
import 'dart:math';

class ResponsiveLayout {
  static const int totalCards = 20;
  static const double cardAspectRatio = 4.0 / 3.0; // largura/altura (3:4 das imagens)
  
  /// Calcula a melhor configuração de layout para as cartas
  static LayoutConfig calculateOptimalLayout(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    
    // Definir margens e espaçamentos base
    const double baseMargin = 16.0;
    const double cardSpacing = 4.0;
    
    // Calcular altura disponível para o grid (considerando header e footer)
    double availableHeight = screenSize.height;
    
    // Subtrair espaços do SafeArea, header, scoreboard e controles
    final safePaddingTop = MediaQuery.of(context).padding.top;
    final safePaddingBottom = MediaQuery.of(context).padding.bottom;
    final headerHeight = getHeaderHeight(context);
    final scoreBoardHeight = getScoreBoardHeight(context);
    final controlsHeight = getControlsHeight(context);
    
    availableHeight -= safePaddingTop;
    availableHeight -= safePaddingBottom;
    availableHeight -= headerHeight;
    availableHeight -= scoreBoardHeight;
    availableHeight -= controlsHeight;
    availableHeight -= (baseMargin * 2); // Margens principais
    
    // Espaçamentos entre seções - ser mais conservador
    final isLargeScreen = screenSize.width > 768;
    final spacingBetweenSections = isLargeScreen ? 60 : 36; // 3 espaços de 20px ou 12px
    availableHeight -= spacingBetweenSections;
    availableHeight -= 16; // Padding do container do grid
    
    // Garantir altura mínima para o grid
    if (availableHeight < 200) {
      availableHeight = screenSize.height * 0.4; // Usar pelo menos 40% da tela para o grid
    }
    
    double availableWidth = screenSize.width - (baseMargin * 2) - 16; // Subtrair padding do container
    
    print('=== RESPONSIVE LAYOUT DEBUG ===');
    print('Screen size: ${screenSize.width} x ${screenSize.height}');
    print('Safe padding: top=$safePaddingTop, bottom=$safePaddingBottom');
    print('Component heights: header=$headerHeight, scoreBoard=$scoreBoardHeight, controls=$controlsHeight');
    print('Available space: ${availableWidth} x $availableHeight');
    
    // Encontrar a melhor configuração de grid
    LayoutConfig bestConfig = _findBestGridLayout(
      availableWidth: availableWidth,
      availableHeight: availableHeight,
      cardSpacing: cardSpacing,
    );
    
    print('Best config: ${bestConfig.columns}x${bestConfig.rows}, card size: ${bestConfig.cardWidth}x${bestConfig.cardHeight}');
    print('Grid height: ${bestConfig.gridHeight}');
    print('==============================');
    
    return bestConfig;
  }
  
  /// Encontra a melhor configuração de grid testando diferentes opções
  static LayoutConfig _findBestGridLayout({
    required double availableWidth,
    required double availableHeight,
    required double cardSpacing,
  }) {
    List<LayoutConfig> possibleConfigs = [];
    
    // Testar diferentes configurações de grid
    List<GridConfig> gridOptions = [
      GridConfig(columns: 5, rows: 4), // Layout padrão
      GridConfig(columns: 4, rows: 5), // Layout vertical
      GridConfig(columns: 10, rows: 2), // Layout super horizontal (para tablets em landscape)
      GridConfig(columns: 2, rows: 10), // Layout super vertical (para celulares em portrait)
      GridConfig(columns: 6, rows: 4), // Mais colunas (para tablets)
      GridConfig(columns: 8, rows: 3), // Layout intermediário horizontal
    ];
    
    for (GridConfig grid in gridOptions) {
      // Verificar se o grid tem espaço suficiente para 20 cartas
      if (grid.columns * grid.rows < totalCards) {
        print('Skipping ${grid.columns}x${grid.rows} - not enough space for $totalCards cards');
        continue;
      }
      
      // Calcular tamanho das cartas para esta configuração
      double cardWidth = (availableWidth - (cardSpacing * (grid.columns - 1))) / grid.columns;
      double cardHeight = cardWidth * cardAspectRatio;
      
      // Verificar se as cartas cabem na altura disponível
      double totalGridHeight = (cardHeight * grid.rows) + (cardSpacing * (grid.rows - 1));
      
      print('Testing ${grid.columns}x${grid.rows}: cardSize=${cardWidth.toStringAsFixed(1)}x${cardHeight.toStringAsFixed(1)}, gridHeight=${totalGridHeight.toStringAsFixed(1)}, availableHeight=${availableHeight.toStringAsFixed(1)}');
      
      if (totalGridHeight <= availableHeight && cardWidth > 30) { // mínimo de 30px de largura
        possibleConfigs.add(LayoutConfig(
          columns: grid.columns,
          rows: grid.rows,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          cardSpacing: cardSpacing,
          gridHeight: totalGridHeight,
        ));
        print('✓ Added config ${grid.columns}x${grid.rows}');
      } else {
        print('✗ Rejected ${grid.columns}x${grid.rows} - grid too tall or cards too small');
      }
    }
    
    // Se nenhuma configuração coube, ajustar pela altura disponível
    if (possibleConfigs.isEmpty) {
      print('No valid configs found, using fallback');
      return _createFallbackLayout(availableWidth, availableHeight, cardSpacing);
    }
    
    // Escolher a configuração que maximiza o tamanho das cartas
    possibleConfigs.sort((a, b) => (b.cardWidth * b.cardHeight).compareTo(a.cardWidth * a.cardHeight));
    
    print('Found ${possibleConfigs.length} valid configs, choosing: ${possibleConfigs.first.columns}x${possibleConfigs.first.rows}');
    
    return possibleConfigs.first;
  }
  
  /// Cria um layout fallback quando nenhuma configuração padrão cabe
  static LayoutConfig _createFallbackLayout(
    double availableWidth,
    double availableHeight,
    double cardSpacing,
  ) {
    print('Creating fallback layout...');
    
    // Tentar diferentes configurações em ordem de preferência
    List<GridConfig> fallbackOptions = [
      GridConfig(columns: 5, rows: 4),  // Padrão
      GridConfig(columns: 4, rows: 5),  // Mais vertical
      GridConfig(columns: 10, rows: 2), // Muito horizontal
      GridConfig(columns: 2, rows: 10), // Muito vertical
      GridConfig(columns: 6, rows: 4),  // Intermediário
      GridConfig(columns: 8, rows: 3),  // Horizontal
    ];
    
    for (GridConfig grid in fallbackOptions) {
      if (grid.columns * grid.rows < totalCards) continue;
      
      // Calcular tamanho máximo baseado na largura
      double maxCardWidthFromWidth = (availableWidth - (cardSpacing * (grid.columns - 1))) / grid.columns;
      
      // Calcular tamanho máximo baseado na altura
      double maxCardHeightFromHeight = (availableHeight - (cardSpacing * (grid.rows - 1))) / grid.rows;
      
      // Tentar dimensionar pela largura primeiro
      double cardWidth = maxCardWidthFromWidth;
      double cardHeight = cardWidth * cardAspectRatio;
      
      // Se não coube na altura, dimensionar pela altura
      if (cardHeight > maxCardHeightFromHeight) {
        cardHeight = maxCardHeightFromHeight;
        cardWidth = cardHeight / cardAspectRatio;
      }
      
      // Verificar se o tamanho mínimo é respeitado
      if (cardWidth >= 25 && cardHeight >= 25) { // tamanho mínimo muito pequeno
        print('✓ Fallback using ${grid.columns}x${grid.rows}: ${cardWidth.toStringAsFixed(1)}x${cardHeight.toStringAsFixed(1)}');
        return LayoutConfig(
          columns: grid.columns,
          rows: grid.rows,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          cardSpacing: cardSpacing,
          gridHeight: (cardHeight * grid.rows) + (cardSpacing * (grid.rows - 1)),
        );
      }
    }
    
    // Se chegou aqui, usar configuração mínima extrema
    print('⚠️ Using emergency fallback');
    int columns = 5;
    int rows = 4;
    double cardWidth = (availableWidth - (cardSpacing * (columns - 1))) / columns;
    double cardHeight = (availableHeight - (cardSpacing * (rows - 1))) / rows;
    
    return LayoutConfig(
      columns: columns,
      rows: rows,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      cardSpacing: cardSpacing,
      gridHeight: (cardHeight * rows) + (cardSpacing * (rows - 1)),
    );
  }
  
  /// Calcula altura do header baseada no dispositivo
  static double getHeaderHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth > 1024) return 60; // Desktop/Tablet grande
    if (screenWidth > 768) return 55;  // Tablet
    return 50; // Mobile
  }
  
  /// Calcula altura do scoreboard baseada no dispositivo
  static double getScoreBoardHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth > 1024) return 45; // Desktop/Tablet grande - reduzido pela metade
    if (screenWidth > 768) return 40;  // Tablet - reduzido pela metade
    return 38; // Mobile - reduzido pela metade
  }
  
  /// Calcula altura dos controles baseada no dispositivo
  static double getControlsHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth > 1024) return 70; // Desktop/Tablet grande
    if (screenWidth > 768) return 65;  // Tablet
    return 60; // Mobile
  }
  
  /// Verifica se é um dispositivo grande (tablet/desktop)
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 768;
  }
  
  /// Verifica se está em modo paisagem
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
}

class LayoutConfig {
  final int columns;
  final int rows;
  final double cardWidth;
  final double cardHeight;
  final double cardSpacing;
  final double gridHeight;
  
  const LayoutConfig({
    required this.columns,
    required this.rows,
    required this.cardWidth,
    required this.cardHeight,
    required this.cardSpacing,
    required this.gridHeight,
  });
  
  double get aspectRatio => cardHeight / cardWidth;
}

class GridConfig {
  final int columns;
  final int rows;
  
  const GridConfig({required this.columns, required this.rows});
} 