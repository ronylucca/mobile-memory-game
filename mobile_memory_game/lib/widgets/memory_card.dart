import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:mobile_memory_game/models/card_model.dart';
import 'package:mobile_memory_game/models/theme_model.dart';
import 'package:mobile_memory_game/utils/audio_manager.dart';
import 'package:mobile_memory_game/providers/game_provider.dart';
import 'package:provider/provider.dart';

class MemoryCard extends StatefulWidget {
  final CardModel card;
  final ThemeModel theme;
  final Function(int) onCardTap;
  final int index;
  final GlobalKey<FlipCardState>? flipCardKey;
  final Size? cardSize;

  const MemoryCard({
    super.key,
    required this.card,
    required this.theme,
    required this.onCardTap,
    required this.index,
    this.flipCardKey,
    this.cardSize,
  });

  @override
  State<MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<MemoryCard> {
  final AudioManager _audioManager = AudioManager();
  late GlobalKey<FlipCardState> _flipCardKey;

  @override
  void initState() {
    super.initState();
    _flipCardKey = widget.flipCardKey ?? GlobalKey<FlipCardState>();
  }

  @override
  void didUpdateWidget(MemoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Se a propriedade isFlipped mudar, atualize o estado visual da carta
    if (oldWidget.card.isFlipped != widget.card.isFlipped) {
      if (widget.card.isFlipped) {
        _flipCardKey.currentState?.toggleCard();
      } else if (!widget.card.isFlipped) {
        // Se a carta já estiver virada e isFlipped mudar para false, vire-a de volta
        if (_flipCardKey.currentState?.isFront == false) {
          _flipCardKey.currentState?.toggleCard();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtém o estado global para saber se estamos usando ícones
    final useIcons = context.select<GameProvider, bool>((provider) => provider.useIcons);
    
    Widget cardWidget = FlipCard(
      key: _flipCardKey,
      speed: 400,
      direction: FlipDirection.HORIZONTAL,
      flipOnTouch: false,
      front: _buildCardFront(),
      back: _buildCardBack(useIcons),
    );
    
    // Se um tamanho específico foi fornecido, use-o
    if (widget.cardSize != null) {
      cardWidget = SizedBox(
        width: widget.cardSize!.width,
        height: widget.cardSize!.height,
        child: cardWidget,
      );
    }
    
    return GestureDetector(
      onTap: () {
        if (!widget.card.isFlipped && !widget.card.isMatched) {
          widget.onCardTap(widget.index);
          _audioManager.playThemeSound('card_flip');
        }
      },
      child: cardWidget,
    );
  }

  Widget _buildCardFront() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            offset: const Offset(2, 2),
          ),
        ],
        color: const Color(0xFF303030),
        border: Border.all(
          color: widget.card.isMatched 
              ? Colors.green.shade300 
              : widget.theme.primaryColor,
          width: widget.card.isMatched ? 2.0 : 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Center(
          child: Image.asset(
            widget.theme.cardBackImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback para o símbolo "?" se a imagem não for encontrada
              return Icon(
                Icons.question_mark,
                size: 40,
                color: widget.theme.primaryColor,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(bool useIcons) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            offset: const Offset(2, 2),
          ),
        ],
        color: Colors.white,
        border: Border.all(
          color: widget.card.isMatched 
              ? Colors.green.shade300 
              : widget.theme.secondaryColor,
          width: widget.card.isMatched ? 2.0 : 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: useIcons 
                ? _getIconForPairId(widget.card.pairId)  // Usa ícones se as imagens não estiverem disponíveis
                : Image.asset(
                    widget.card.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback se a imagem falhar ao carregar
                      return _getIconForPairId(widget.card.pairId);
                    },
                  ),
          ),
        ),
      ),
    );
  }
  
  Widget _getIconForPairId(int pairId) {
    final icons = [
      Icons.favorite,
      Icons.star,
      Icons.emoji_emotions,
      Icons.pets,
      Icons.flight,
      Icons.beach_access,
      Icons.cake,
      Icons.directions_bike,
      Icons.music_note,
      Icons.emoji_nature,
    ];
    
    final iconIndex = (pairId - 1) % icons.length;
    
    return Icon(
      icons[iconIndex],
      size: 40,
      color: widget.theme.primaryColor,
    );
  }
} 