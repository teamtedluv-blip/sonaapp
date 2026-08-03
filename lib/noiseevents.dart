import 'package:flutter/material.dart';
import 'current_device.dart';
import 'noise_event_manager.dart';

class NoiseEvents extends StatefulWidget {
  const NoiseEvents({super.key});

  @override
  State<NoiseEvents> createState() => _NoiseEventsState();
}

class _NoiseEventsState extends State<NoiseEvents> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    setState(() => loading = true);

    await NoiseEventManager.loadEvents();

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Color cardColor(EventType type) {
    switch (type) {
      case EventType.warning:
        return Colors.orange.shade100;

      case EventType.violation:
        return Colors.red.shade100;

      case EventType.spike:
        return Colors.yellow.shade100;

      case EventType.calibration:
        return Colors.blue.shade100;

      default:
        return Colors.grey.shade200;
    }
  }

  IconData icon(EventType type) {
    switch (type) {
      case EventType.warning:
        return Icons.warning_amber;

      case EventType.violation:
        return Icons.gavel;

      case EventType.spike:
        return Icons.graphic_eq;

      case EventType.calibration:
        return Icons.tune;

      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = NoiseEventManager.getAll();
    final deviceId = CurrentDevice.deviceId ?? "UNKNOWN";

    return Scaffold(
      backgroundColor: const Color(0xff0B1220),

      appBar: AppBar(
        title: const Text("Noise Events"),
        backgroundColor: const Color(0xff111827),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadEvents,
              child: Column(
                children: [
                  // =========================
                  // HEADER / STATS
                  // =========================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xff111827),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Device: $deviceId",
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Total Events: ${events.length}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "Warnings: ${events.where((e) => e.type == EventType.warning).length}",
                          style: const TextStyle(color: Colors.orangeAccent),
                        ),
                        Text(
                          "Violations: ${events.where((e) => e.type == EventType.violation).length}",
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),

                  // =========================
                  // EVENT LIST
                  // =========================
                  Expanded(
                    child: events.isEmpty
                        ? const Center(
                            child: Text(
                              "No events yet",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];

                              return Card(
                                color: cardColor(event.type),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: Icon(icon(event.type)),
                                  title: Text(event.message),
                                  subtitle: Text(
                                    "${event.db.toStringAsFixed(1)} dB\n${event.time}",
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
