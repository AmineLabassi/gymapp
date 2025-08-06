import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key}); // ✅ Added const constructor

  // These controllers must not be final if you want them to reset every time
  static final TextEditingController usernameController = TextEditingController();
  static final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://192.168.245.59:5000/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
      }),
    );

    final result = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final userResponse = await http.get(
        Uri.parse('http://192.168.245.59:5000/user/${usernameController.text}'),
      );

      if (userResponse.statusCode == 200) {
        final user = jsonDecode(userResponse.body);

        final appState = Provider.of<AppState>(context, listen: false);
        appState.setUser(user['username']);
       final goal = user['goal'] ?? 'maintain';
final calories = user['calories'];
appState.setGoalAndCalories(
  goal,
  calories is int ? calories : 2000, // fallback to 2000 if null or not an int
);


        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Login failed')),
      );
    }
  }

  Future<void> loginWithFace(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage == null) return;

    final bytes = await pickedImage.readAsBytes();
    final base64Image = 'data:image/jpeg;base64,' + base64Encode(bytes);

    final response = await http.post(
      Uri.parse('http://192.168.245.59:5000/verify-face'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        'face_image': base64Image,
      }),
    );

    final result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final userResponse = await http.get(
        Uri.parse('http://192.168.245.59:5000/user/${usernameController.text}'),
      );

      if (userResponse.statusCode == 200) {
        final user = jsonDecode(userResponse.body);

        final appState = Provider.of<AppState>(context, listen: false);
        appState.setUser(user['username']);
        appState.setGoalAndCalories(user['goal'], user['calories']);

        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Face login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fitness_center, size: 80, color: Colors.lightBlueAccent),
                const SizedBox(height: 20),
                const Text("Welcome Back",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                const Text("Login to continue", style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 30),
                TextField(
                  controller: usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Username',
                    prefixIcon: const Icon(Icons.person, color: Colors.white),
                    filled: true,
                    fillColor: Colors.blue.shade800,
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.white),
                    filled: true,
                    fillColor: Colors.blue.shade800,
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => login(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text("Login", style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
                TextButton(
                  onPressed: () => loginWithFace(context),
                  child: const Text("Login with Face", style: TextStyle(color: Colors.lightBlueAccent)),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text("Don't have an account? Sign up",
                      style: TextStyle(color: Colors.lightBlueAccent)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
