import 'dart:async';
import 'package:flutter/services.dart';

class MicrophoneService {
  static const MethodChannel _channel = MethodChannel('sona.microphone');

  Function(double db)? onLevel;

  bool _running = false;

  Future<void> start() async {
    if (_running) return;

    _running = true;

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "noiseLevel":
          final level = double.tryParse(call.arguments.toString()) ?? -60;

          onLevel?.call(level);
          break;
      }
    });

    try {
      await _channel.invokeMethod("startMicrophone");
    } catch (e) {
      _running = false;
      throw Exception("Microphone start error: $e");
    }
  }

  Future<void> stop() async {
    if (!_running) return;

    try {
      await _channel.invokeMethod("stopMicrophone");
    } finally {
      _running = false;
    }
  }
}
