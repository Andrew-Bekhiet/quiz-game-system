import 'package:flutter/material.dart';
import 'package:quiz_app/models/player_data.dart';
import 'package:quiz_app/quiz/widgets/player_panel.dart';
import 'package:quiz_app/quiz/widgets/quiz_action_button.dart';

class PlayerBuzzedBody extends StatelessWidget {
  final VoidCallback onResetScore;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;
  final int playerNumber;
  final List<PlayerData> players;

  const PlayerBuzzedBody({
    required this.playerNumber,
    required this.players,
    required this.onResetScore,
    required this.onCorrect,
    required this.onWrong,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final player = players[playerNumber - 1];
    final color = player.color;

    return Column(
      children: [
        Icon(
          Icons.emoji_events_rounded,
          size: 88,
          color: color,
        ),
        const SizedBox(height: 20),
        Text(
          player.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        Text(
          'BUZZED IN FIRST',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            spacing: 16,
            children: [
              Expanded(
                child: PlayerPanel(
                  player: players.first,
                  active: playerNumber == 1,
                  onCorrect: onCorrect,
                  onWrong: onWrong,
                ),
              ),
              Expanded(
                child: PlayerPanel(
                  player: players[1],
                  active: playerNumber == 2,
                  onCorrect: onCorrect,
                  onWrong: onWrong,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: QuizActionButton(
            onPressed: onResetScore,
            icon: Icons.restart_alt,
            label: 'Reset Score',
          ),
        ),
        Text(
          'Reset on the Arduino clears the lamps and notifies this screen.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}
