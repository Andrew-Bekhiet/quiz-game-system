import 'package:flutter/material.dart';
import 'package:quiz_app/models/player_data.dart';
import 'package:quiz_app/quiz/quiz_game_colors.dart';
import 'package:quiz_app/quiz/widgets/player_panel.dart';
import 'package:quiz_app/quiz/widgets/quiz_action_button.dart';

class LiveGameBody extends StatelessWidget {
  final List<PlayerData> players;
  final VoidCallback onResetScore;
  final void Function(int playerIndex, String name) onPlayerNameChanged;
  final bool canRenamePlayers;

  const LiveGameBody({
    required this.players,
    required this.onResetScore,
    required this.onPlayerNameChanged,
    required this.canRenamePlayers,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _PlayerColumn(
                  player: players.first,
                  playerIndex: 0,
                  lit: true,
                  onNameChanged: canRenamePlayers ? onPlayerNameChanged : null,
                ),
              ),
              Expanded(
                child: _PlayerColumn(
                  player: players[1],
                  playerIndex: 1,
                  lit: true,
                  onNameChanged: canRenamePlayers ? onPlayerNameChanged : null,
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
            label: 'Reset Counter',
          ),
        ),
        Text(
          'Press the hardware RESET on the Arduino to start another round.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _PlayerColumn extends StatelessWidget {
  final PlayerData player;
  final int playerIndex;
  final bool lit;
  final void Function(int playerIndex, String name)? onNameChanged;

  const _PlayerColumn({
    required this.player,
    required this.playerIndex,
    required this.lit,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onNameChanged case final onNameChanged?)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              initialValue: player.name,
              textInputAction: TextInputAction.done,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Player ${playerIndex + 1} name',
                labelStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.edit, color: Colors.white54),
                filled: true,
                fillColor: quizInputColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (name) => onNameChanged(playerIndex, name),
            ),
          ),
        Expanded(
          child: PlayerPanel(
            player: player,
            active: lit,
          ),
        ),
      ],
    );
  }
}
