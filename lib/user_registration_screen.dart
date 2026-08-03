import 'package:flutter/material.dart';
import 'database.dart';
import 'current_device.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final businessNameController = TextEditingController();
  final businessTypeController = TextEditingController();
  final addressController = TextEditingController();
  final districtController = TextEditingController();

  final ownerController = TextEditingController();
  final ownerNinController = TextEditingController();

  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final licenseController = TextEditingController();
  final tinController = TextEditingController();

  final deviceNumberController = TextEditingController();

  String status = "Active";
  bool loading = false;

  @override
  void dispose() {
    businessNameController.dispose();
    businessTypeController.dispose();
    addressController.dispose();
    districtController.dispose();
    ownerController.dispose();
    ownerNinController.dispose();
    phoneController.dispose();
    emailController.dispose();
    licenseController.dispose();
    tinController.dispose();
    deviceNumberController.dispose();
    super.dispose();
  }

  Future<void> saveBusiness() async {
    final deviceId = deviceNumberController.text.trim();

    if (businessNameController.text.trim().isEmpty ||
        ownerController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        deviceId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill required fields")));
      return;
    }

    if (!emailController.text.contains("@") &&
        emailController.text.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid email")));
      return;
    }

    setState(() => loading = true);

    try {
      await Database.registerStation(
        businessName: businessNameController.text.trim(),
        businessType: businessTypeController.text.trim(),
        address: addressController.text.trim(),
        district: districtController.text.trim(),
        owner: ownerController.text.trim(),
        nin: ownerNinController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        license: licenseController.text.trim(),
        tin: tinController.text.trim(),
        status: status,
        deviceNumber: deviceId,
      );

      CurrentDevice.set(
        deviceId: deviceId,
        ownerEmail: emailController.text.trim(),
        ownerPhone: phoneController.text.trim(),
        businessName: businessNameController.text.trim(),
        district: districtController.text.trim(),
      );

      clearFields();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Station registered successfully")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void clearFields() {
    businessNameController.clear();
    businessTypeController.clear();
    addressController.clear();
    districtController.clear();
    ownerController.clear();
    ownerNinController.clear();
    phoneController.clear();
    emailController.clear();
    licenseController.clear();
    tinController.clear();
    deviceNumberController.clear();
  }

  Widget field(String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Noise Station")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            section("Business Info"),
            field("Business Name", Icons.business, businessNameController),
            field("Business Type", Icons.category, businessTypeController),
            field("Address", Icons.location_on, addressController),
            field("District", Icons.map, districtController),

            section("Owner Info"),
            field("Owner Name", Icons.person, ownerController),
            field("Owner NIN", Icons.badge, ownerNinController),

            section("Contact"),
            field("Phone", Icons.phone, phoneController),
            field("Email", Icons.email, emailController),

            section("Legal"),
            field("License", Icons.description, licenseController),
            field("TIN", Icons.receipt, tinController),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: status,
              items: const [
                DropdownMenuItem(value: "Active", child: Text("Active")),
                DropdownMenuItem(value: "Suspended", child: Text("Suspended")),
              ],
              onChanged: (value) {
                setState(() => status = value ?? "Active");
              },
              decoration: const InputDecoration(labelText: "Status"),
            ),

            const SizedBox(height: 10),

            section("Device"),
            field("Device ID", Icons.sensors, deviceNumberController),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : saveBusiness,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Register Station"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
