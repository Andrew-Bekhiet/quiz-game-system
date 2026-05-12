import 'dart:async';
import 'dart:io';

import 'package:quiz_app/models/arduino_response.dart';
import 'package:quiz_app/repository/arduino_repository.dart';
import 'package:rxdart/rxdart.dart';

class FileInputArduinoRepository implements ArduinoRepository {
  StreamSubscription<String>? _readerSubscription;
  final _responseController = StreamController<ArduinoResponse>.broadcast();

  @override
  Stream<ArduinoResponse> get responses => _responseController.stream;

  @override
  Future<List<String>> getAvailablePorts() {
    return Directory.current
        .list()
        .whereType<File>()
        .where((file) => !file.uri.pathSegments.last.startsWith('.'))
        .map((file) => file.uri.pathSegments.last)
        .toList();
  }

  @override
  Future<bool> connect(String portName) async {
    final file = File(portName);
    if (!file.existsSync()) {
      throw Exception('File not found: $portName');
    }

    _readerSubscription = file
        .watch()
        .asyncMap((_) => file.readAsLines())
        .scan<(int, List<String>)>(
          (acc, currentLines, _) {
            final previousLinesCount = acc.$1;
            final newLines = currentLines.sublist(previousLinesCount);

            return (currentLines.length, newLines);
          },
          (0, []),
        )
        .expand((tuple) => tuple.$2)
        .listen(_handleData, onError: _handleError, onDone: disconnect);

    return Future.value(true);
  }

  @override
  Future<void> reset() async {}

  void _handleData(String data) {
    _responseController.add(ArduinoResponse.fromLine(data));
  }

  void _handleError(Object error) {
    _responseController.add(ErrorResponse(error.toString()));
  }

  @override
  Future<void> disconnect() async {
    await _readerSubscription?.cancel();
  }

  @override
  Future<void> dispose() async {
    await _responseController.close();
    await disconnect();
  }
}
