import 'dart:async';

import 'database.dart';
import 'emailservice.dart';

class AlertService {
  static const double warningLevel = 70;
  static const double violationLevel = 75;

  static Timer? _timer;

  // 0 = normal
  // 1 = approaching limit
  // 2 = limit reached countdown
  static final Map<String, int> _alertStage = {};

  // prevent duplicate checks
  static final Map<String, bool> _processing = {};

  // prevent multiple 5 minute timers
  static final Map<String, bool> _violationTimers = {};

  //=========================================================
  // START ALERT ENGINE
  //=========================================================

  static void start(String deviceId) {
    _timer?.cancel();

    print("Alert engine started for $deviceId");

    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _checkNoise(deviceId);
    });
  }

  //=========================================================
  // CHECK NOISE
  //=========================================================

  static Future<void> _checkNoise(String deviceId) async {
    if (_processing[deviceId] == true) {
      return;
    }

    try {
      _processing[deviceId] = true;

      final noise = await Database.getLatestNoise(deviceId);

      if (noise == null) {
        return;
      }

      print("Noise $deviceId : $noise dBA");

      //=====================================================
      // NORMAL
      // BELOW 70
      //=====================================================

      if (noise < warningLevel) {
        if (_alertStage[deviceId] != 0) {
          await Database.saveNoiseEvent(
            deviceId: deviceId,

            noiseLevel: noise,

            type: "RESOLVED",

            message: "Noise returned to normal level.",
          );
        }

        _alertStage[deviceId] = 0;

        return;
      }

      final ownerEmail = await Database.getOwnerEmail(deviceId);

      //=====================================================
      // WARNING 1
      // 70 - 74
      //=====================================================

      if (noise >= warningLevel && noise < violationLevel) {
        if (_alertStage[deviceId] != 1) {
          _alertStage[deviceId] = 1;

          await Database.saveNoiseEvent(
            deviceId: deviceId,

            noiseLevel: noise,

            type: "WARNING_APPROACHING",

            message: "Noise approaching allowed limit.",
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

      //=====================================================
      // WARNING 2
      // 75+
      //=====================================================

      if (noise >= violationLevel) {
        if (_alertStage[deviceId] != 2) {
          _alertStage[deviceId] = 2;

          await Database.saveNoiseEvent(
            deviceId: deviceId,

            noiseLevel: noise,

            type: "LIMIT_REACHED",

            message:
                "Allowed noise limit reached. "
                "Five minute countdown started.",
          );

          // USER EMAIL

          if (ownerEmail != null && ownerEmail.isNotEmpty) {
            await EmailService.sendLimitReachedEmail(
              recipient: ownerEmail,

              noise: noise,
            );
          }

          // CONTROL CENTER EMAIL

          await EmailService.sendLimitReachedEmail(
            recipient: EmailService.controlCenterEmail,

            noise: noise,
          );

          // Start 5 minute timer once

          if (_violationTimers[deviceId] != true) {
            _violationTimers[deviceId] = true;

            await Future.delayed(const Duration(minutes: 5));

            await _checkViolation(deviceId);

            _violationTimers[deviceId] = false;
          }
        }
      }
    } catch (e) {
      print("Alert engine error: $e");
    } finally {
      _processing[deviceId] = false;
    }
  }

  //=========================================================
  // CHECK VIOLATION
  //=========================================================

  static Future<void> _checkViolation(String deviceId) async {
    final noise = await Database.getLatestNoise(deviceId);

    if (noise == null) {
      return;
    }

    if (noise >= violationLevel) {
      final ownerEmail = await Database.getOwnerEmail(deviceId);

      await Database.createViolation(deviceId: deviceId, measuredLevel: noise);

      await Database.saveNoiseEvent(
        deviceId: deviceId,

        noiseLevel: noise,

        type: "VIOLATION",

        message: "Noise pollution violation recorded.",
      );

      // USER

      if (ownerEmail != null && ownerEmail.isNotEmpty) {
        await EmailService.sendViolationEmail(
          recipient: ownerEmail,

          noise: noise,
        );
      }

      // CONTROL CENTER

      await EmailService.sendViolationEmail(
        recipient: EmailService.controlCenterEmail,

        noise: noise,
      );
    } else {
      await Database.saveNoiseEvent(
        deviceId: deviceId,

        noiseLevel: noise,

        type: "RESOLVED",

        message: "Noise reduced before violation.",
      );
    }

    _alertStage[deviceId] = 0;
  }

  //=========================================================
  // STOP
  //=========================================================

  static void stop() {
    _timer?.cancel();

    _timer = null;

    _alertStage.clear();

    _processing.clear();

    _violationTimers.clear();

    print("Alert engine stopped");
  }
}
