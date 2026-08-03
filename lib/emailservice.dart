import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static final SmtpServer smtpServer = gmail(
    'your_email@gmail.com',
    'your_app_password',
  );

  // CONTROL CENTER EMAIL
  static const String controlCenterEmail = "controlcenter@sona.com";

  // =========================
  // SEND EMAIL
  // =========================

  static Future<void> sendEmail({
    required String recipient,

    required String subject,

    required String message,
  }) async {
    final email = Message()
      ..from = const Address('your_email@gmail.com', 'SONA Monitor System')
      ..recipients.add(recipient)
      ..subject = subject
      ..text = message;

    try {
      await send(email, smtpServer);

      print("Email sent to $recipient");
    } catch (e) {
      print("Email error: $e");
    }
  }

  // =========================
  // WARNING 1
  // 70 - 74 dBA
  // =========================

  static Future<void> sendApproachingLimitEmail({
    required String recipient,

    required double noise,
  }) async {
    await sendEmail(
      recipient: recipient,

      subject: "⚠ Noise Approaching Limit",

      message:
          "SONA Noise Monitoring Alert\n\n"
          "Noise level is approaching the allowed limit.\n\n"
          "Current level: $noise dBA\n\n"
          "Please reduce sound to avoid a violation.",
    );
  }

  // =========================
  // WARNING 2
  // 75+ dBA
  // =========================

  static Future<void> sendLimitReachedEmail({
    required String recipient,

    required double noise,
  }) async {
    await sendEmail(
      recipient: recipient,

      subject: "⚠ Noise Limit Reached",

      message:
          "SONA Noise Monitoring Alert\n\n"
          "The allowed noise limit has been reached.\n\n"
          "Current level: $noise dBA\n\n"
          "Please reduce sound within 5 minutes to avoid a violation.",
    );
  }

  // =========================
  // VIOLATION
  // =========================

  static Future<void> sendViolationEmail({
    required String recipient,

    required double noise,
  }) async {
    await sendEmail(
      recipient: recipient,

      subject: "🚨 Noise Pollution Violation",

      message:
          "SONA Violation Notice\n\n"
          "Noise remained above the allowed limit for 5 minutes.\n\n"
          "Measured level: $noise dBA\n\n"
          "A noise pollution violation has been recorded.",
    );
  }
}
