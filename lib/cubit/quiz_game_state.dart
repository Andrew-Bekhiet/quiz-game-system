import 'package:equatable/equatable.dart';

sealed class QuizGameState with EquatableMixin {
  const QuizGameState();
}

final class QuizGameStateDisconnected extends QuizGameState {
  final List<String> availablePorts;
  final String? selectedPort;

  @override
  List<Object?> get props => [availablePorts, selectedPort];

  const QuizGameStateDisconnected({
    this.selectedPort,
    this.availablePorts = const [],
  });
}

final class QuizGameStateConnecting extends QuizGameState {
  @override
  List<Object?> get props => [];

  const QuizGameStateConnecting();
}

final class QuizGameStateWaiting extends QuizGameState {
  final List<int> playerScores;

  @override
  List<Object?> get props => [playerScores];

  const QuizGameStateWaiting({required this.playerScores});
}

final class QuizGameStatePlayerBuzzed extends QuizGameState {
  final int playerNumber;
  final List<int> playerScores;

  @override
  List<Object?> get props => [playerNumber, playerScores];

  const QuizGameStatePlayerBuzzed({
    required this.playerNumber,
    required this.playerScores,
  });
}

final class QuizGameStateError extends QuizGameState {
  final String message;

  @override
  List<Object?> get props => [message];

  const QuizGameStateError({required this.message});
}
