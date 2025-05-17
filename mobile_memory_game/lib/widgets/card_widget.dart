import 'package:flutter/material.dart';

class CardWidget extends StatefulWidget {
  // ... (existing code)
}

class _CardWidgetState extends State<CardWidget> {
  // ... (existing code)

  Widget _buildCardBack(BuildContext context) {
    // Usa a imagem de verso do tema
    return Container(
      decoration: BoxDecoration(
        color: _theme.primaryColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _theme.secondaryColor,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          _theme.cardBackImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback para o símbolo "?" se a imagem não for encontrada
            return Center(
              child: Icon(
                Icons.help_outline,
                size: 56,
                color: _theme.secondaryColor,
              ),
            );
          },
        ),
      ),
    );
  }

  // ... (rest of the existing code)
} 