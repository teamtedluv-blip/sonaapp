import 'package:shared_preferences/shared_preferences.dart';

class CurrentDevice {
  static String? deviceId;

  static String? ownerEmail;
  static String? ownerPhone;
  static String? businessName;
  static String? district;

  static Future<void> set({
    required String deviceId,
    required String ownerEmail,
    required String ownerPhone,
    required String businessName,
    required String district,
  }) async {
    CurrentDevice.deviceId = deviceId;
    CurrentDevice.ownerEmail = ownerEmail;
    CurrentDevice.ownerPhone = ownerPhone;
    CurrentDevice.businessName = businessName;
    CurrentDevice.district = district;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("deviceId", deviceId);
    await prefs.setString("ownerEmail", ownerEmail);
    await prefs.setString("ownerPhone", ownerPhone);
    await prefs.setString("businessName", businessName);
    await prefs.setString("district", district);
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    deviceId = prefs.getString("deviceId");
    ownerEmail = prefs.getString("ownerEmail");
    ownerPhone = prefs.getString("ownerPhone");
    businessName = prefs.getString("businessName");
    district = prefs.getString("district");
  }

  static bool get isReady => deviceId != null;
}
