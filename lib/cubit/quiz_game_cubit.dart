import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/arduino_repository.dart';
import 'package:quiz_app/arduino_response.dart';
import 'package:quiz_app/cubit/quiz_game_state.dart';

class QuizGameCubit extends Cubit<QuizGameState> {
  final ArduinoRepository _arduinoRepo;
  StreamSubscription<ArduinoResponse>? _responseSubscription;

  QuizGameCubit(this._arduinoRepo) : super(const QuizGameStateDisconnected()) {
    _init(false);
  }

  Future<void> _init([bool connectNow = true]) async {
    final ports = await _arduinoRepo.getAvailablePorts();

    if (connectNow && ports.length == 1) {
      await connect(ports.single);
    } else {
      emit(QuizGameStateDisconnected(availablePorts: ports));
    }
  }

  Future<void> connect(String portName) async {
    emit(const QuizGameStateConnecting());

    final success = await _arduinoRepo.connect(portName);
    if (success) {
      _responseSubscription = _arduinoRepo.responses.listen(_handleResponse);

      emit(const QuizGameStateWaiting());
    } else {
      final ports = await _arduinoRepo.getAvailablePorts();
      emit(QuizGameStateDisconnected(availablePorts: ports));
    }
  }

  Future<void> _handleResponse(ArduinoResponse response) async {
    switch (response) {
      case ResetResponse():
        emit(const QuizGameStateWaiting());

      case PlayerWonResponse(:final playerNumber):
        emit(QuizGameStatePlayerWon(playerNumber: playerNumber));

      case ErrorResponse(:final message):
        emit(QuizGameStateError(message: message));
    }
  }

  @override
  Future<void> close() async {
    await _responseSubscription?.cancel();
    await _arduinoRepo.dispose();
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
