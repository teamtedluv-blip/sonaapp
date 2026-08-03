import 'package:flutter/material.dart';
import 'database.dart';
import 'current_device.dart';

class Alerts extends StatefulWidget {
  const Alerts({super.key});

  @override
  State<Alerts> createState() => _AlertsState();
}

class _AlertsState extends State<Alerts> {
  List<Map<String, dynamic>> alerts = [];

  int unreadCount = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadAlerts();
  }

  // =========================
  // LOAD ALERTS
  // =========================

  Future<void> loadAlerts() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    try {
      final deviceId = CurrentDevice.deviceId;

      if (deviceId == null) {
        if (mounted) {
          setState(() {
            alerts = [];

            unreadCount = 0;

            loading = false;
          });
        }

        return;
      }

      final data = await Database.getAlerts(deviceId);

      if (mounted) {
        setState(() {
          alerts = data;

          unreadCount = alerts.where((a) => !_isRead(a["is_read"])).length;

          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Alert load error: $e");

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // =========================
  // MARK READ
  // =========================

  Future<void> markAsRead(String id) async {
    try {
      await Database.markAlertAsRead(id);

      if (!mounted) return;

      setState(() {
        final index = alerts.indexWhere((a) => a["id"].toString() == id);

        if (index != -1 && !_isRead(alerts[index]["is_read"])) {
          alerts[index]["is_read"] = true;

          if (unreadCount > 0) {
            unreadCount--;
          }
        }
      });
    } catch (e) {
      debugPrint("Mark read error: $e");
    }
  }

  // =========================
  // HELPERS
  // =========================

  bool _isRead(dynamic value) {
    return value == true || value == 1 || value == "true";
  }

  String _type(dynamic value) {
    return value.toString().toUpperCase();
  }

  Color _alertColor(String type) {
    switch (type) {
      case "WARNING":
        return Colors.orange;

      case "VIOLATION":
        return Colors.red;

      case "RESOLVED":
        return Colors.green;

      default:
        return Colors.blue;
    }
  }

  IconData _alertIcon(String type) {
    switch (type) {
      case "WARNING":
        return Icons.warning;

      case "VIOLATION":
        return Icons.error;

      case "RESOLVED":
        return Icons.check_circle;

      default:
        return Icons.notifications;
    }
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    final deviceId = CurrentDevice.deviceId ?? "UNKNOWN DEVICE";

    return Scaffold(
      backgroundColor: const Color(0xff0B1220),

      appBar: AppBar(
        backgroundColor: const Color(0xff0B1220),

        title: Text("Alerts ($unreadCount new)"),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,

            margin: const EdgeInsets.all(12),

            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: const Color(0xff111827),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Text(
              "Device: $deviceId",

              style: const TextStyle(color: Colors.white),
            ),
          ),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: loadAlerts,

                    child: alerts.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                              ),

                              const Center(
                                child: Text(
                                  "No alerts yet",

                                  style: TextStyle(color: Colors.white54),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),

                            itemCount: alerts.length,

                            itemBuilder: (context, index) {
                              final alert = alerts[index];

                              final type = _type(alert["type"]);

                              final read = _isRead(alert["is_read"]);

                              return Card(
                                color: read
                                    ? Colors.white10
                                    : _alertColor(type).withOpacity(0.15),

                                child: ListTile(
                                  leading: Icon(
                                    _alertIcon(type),

                                    color: _alertColor(type),
                                  ),

                                  title: Text(
                                    alert["message"]?.toString() ??
                                        "No message",

                                    style: const TextStyle(color: Colors.white),
                                  ),

                                  subtitle: Text(
                                    "${alert["noise_level"] ?? 0} dBA\n$type",

                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),

                                  trailing: Text(
                                    read ? "READ" : "NEW",

                                    style: TextStyle(
                                      color: read ? Colors.green : Colors.red,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  onTap: () {
                                    final id = alert["id"];

                                    if (id != null) {
                                      markAsRead(id.toString());
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
