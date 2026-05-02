import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/arduino_repository.dart';
import 'package:quiz_app/arduino_response.dart';
import 'package:quiz_app/cubit/quiz_game_state.dart';

class QuizGameCubit extends Cubit<QuizGameState> {
  static const playersCount = 2;

  List<int> playerScores = List.filled(playersCount, 0);

  final ArduinoRepository _arduinoRepo;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<ArduinoResponse>? _responseSubscription;

  QuizGameCubit(this._arduinoRepo) : super(const QuizGameStateDisconnected()) {
    _init();
  }

  Future<void> _init([bool connectNow = true]) async {
    await _initArduinoRepo(connectNow);
    await _cacheAudio();
  }

  Future<void> _initArduinoRepo(bool connectNow) async {
    final ports = await _arduinoRepo.getAvailablePorts();

    if (connectNow && ports.length == 1) {
      await connect(ports.single);
    } else {
      emit(QuizGameStateDisconnected(availablePorts: ports));
    }
  }

  Future<void> _cacheAudio() async {
    await _audioPlayer.setSource(AssetSource('buzzer.wav'));
    await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
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

      emit(QuizGameStateWaiting(playerScores: playerScores));
    } else {
      final ports = await _arduinoRepo.getAvailablePorts();
      emit(QuizGameStateDisconnected(availablePorts: ports));
    }
  }

  void resetCounter() {
    playerScores = List.filled(playersCount, 0);

    if (state is QuizGameStateWaiting) {
      emit(QuizGameStateWaiting(playerScores: playerScores));
    } else if (state case QuizGameStatePlayerBuzzed(:final playerNumber)) {
      emit(
        QuizGameStatePlayerBuzzed(
          playerNumber: playerNumber,
          playerScores: playerScores,
        ),
      );
    }
  }

  Future<void> _handleResponse(ArduinoResponse response) async {
    switch (response) {
      case ResetResponse():
        emit(QuizGameStateWaiting(playerScores: playerScores));

      case PlayerBuzzedResponse(:final playerNumber):
        playerScores = playerScores
            .mapIndexed(
              (index, score) => index + 1 == playerNumber ? score + 1 : score,
            )
            .toList();
        _playBuzzerSound();
        emit(
          QuizGameStatePlayerBuzzed(
            playerScores: playerScores,
            playerNumber: playerNumber,
          ),
        );

      case ErrorResponse(:final message):
        emit(QuizGameStateError(message: message));
    }
  }

  void _playBuzzerSound() {
    _audioPlayer.resume();
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
