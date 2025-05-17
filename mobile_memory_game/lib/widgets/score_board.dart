import 'package:flutter/material.dart';
import 'package:mobile_memory_game/models/player_model.dart';
import 'package:mobile_memory_game/models/theme_model.dart';

class ScoreBoard extends StatelessWidget {
  final List<PlayerModel> players;
  final ThemeModel theme;
  final int currentPlayerIndex;

  const ScoreBoard({
    super.key,
    required this.players,
    required this.theme,
    required this.currentPlayerIndex,
  });

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPlayerScore(players[0], isCurrentPlayer: currentPlayerIndex == 0),
            const SizedBox(width: 16),
            _buildPlayerScore(players[1], isCurrentPlayer: currentPlayerIndex == 1),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerScore(PlayerModel player, {required bool isCurrentPlayer}) {
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
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          children: [
            Text(
              player.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCurrentPlayer ? theme.primaryColor : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: isCurrentPlayer ? theme.primaryColor : Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  player.score.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isCurrentPlayer ? theme.primaryColor : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (isCurrentPlayer)
              Text(
                'Sua vez!',
                style: TextStyle(
                  fontSize: 12,
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