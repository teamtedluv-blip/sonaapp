import 'package:flutter/material.dart';
import 'database.dart';
import 'homescreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool passwordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // =========================
      // ENSURE DATABASE CONNECTION
      // =========================

      if (Database.connection == null) {
        debugPrint("Database not connected. Connecting...");

        await Database.connect();

        debugPrint("Database reconnected");
      }

      // =========================
      // LOGIN
      // =========================

      final user = await Database.login(email, password);

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );

        return;
      }

      debugPrint("User: ${user['email']}");
      debugPrint("Role: ${user['role']}");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login error: $e")));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> forgotPassword() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Contact administrator to reset password")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade200, Colors.green.shade700],

            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: SizedBox(
            width: 400,

            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset("images/blink.png", height: 120),

                  const SizedBox(height: 20),

                  const Text(
                    "SONA LOGIN",

                    style: TextStyle(
                      fontSize: 28,

                      fontWeight: FontWeight.bold,

                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: emailController,

                    decoration: InputDecoration(
                      hintText: "Email",

                      filled: true,

                      fillColor: Colors.white,

                      prefixIcon: const Icon(Icons.email),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: passwordController,

                    obscureText: !passwordVisible,

                    decoration: InputDecoration(
                      hintText: "Password",

                      filled: true,

                      fillColor: Colors.white,

                      prefixIcon: const Icon(Icons.lock),

                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),

                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,

                    height: 50,

                    child: loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: login,

                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),

                            child: const Text("LOGIN"),
                          ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: forgotPassword,

                    child: const Text(
                      "Forgot Password?",

                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
