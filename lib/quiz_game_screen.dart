import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/cubit/quiz_game_cubit.dart';
import 'package:quiz_app/cubit/quiz_game_state.dart';
import 'package:quiz_app/quiz/quiz_game_colors.dart';
import 'package:quiz_app/quiz/widgets/connecting_body.dart';
import 'package:quiz_app/quiz/widgets/disconnected_body.dart';
import 'package:quiz_app/quiz/widgets/error_body.dart';
import 'package:quiz_app/quiz/widgets/live_game_body.dart';
import 'package:quiz_app/quiz/widgets/player_buzzed_body.dart';

class QuizGameScreen extends StatefulWidget {
  const QuizGameScreen({super.key});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<QuizGameCubit, QuizGameState>(
      builder: (context, state) {
        final cubit = context.read<QuizGameCubit>();

        return Scaffold(
          backgroundColor: quizBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        color: theme.colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Quiz buzzer',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      if (state is QuizGameStateConnected ||
                          state is QuizGameStatePlayerBuzzed)
                        TextButton.icon(
                          onPressed: cubit.disconnect,
                          icon: const Icon(
                            Icons.link_off,
                            color: Colors.white70,
                          ),
                          label: const Text(
                            'Disconnect',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF143D29),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(
                              0xFF2ECC71,
                            ).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2ECC71),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Live',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: const Color(0xFFAAF0C4),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mirrors signals from your Arduino quiz rig: buzzers print the winner over serial; reset notifies the desk.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: switch (state) {
                      QuizGameStateDisconnected(
                        :final availablePorts,
                        :final selectedPort,
                      ) =>
                        DisconnectedBody(
                          ports: availablePorts,
                          selectedPort: selectedPort,
                          onPortChanged: cubit.selectPort,
                          onRefresh: cubit.refreshPorts,
                          onConnect: selectedPort == null
                              ? null
                              : () => cubit.connect(selectedPort),
                        ),
                      QuizGameStateConnecting() => const ConnectingBody(),
                      QuizGameStateConnected(
                        :final canRenamePlayers,
                        :final players,
                      ) =>
                        LiveGameBody(
                          canRenamePlayers: canRenamePlayers,
                          players: players,
                          onResetScore: cubit.resetScore,
                          onPlayerNameChanged: cubit.setPlayerName,
                        ),
                      QuizGameStatePlayerBuzzed(
                        :final playerNumber,
                        :final players,
                      ) =>
                        PlayerBuzzedBody(
                          onResetScore: cubit.resetScore,
                          onCorrect: cubit.hostMarkCorrect,
                          onWrong: cubit.hostMarkWrong,
                          playerNumber: playerNumber,
                          players: players,
                        ),
                      QuizGameStateError(:final message) => ErrorBody(
                        message: message,
                        onRetry: cubit.disconnect,
                      ),
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
