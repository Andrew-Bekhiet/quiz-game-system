import 'package:equatable/equatable.dart';

sealed class QuizGameState with EquatableMixin {
  const QuizGameState();
}

final class QuizGameStateDisconnected extends QuizGameState {
  final List<String> availablePorts;

  @override
  List<Object?> get props => [availablePorts];

  const QuizGameStateDisconnected({this.availablePorts = const []});
}

final class QuizGameStateConnecting extends QuizGameState {
  @override
  List<Object?> get props => [];

  const QuizGameStateConnecting();
}

final class QuizGameStateWaiting extends QuizGameState {
  @override
  List<Object?> get props => [];

  const QuizGameStateWaiting();
}

final class QuizGameStatePlayerWon extends QuizGameState {
  final int playerNumber;

  @override
  List<Object?> get props => [playerNumber];

  const QuizGameStatePlayerWon({required this.playerNumber});
}

final class QuizGameStateError extends QuizGameState {
  final String message;

  @override
  List<Object?> get props => [message];

  const QuizGameStateError({required this.message});
}
