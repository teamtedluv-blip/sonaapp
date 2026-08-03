import 'package:sona/database.dart';
import 'package:sona/current_device.dart';

enum EventType {
  spike,
  warning,
  limitReached,
  violation,
  resolved,
  calibration,
  system,
}

class NoiseEvent {
  final String deviceId;
  final String message;
  final double db;
  final DateTime time;
  final EventType type;
  final bool synced;

  NoiseEvent({
    required this.deviceId,
    required this.message,
    required this.db,
    required this.time,
    required this.type,
    required this.synced,
  });
}

class NoiseEventManager {
  static final List<NoiseEvent> _events = [];

  static List<NoiseEvent> get events => List.unmodifiable(_events);

  //=========================================================
  // ADD EVENT
  //=========================================================

  static Future<void> addEvent({
    required String message,

    required double db,

    required EventType type,
  }) async {
    final deviceId = CurrentDevice.deviceId;

    if (deviceId == null || deviceId.isEmpty) {
      throw Exception("Device not registered");
    }

    final event = NoiseEvent(
      deviceId: deviceId,

      message: message,

      db: db,

      time: DateTime.now(),

      type: type,

      synced: true,
    );

    _events.insert(0, event);

    await Database.saveNoiseEvent(
      deviceId: deviceId,

      noiseLevel: db,

      type: type.name.toUpperCase(),

      message: message,
    );
  }

  //=========================================================
  // LOAD EVENTS FROM DATABASE
  //=========================================================

  static Future<void> loadEvents() async {
    final deviceId = CurrentDevice.deviceId;

    if (deviceId == null) {
      return;
    }

    final result = await Database.getAlerts(deviceId);

    _events.clear();

    for (final row in result) {
      _events.add(
        NoiseEvent(
          deviceId: row["device_id"].toString(),

          message: row["message"].toString(),

          db: double.tryParse(row["noise_level"].toString()) ?? 0,

          time: row["created_at"] is DateTime
              ? row["created_at"]
              : DateTime.now(),

          type: _convertType(row["type"]),

          synced: true,
        ),
      );
    }
  }

  //=========================================================
  // CONVERT DATABASE TYPE
  //=========================================================

  static EventType _convertType(dynamic value) {
    switch (value.toString().toUpperCase()) {
      case "SPIKE":
        return EventType.spike;

      case "WARNING_APPROACHING":
        return EventType.warning;

      case "LIMIT_REACHED":
        return EventType.limitReached;

      case "VIOLATION":
        return EventType.violation;

      case "RESOLVED":
        return EventType.resolved;

      case "CALIBRATION":
        return EventType.calibration;

      default:
        return EventType.system;
    }
  }

  //=========================================================
  // GET ALL EVENTS
  //=========================================================

  static List<NoiseEvent> getAll() {
    return List.unmodifiable(_events);
  }

  //=========================================================
  // COUNTS
  //=========================================================

  static int get warningCount =>
      _events.where((e) => e.type == EventType.warning).length;

  static int get limitReachedCount =>
      _events.where((e) => e.type == EventType.limitReached).length;

  static int get violationCount =>
      _events.where((e) => e.type == EventType.violation).length;

  static int get spikeCount =>
      _events.where((e) => e.type == EventType.spike).length;

  //=========================================================
  // CLEAR CACHE
  //=========================================================

  static void clear() {
    _events.clear();
  }
}
