import 'package:flutter/material.dart';

class CalibrationCard extends StatelessWidget {
  final double offset;

  final VoidCallback onPlus;

  final VoidCallback onMinus;

  final VoidCallback onSave;

  final bool calibrating;

  final double progress;

  final VoidCallback onAutoCalibrate;

  const CalibrationCard({
    super.key,

    required this.offset,

    required this.onPlus,

    required this.onMinus,

    required this.onSave,

    required this.calibrating,

    required this.progress,

    required this.onAutoCalibrate,
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
        children: [
          const Text(
            "Calibration",

            style: TextStyle(color: Colors.white, fontSize: 18),
          ),

          const SizedBox(height: 10),

          Text(
            "Offset: ${offset.toStringAsFixed(1)} dB",

            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 15),

          if (calibrating)
            Column(
              children: [
                LinearProgressIndicator(value: progress),

                const SizedBox(height: 8),

                Text(
                  "Auto Calibration ${(progress * 100).toStringAsFixed(0)}%",

                  style: const TextStyle(color: Colors.orange),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: onAutoCalibrate,

              icon: const Icon(Icons.auto_fix_high),

              label: const Text("Auto Calibration"),
            ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              IconButton(
                onPressed: onMinus,

                icon: const Icon(Icons.remove, color: Colors.white),
              ),

              IconButton(
                onPressed: onPlus,

                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),

          ElevatedButton(
            onPressed: onSave,

            child: const Text("Save Calibration"),
          ),
        ],
      ),
    );
  }
}
