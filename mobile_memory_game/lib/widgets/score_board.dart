import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/player_model.dart';
import 'package:mobile_memory_game/models/theme_model.dart';

class ScoreBoard extends StatelessWidget {
  final List<PlayerModel> players;
  final ThemeModel theme;
  final int currentPlayerIndex;
  final bool isCompact;

  const ScoreBoard({
    super.key,
    required this.players,
    required this.theme,
    required this.currentPlayerIndex,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final verticalPadding = isCompact ? 8.0 : 12.0;
    final horizontalPadding = isCompact ? 12.0 : 16.0;
    final spacingWidth = isCompact ? 12.0 : 16.0;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPlayerScore(players[0], isCurrentPlayer: currentPlayerIndex == 0),
            SizedBox(width: spacingWidth),
            _buildPlayerScore(players[1], isCurrentPlayer: currentPlayerIndex == 1),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerScore(PlayerModel player, {required bool isCurrentPlayer}) {
    final nameFontSize = isCompact ? 14.0 : 16.0;
    final scoreFontSize = isCompact ? 18.0 : 20.0;
    final turnFontSize = isCompact ? 10.0 : 12.0;
    final iconSize = isCompact ? 18.0 : 20.0;
    final verticalPadding = isCompact ? 6.0 : 8.0;
    final horizontalPadding = isCompact ? 8.0 : 12.0;
    final spacingHeight = isCompact ? 4.0 : 8.0;
    
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentPlayer
              ? theme.primaryColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentPlayer ? theme.primaryColor : Colors.grey.shade300,
            width: isCurrentPlayer ? 2.0 : 1.0,
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
        child: Column(
          children: [
            Text(
              player.name,
              style: TextStyle(
                fontSize: nameFontSize,
                fontWeight: FontWeight.bold,
                color: isCurrentPlayer ? theme.primaryColor : Colors.black87,
              ),
            ),
            SizedBox(height: spacingHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: isCurrentPlayer ? theme.primaryColor : Colors.amber,
                  size: iconSize,
                ),
                const SizedBox(width: 4),
                Text(
                  player.score.toString(),
                  style: TextStyle(
                    fontSize: scoreFontSize,
                    fontWeight: FontWeight.bold,
                    color: isCurrentPlayer ? theme.primaryColor : Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 2 : 4),
            if (isCurrentPlayer)
              Text(
                'Sua vez!',
                style: TextStyle(
                  fontSize: turnFontSize,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
} 