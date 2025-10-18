import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialScannerService {
  final _controller = StreamController<String>.broadcast();
  Stream<String> get codes => _controller.stream;

  SerialPort? _port;
  SerialPortReader? _reader;
  SerialPortConfig? _cfg;
  final StringBuffer _buf = StringBuffer();

  Future<bool> start({String? address, int baud = 9600}) async {
    try {
      // 1) List ports with details (copy from console when choosing a port)
      final ports = SerialPort.availablePorts;
      debugPrint('PORTS: $ports');
      for (final a in ports) {
        final p = SerialPort(a);
        debugPrint(
          'PORT INFO: "$a" '
          'transport=${p.transport} '
          'manufacturer=${p.manufacturer} '
          'productName=${p.productName} '
          'serialNumber=${p.serialNumber} '
          'vendorId=${p.vendorId} productId=${p.productId}',
        );
        p.dispose();
      }

      // 2) Choose port: explicit or first USB/native as fallback
      final chosen = address ??
          ports.firstWhere(
            (a) {
              final p = SerialPort(a);
              final ok = p.transport == SerialPortTransport.usb || p.transport == SerialPortTransport.native;
              p.dispose();
              return ok;
            },
            orElse: () => ports.isNotEmpty ? ports.first : '',
          );

      if (chosen.isEmpty) {
        debugPrint('NO SERIAL PORT FOUND');
        return false;
      }

      // 3) Open and configure every parameter explicitly (incl. RTS/DTR)
      _port = SerialPort(chosen);
      final opened = _port!.openReadWrite();
      debugPrint('OPENED: $chosen -> $opened');
      if (!opened) {
        debugPrint('OPEN FAILED: ${SerialPort.lastError}');
        _port?.dispose();
        _port = null;
        return false;
      }

      _cfg = SerialPortConfig()
        ..baudRate = baud
        ..bits = 8
        ..parity = SerialPortParity.none
        ..stopBits = 1
        ..xonXoff = 0
        ..rts = 1   // important for some scanners
        ..cts = 0
        ..dsr = 0
        ..dtr = 1   // important for some scanners
        ..setFlowControl(SerialPortFlowControl.none);
      _port!.config = _cfg!;

      // 4) Stream reader
      _reader = SerialPortReader(_port!, timeout: 50);
      _reader!.stream.listen(
        (Uint8List data) {
          final chunk = ascii.decode(data, allowInvalid: true);
          debugPrint('CHUNK: "$chunk" [${data.length} bytes]');
          for (final ch in chunk.split('')) {
            if (ch == '\r' || ch == '\n') {
              final code = _buf.toString().trim();
              if (code.isNotEmpty) {
                debugPrint('COMMIT: "$code"');
                _controller.add(code);
              }
              _buf.clear();
            } else {
              _buf.write(ch);
            }
          }
        },
        onError: (e, st) {
          debugPrint('SERIAL ERROR: $e');
        },
        onDone: () {
          debugPrint('SERIAL DONE');
        },
        cancelOnError: false,
      );

      debugPrint('SERIAL STARTED on $chosen @ $baud');
      return true;
    } catch (e) {
      debugPrint('START EXCEPTION: $e');
      await stop();
      return false;
    }
  }

  Future<void> stop() async {
    try {
      _reader?.close();
    } catch (_) {}
    _reader = null;
    try {
      _port?.close();
    } catch (_) {}
    try {
      _port?.dispose();
    } catch (_) {}
    _port = null;
    try {
      _cfg?.dispose();
    } catch (_) {}
    _cfg = null;
    debugPrint('SERIAL STOPPED');
  }

  void dispose() {
    stop();
    _controller.close();
  }
}
