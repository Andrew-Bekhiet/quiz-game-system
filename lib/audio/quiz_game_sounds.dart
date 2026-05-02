import 'package:audioplayers/audioplayers.dart';

abstract interface class QuizGameSounds {
  Future<void> init();

  Future<void> playBuzzer();

  Future<void> playCorrect();

  Future<void> playWrong();

  Future<void> dispose();
}

final class AudioplayersQuizGameSounds implements QuizGameSounds {
  final AudioPlayer _buzzerPlayer = AudioPlayer();
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer = AudioPlayer();
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;

    await _setupPlayer(_buzzerPlayer, 'buzzer.wav');
    await _setupPlayer(_correctPlayer, 'correct.mp3');
    await _setupPlayer(_wrongPlayer, 'wrong.wav');

    _initialized = true;
  }

  Future<void> _setupPlayer(AudioPlayer player, String assetPath) async {
    await player.setSource(AssetSource(assetPath));
    await player.setPlayerMode(PlayerMode.lowLatency);
    await player.setReleaseMode(ReleaseMode.stop);
  }

  @override
  Future<void> playBuzzer() => _buzzerPlayer.resume();

  @override
  Future<void> playCorrect() async => _correctPlayer.resume();

  @override
  Future<void> playWrong() async => _wrongPlayer.resume();

  @override
  Future<void> dispose() => _buzzerPlayer.dispose();
}
