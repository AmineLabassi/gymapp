import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'package:image_picker/image_picker.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.3:5000/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
      }),
    );

    final result = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final userResponse = await http.get(
        Uri.parse('http://192.168.1.3:5000/user/${usernameController.text}'),
      );

      if (userResponse.statusCode == 200) {
        final user = jsonDecode(userResponse.body);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              username: user['username'],
              gender: user['gender'],
              goal: user['goal'],
              weight: user['weight'].toDouble(),
              height: user['height'].toDouble(),
              age: user['age'],
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
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
      Uri.parse('http://192.168.1.3:5000/verify-face'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        'face_image': base64Image,
      }),
    );

    final result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final userResponse = await http.get(
        Uri.parse('http://192.168.1.3:5000/user/${usernameController.text}'),
      );

      if (userResponse.statusCode == 200) {
        final user = jsonDecode(userResponse.body);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              username: user['username'],
              gender: user['gender'],
              goal: user['goal'],
              weight: user['weight'].toDouble(),
              height: user['height'].toDouble(),
              age: user['age'],
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
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
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center, size: 80, color: Colors.lightBlueAccent),
                SizedBox(height: 20),
                Text("Welcome Back",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 10),
                Text("Login to continue",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                SizedBox(height: 30),
                TextField(
                  controller: usernameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Username',
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                    filled: true,
                    fillColor: Colors.blue.shade800,
                    hintStyle: TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: Colors.white),
                    filled: true,
                    fillColor: Colors.blue.shade800,
                    hintStyle: TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => login(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text("Login", style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
                TextButton(
                  onPressed: () => loginWithFace(context),
                  child: Text("Login with Face", style: TextStyle(color: Colors.lightBlueAccent)),
                ),
                SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: Text("Don't have an account? Sign up",
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
