import 'package:flutter/material.dart';
import 'package:quiz_app/models/player_data.dart';
import 'package:quiz_app/quiz/widgets/quiz_action_button.dart';

class PlayerPanel extends StatelessWidget {
  final PlayerData player;
  final bool active;
  final VoidCallback? onCorrect;
  final VoidCallback? onWrong;

  const PlayerPanel({
    required this.player,
    required this.active,
    this.onCorrect,
    this.onWrong,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: active
            ? player.color.withValues(alpha: 0.18)
            : const Color(0xFF1A222C),
        border: Border.all(
          color: active ? player.color.withValues(alpha: 0.7) : Colors.white12,
          width: active ? 2 : 1,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: player.color.withValues(alpha: 0.35),
                  blurRadius: 24,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_rounded,
            size: 64,
            color: active ? player.color : Colors.white24,
          ),
          const SizedBox(height: 12),
          Text(
            player.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            player.score.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: active ? player.color : Colors.white38,
            ),
          ),
          if ((onCorrect, onWrong) case (
            final onCorrect?,
            final onWrong?,
          ) when active)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: [
                  QuizActionButton(
                    onPressed: onCorrect,
                    icon: Icons.check,
                    label: 'Correct',
                    isPrimary: true,
                  ),
                  QuizActionButton(
                    onPressed: onWrong,
                    icon: Icons.close,
                    label: 'Wrong',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
