sealed class ArduinoResponse {
  const ArduinoResponse();

  factory ArduinoResponse.fromLine(String line) {
    switch (line) {
      case 'r':
        return const ResetBuzzerResponse();

      case final n when int.tryParse(n) != null:
        return PlayerBuzzedResponse(int.parse(n));

      default:
        return ErrorResponse('Unknown response: $line');
    }
  }
}

final class ResetBuzzerResponse extends ArduinoResponse {
  const ResetBuzzerResponse();
}

final class PlayerBuzzedResponse extends ArduinoResponse {
  final int playerNumber;

  const PlayerBuzzedResponse(this.playerNumber);
}

final class ErrorResponse extends ArduinoResponse {
  final String message;

  const ErrorResponse(this.message);
}
