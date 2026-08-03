import 'dart:async';

import 'database.dart';
import 'emailservice.dart';

class AlertEngine {
  static const double warningLevel = 70;
  static const double violationLevel = 75;

  static Timer? _timer;

  static final Map<String, int> _stage = {};

  static void start(String deviceId) {
    _timer?.cancel();

    print("Alert Engine Started: $deviceId");

    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await check(deviceId);
    });
  }

  static Future<void> check(String deviceId) async {
    try {
      final noise = await Database.getLatestNoise(deviceId);

      if (noise == null) {
        print("No noise data found");
        return;
      }

      print("Checking noise: $noise dBA");

      final ownerEmail = await Database.getOwnerEmail(deviceId);

      // NORMAL

      if (noise < warningLevel) {
        _stage[deviceId] = 0;

        return;
      }

      // WARNING

      if (noise >= warningLevel && noise < violationLevel) {
        if (_stage[deviceId] != 1) {
          _stage[deviceId] = 1;

          await Database.saveNoiseEvent(
            deviceId: deviceId,
            noiseLevel: noise,
            type: "WARNING",
            message: "Noise approaching limit",
          );

          if (ownerEmail != null && ownerEmail.isNotEmpty) {
            await EmailService.sendApproachingLimitEmail(
              recipient: ownerEmail,
              noise: noise,
            );
          }
        }

        return;
      }

      // VIOLATION LEVEL

      if (noise >= violationLevel) {
        if (_stage[deviceId] != 2) {
          _stage[deviceId] = 2;

          await Database.saveNoiseEvent(
            deviceId: deviceId,
            noiseLevel: noise,
            type: "LIMIT_REACHED",
            message: "Noise limit reached",
          );

          if (ownerEmail != null && ownerEmail.isNotEmpty) {
            await EmailService.sendLimitReachedEmail(
              recipient: ownerEmail,
              noise: noise,
            );
          }
        }
      }
    } catch (e) {
      print("Alert Engine Error: $e");
    }
  }

  static void stop() {
    _timer?.cancel();

    _timer = null;

    _stage.clear();

    print("Alert Engine Stopped");
  }
}
