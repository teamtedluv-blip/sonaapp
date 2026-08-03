import 'package:flutter/material.dart';

class PostgresStatus extends StatelessWidget {
  final bool connected;
  final String lastUpdate;

  const PostgresStatus({
    super.key,
    required this.connected,
    required this.lastUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PostgreSQL",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Icon(
                connected ? Icons.cloud_done : Icons.cloud_off,
                color: connected ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                connected ? "Connected" : "Disconnected",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            "Last Update: $lastUpdate",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
