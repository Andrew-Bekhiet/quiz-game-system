import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:quiz_app/models/arduino_response.dart';

class ArduinoRepository {
  SerialPort? _port;
  SerialPortReader? _portReader;
  StreamSubscription<Uint8List>? _readerSubscription;
  final _responseController = StreamController<ArduinoResponse>.broadcast();
  String _buffer = '';

  void _log(String message) {
    developer.log(message, name: '$ArduinoRepository');
  }

  Stream<ArduinoResponse> get responses => _responseController.stream;

  Future<List<String>> getAvailablePorts() async {
    return SerialPort.availablePorts;
  }

  Future<bool> connect(String portName) async {
    try {
      final port = SerialPort(portName);
      _port = port;

      final opened = port.openRead();

      if (!opened) {
        _log('Failed to open port: ${SerialPort.lastError}');

        return false;
      }

      port.config = SerialPortConfig()
        ..baudRate = 9600
        ..bits = 8
        ..stopBits = 1
        ..parity = SerialPortParity.none
        ..dtr = SerialPortDtr.on
        ..rts = SerialPortRts.on;

      _log('Port opened successfully: $portName');

      _portReader = SerialPortReader(port);
      _readerSubscription = _portReader?.stream.listen(
        _handleData,
        onError: (error) {
          _log('Stream error: $error');
          _responseController.add(ErrorResponse('Serial error: $error'));
        },
        onDone: () {
          _log('Stream closed');
        },
      );

      return true;
    } catch (e) {
      _log('Connection error: $e');

      return false;
    }
  }

  void _handleData(Uint8List data) {
    final text = utf8.decode(data);
    _buffer += text;

    final lines = _buffer.split('\n');
    _buffer = lines.last;

    for (var i = 0; i < lines.length - 1; i++) {
      final line = lines[i].trim();
      if (line.isNotEmpty) {
        _log('Parsing line: $line');

        _responseController.add(ArduinoResponse.fromLine(line));
      }
    }
  }

  Future<void> disconnect() async {
    await _readerSubscription?.cancel();
    _portReader?.close();
    _port?.close();
    _port?.dispose();
    _port = null;
  }

  Future<void> dispose() async {
    await _responseController.close();
    await disconnect();
  }
}
