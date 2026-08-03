import 'package:flutter/material.dart';

import 'database.dart';
import 'analog_meter.dart';
import 'calibration_card.dart';
import 'postgres_status.dart';
import 'current_device.dart';
import 'microphone_services.dart';
import 'alert_engine.dart';

import 'user_registration_screen.dart';
import 'alerts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MicrophoneService microphone = MicrophoneService();

  double rawDb = 0;

  double calibrationOffset = 0;

  bool micActive = false;

  bool pgConnected = true;

  String lastUpdate = "--:--:--";

  int uploadCount = 0;

  // AUTO CALIBRATION

  bool calibrating = false;

  double calibrationProgress = 0;

  double calibrationTotal = 0;

  int calibrationSamples = 0;

  @override
  void initState() {
    super.initState();

    start();

    startAlertEngine();
  }

  void startAlertEngine() {
    final deviceId = CurrentDevice.deviceId;

    if (deviceId == null) {
      debugPrint("No device ID for Alert Engine");

      return;
    }

    AlertEngine.start(deviceId);
  }

  Future<void> start() async {
    final deviceId = CurrentDevice.deviceId;

    if (deviceId == null) {
      debugPrint("DEVICE NOT REGISTERED");

      return;
    }

    microphone.onLevel = (level) async {
      final calibrated = (level + calibrationOffset).clamp(0, 120).toDouble();

      if (mounted) {
        setState(() {
          rawDb = calibrated;

          lastUpdate = TimeOfDay.now().format(context);
        });
      }

      try {
        await Database.saveNoiseReading(
          deviceId: deviceId,
          noiseLevel: calibrated,
        );

        if (mounted) {
          setState(() {
            uploadCount++;

            pgConnected = true;
          });
        }
      } catch (e) {
        debugPrint("Noise upload error: $e");

        if (mounted) {
          setState(() {
            pgConnected = false;
          });
        }
      }
    };

    try {
      await microphone.start();

      if (mounted) {
        setState(() {
          micActive = true;
        });
      }
    } catch (e) {
      debugPrint("Microphone start error: $e");

      if (mounted) {
        setState(() {
          micActive = false;
        });
      }
    }
  }
  // ===============================
  // AUTO CALIBRATION
  // ===============================

  Future<void> autoCalibrate() async {
    setState(() {
      calibrating = true;

      calibrationProgress = 0;

      calibrationTotal = 0;

      calibrationSamples = 0;
    });

    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 50));

      calibrationTotal += rawDb;

      calibrationSamples++;

      if (mounted) {
        setState(() {
          calibrationProgress = i / 100;
        });
      }
    }

    final average = calibrationTotal / calibrationSamples;

    setState(() {
      calibrationOffset = -average;

      calibrating = false;

      calibrationProgress = 1;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Auto calibration completed")));
  }

  @override
  void dispose() {
    microphone.stop();

    AlertEngine.stop();

    super.dispose();
  }

  void openRegistration() {
    Navigator.push(
      context,

      MaterialPageRoute(builder: (_) => const UserRegistrationScreen()),
    );
  }

  void openAlerts() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const Alerts()));
  }

  @override
  Widget build(BuildContext context) {
    final deviceId = CurrentDevice.deviceId ?? "NOT REGISTERED";

    final business = CurrentDevice.businessName ?? "UNKNOWN";

    return Scaffold(
      backgroundColor: const Color(0xff0B1220),

      appBar: AppBar(
        title: const Text("SONA Control Center"),

        backgroundColor: Colors.black,

        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),

            tooltip: "Registration",

            onPressed: openRegistration,
          ),

          IconButton(
            icon: const Icon(Icons.warning),

            tooltip: "Alerts",

            onPressed: openAlerts,
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(12),

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

                      Text(
                        "Station: $business",

                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                AnalogMeter(value: rawDb),

                const SizedBox(height: 20),

                CalibrationCard(
                  offset: calibrationOffset,

                  calibrating: calibrating,

                  progress: calibrationProgress,

                  onAutoCalibrate: autoCalibrate,

                  onPlus: () {
                    setState(() {
                      calibrationOffset += 0.5;
                    });
                  },

                  onMinus: () {
                    setState(() {
                      calibrationOffset -= 0.5;
                    });
                  },

                  onSave: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Calibration saved")),
                    );
                  },
                ),
                const SizedBox(height: 20),

                PostgresStatus(connected: pgConnected, lastUpdate: lastUpdate),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: const Color(0xff111827),

                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "Uploads: $uploadCount",

                        style: const TextStyle(color: Colors.white),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Text(
                            "Microphone: ",

                            style: TextStyle(color: Colors.white),
                          ),

                          Icon(
                            micActive ? Icons.mic : Icons.mic_off,

                            color: micActive ? Colors.green : Colors.red,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      if (calibrating)
                        Text(
                          "Calibration: ${(calibrationProgress * 100).toStringAsFixed(0)}%",

                          style: const TextStyle(color: Colors.orange),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
