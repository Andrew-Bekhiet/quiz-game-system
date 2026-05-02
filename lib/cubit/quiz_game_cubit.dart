import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/audio/quiz_game_sounds.dart';
import 'package:quiz_app/cubit/quiz_game_state.dart';
import 'package:quiz_app/models/arduino_response.dart';
import 'package:quiz_app/models/player_data.dart';
import 'package:quiz_app/repository/arduino_repository.dart';

class QuizGameCubit extends Cubit<QuizGameState> {
  List<PlayerData> _players = [
    const PlayerData(name: 'Player 1', score: 0, color: Colors.redAccent),
    const PlayerData(name: 'Player 2', score: 0, color: Colors.blueAccent),
  ];

  final ArduinoRepository _arduinoRepo;
  final QuizGameSounds _sounds;
  StreamSubscription<ArduinoResponse>? _responseSubscription;

  QuizGameCubit(this._arduinoRepo, this._sounds)
    : super(const QuizGameStateDisconnected()) {
    _init();
  }

  Future<void> _init([bool connectNow = true]) async {
    await _initArduinoRepo(connectNow);
    await _sounds.init();
  }

  Future<void> _initArduinoRepo(bool connectNow) async {
    final ports = await _arduinoRepo.getAvailablePorts();

    if (connectNow && ports.length == 1) {
      await connect(ports.single);
    } else {
      emit(QuizGameStateDisconnected(availablePorts: ports));
    }
  }

  void selectPort(String portName) {
    final state = this.state;
    if (state is! QuizGameStateDisconnected) return;

    emit(
      QuizGameStateDisconnected(
        availablePorts: state.availablePorts,
        selectedPort: portName,
      ),
    );
  }

  Future<void> connect(String portName) async {
    emit(const QuizGameStateConnecting());

    final success = await _arduinoRepo.connect(portName);
    if (success) {
      _responseSubscription = _arduinoRepo.responses.listen(_handleResponse);

      emit(QuizGameStateConnected(players: _players, canRenamePlayers: true));
    } else {
      final ports = await _arduinoRepo.getAvailablePorts();
      emit(QuizGameStateDisconnected(availablePorts: ports));
    }
  }

  void resetScore() {
    _players = _players
        .map((player) => player.copyWith(score: 0))
        .toList(growable: false);

    if (state is QuizGameStateConnected) {
      emit(QuizGameStateConnected(players: _players, canRenamePlayers: true));
    } else if (state case QuizGameStatePlayerBuzzed(:final playerNumber)) {
      emit(
        QuizGameStatePlayerBuzzed(
          playerNumber: playerNumber,
          players: _players,
        ),
      );
    }
  }

  void setPlayerName(int playerIndex, String name) {
    final canRenamePlayers = _players.every((player) => player.score == 0);
    if (!canRenamePlayers ||
        playerIndex < 0 ||
        playerIndex >= _players.length) {
      return;
    }

    if (_players[playerIndex].name == name) return;

    _players = _players
        .mapIndexed(
          (index, player) =>
              index == playerIndex ? player.copyWith(name: name) : player,
        )
        .toList(growable: false);

    if (state case QuizGameStateConnected(:final canRenamePlayers)) {
      emit(
        QuizGameStateConnected(
          players: _players,
          canRenamePlayers: canRenamePlayers,
        ),
      );
    }
  }

  Future<void> hostMarkCorrect() async {
    final state = this.state;
    if (state is! QuizGameStatePlayerBuzzed) return;

    final playerIndex = state.playerNumber - 1;
    if (playerIndex < 0 || playerIndex >= _players.length) return;

    _players = _players
        .mapIndexed(
          (index, player) => index == playerIndex
              ? player.copyWith(score: player.score + 1)
              : player,
        )
        .toList(growable: false);

    await _sounds.playCorrect();
    emit(QuizGameStateConnected(players: _players, canRenamePlayers: false));
  }

  Future<void> hostMarkWrong() async {
    if (state is! QuizGameStatePlayerBuzzed) return;

    await _sounds.playWrong();
    emit(QuizGameStateConnected(players: _players, canRenamePlayers: false));
  }

  void _handleResponse(ArduinoResponse response) {
    switch (response) {
      case ResetBuzzerResponse():
        emit(
          QuizGameStateConnected(players: _players, canRenamePlayers: false),
        );

      case PlayerBuzzedResponse(:final playerNumber):
        _sounds.playBuzzer();
        emit(
          QuizGameStatePlayerBuzzed(
            players: _players,
            playerNumber: playerNumber,
          ),
        );

      case ErrorResponse(:final message):
        emit(QuizGameStateError(message: message));
    }
  }

  @override
  Future<void> close() async {
    await _responseSubscription?.cancel();
    await _arduinoRepo.dispose();
    await _sounds.dispose();
    await super.close();
  }

  Future<void> disconnect() async {
    await _arduinoRepo.disconnect();
    await _init(false);
  }

  /// Rescan serial ports while disconnected (e.g. after plugging in the Arduino).
  Future<void> refreshPorts() async {
    final ports = await _arduinoRepo.getAvailablePorts();
    emit(QuizGameStateDisconnected(availablePorts: ports));
  }
}
