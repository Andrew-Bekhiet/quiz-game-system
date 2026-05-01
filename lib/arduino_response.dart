sealed class ArduinoResponse {
  const ArduinoResponse();
}

final class ResetResponse extends ArduinoResponse {
  const ResetResponse();
}

final class PlayerWonResponse extends ArduinoResponse {
  final int playerNumber;

  const PlayerWonResponse(this.playerNumber);
}

final class ErrorResponse extends ArduinoResponse {
  final String message;

  const ErrorResponse(this.message);
}
