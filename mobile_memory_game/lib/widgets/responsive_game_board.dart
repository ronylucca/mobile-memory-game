import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/card_model.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/widgets/memory_card.dart';
import 'package:mobile_memory_game/providers/game_provider.dart';

class ResponsiveGameBoard extends StatelessWidget {
  final List<CardModel> cards;
  final ThemeModel theme;
  final Function(int) onCardTap;

  const ResponsiveGameBoard({
    super.key,
    required this.cards,
    required this.theme,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 4),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final config = _calculateBestLayout(constraints);
            
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: AspectRatio(
                  aspectRatio: config.gridWidth / config.gridHeight,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: config.columns,
                      childAspectRatio: config.cardWidth / config.cardHeight,
                      crossAxisSpacing: config.spacing,
                      mainAxisSpacing: config.spacing,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      return MemoryCard(
                        card: cards[index],
                        theme: theme,
                        onCardTap: onCardTap,
                        index: index,
                        cardSize: Size(config.cardWidth, config.cardHeight),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  GridConfiguration _calculateBestLayout(BoxConstraints constraints) {
    const double spacing = 4.0;
    const double cardAspectRatio = 4.0 / 3.0; // largura/altura (3:4 das imagens)
    const int totalCards = 20;
    
    final availableWidth = constraints.maxWidth;
    final availableHeight = constraints.maxHeight;
    
    // Possíveis configurações de grid (colunas, linhas)
    List<GridConfig> configurations = [
      GridConfig(5, 4),   // Layout padrão
      GridConfig(4, 5),   // Mais vertical
      GridConfig(10, 2),  // Muito horizontal
      GridConfig(2, 10),  // Muito vertical
      GridConfig(6, 4),   // Intermediário
      GridConfig(8, 3),   // Horizontal intermediário
    ];
    
    GridConfiguration? bestConfig;
    double bestArea = 0;
    
    for (final config in configurations) {
      // Verificar se pode acomodar todas as cartas
      if (config.columns * config.rows < totalCards) continue;
      
      // Calcular tamanho baseado na largura
      double cardWidthFromWidth = (availableWidth - (spacing * (config.columns - 1))) / config.columns;
      double cardHeightFromWidth = cardWidthFromWidth * cardAspectRatio;
      
      // Calcular tamanho baseado na altura
      double cardHeightFromHeight = (availableHeight - (spacing * (config.rows - 1))) / config.rows;
      double cardWidthFromHeight = cardHeightFromHeight / cardAspectRatio;
      
      // Usar o menor dos dois para garantir que cabe
      double cardWidth = cardWidthFromWidth < cardWidthFromHeight ? cardWidthFromWidth : cardWidthFromHeight;
      double cardHeight = cardWidth * cardAspectRatio;
      
      // Verificar se as dimensões são válidas
      final gridWidth = (cardWidth * config.columns) + (spacing * (config.columns - 1));
      final gridHeight = (cardHeight * config.rows) + (spacing * (config.rows - 1));
      
      if (gridWidth <= availableWidth && 
          gridHeight <= availableHeight && 
          cardWidth > 20 && 
          cardHeight > 20) { // tamanho mínimo
        
        final area = cardWidth * cardHeight;
        if (area > bestArea) {
          bestArea = area;
          bestConfig = GridConfiguration(
            columns: config.columns,
            rows: config.rows,
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            spacing: spacing,
            gridWidth: gridWidth,
            gridHeight: gridHeight,
          );
        }
      }
    }
    
    // Se nenhuma configuração foi encontrada, usar fallback
    if (bestConfig == null) {
      return _createFallbackConfiguration(availableWidth, availableHeight, spacing);
    }
    
    return bestConfig;
  }
  
  GridConfiguration _createFallbackConfiguration(double width, double height, double spacing) {
    // Usar configuração 5x4 e ajustar para caber
    const columns = 5;
    const rows = 4;
    const cardAspectRatio = 4.0 / 3.0; // largura/altura (3:4 das imagens)
    
    // Calcular o maior tamanho possível
    double cardWidth = (width - (spacing * (columns - 1))) / columns;
    double cardHeight = (height - (spacing * (rows - 1))) / rows;
    
    // Manter proporção
    if (cardWidth * cardAspectRatio > cardHeight) {
      cardWidth = cardHeight / cardAspectRatio;
    } else {
      cardHeight = cardWidth * cardAspectRatio;
    }
    
    final gridWidth = (cardWidth * columns) + (spacing * (columns - 1));
    final gridHeight = (cardHeight * rows) + (spacing * (rows - 1));
    
    return GridConfiguration(
      columns: columns,
      rows: rows,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      spacing: spacing,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
    );
  }
}

class GridConfig {
  final int columns;
  final int rows;
  
  const GridConfig(this.columns, this.rows);
}

class GridConfiguration {
  final int columns;
  final int rows;
  final double cardWidth;
  final double cardHeight;
  final double spacing;
  final double gridWidth;
  final double gridHeight;
  
  const GridConfiguration({
    required this.columns,
    required this.rows,
    required this.cardWidth,
    required this.cardHeight,
    required this.spacing,
    required this.gridWidth,
    required this.gridHeight,
  });
} 