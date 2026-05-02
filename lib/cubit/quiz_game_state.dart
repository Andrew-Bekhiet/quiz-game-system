import 'package:equatable/equatable.dart';
import 'package:quiz_app/models/player_data.dart';

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

final class QuizGameStateConnected extends QuizGameState {
  final List<PlayerData> players;
  final bool canRenamePlayers;

  @override
  List<Object?> get props => [players, canRenamePlayers];

  const QuizGameStateConnected({
    required this.players,
    required this.canRenamePlayers,
  });
}

final class QuizGameStatePlayerBuzzed extends QuizGameState {
  final int playerNumber;
  final List<PlayerData> players;

  @override
  List<Object?> get props => [playerNumber, players];

  const QuizGameStatePlayerBuzzed({
    required this.playerNumber,
    required this.players,
  });
}

final class QuizGameStateError extends QuizGameState {
  final String message;

  @override
  List<Object?> get props => [message];

  const QuizGameStateError({required this.message});
}
