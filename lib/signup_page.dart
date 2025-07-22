import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String selectedGoal = 'Lose weight';
  String selectedGender = 'Male';

  Future<void> captureAndUploadFace(String username) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage == null) return;

    final bytes = await pickedImage.readAsBytes();
    final base64Image = 'data:image/jpeg;base64,' + base64Encode(bytes);

    final faceResponse = await http.post(
      Uri.parse('http://192.168.1.3:5000/upload-face'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'face_image': base64Image}),
    );

    final result = jsonDecode(faceResponse.body);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result['message'])));
  }

  Future<void> register(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.3:5000/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
        'gender': selectedGender.toLowerCase(),
        'goal': selectedGoal,
        'height': double.tryParse(heightController.text) ?? 0.0,
        'weight': double.tryParse(weightController.text) ?? 0.0,
        'age': int.tryParse(ageController.text) ?? 0,
      }),
    );

    final result = jsonDecode(response.body);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result['message'])));

    if (response.statusCode == 201) {
      Navigator.pop(context);
    }
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      hintText: label,
      filled: true,
      fillColor: Colors.blue.shade800,
      hintStyle: TextStyle(color: Colors.white54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      appBar: AppBar(
        title: Text('Create Account'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: _inputStyle('Username'),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 15),
            TextField(
              controller: passwordController,
              decoration: _inputStyle('Password'),
              obscureText: true,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedGender,
              dropdownColor: Colors.blue.shade800,
              decoration: _inputStyle('Gender'),
              style: TextStyle(color: Colors.white),
              items: ['Male', 'Female'].map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGender = value!;
                });
              },
            ),
            SizedBox(height: 15),
            TextField(
              controller: heightController,
              decoration: _inputStyle('Height (cm)'),
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 15),
            TextField(
              controller: weightController,
              decoration: _inputStyle('Weight (kg)'),
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 15),
            TextField(
              controller: ageController,
              decoration: _inputStyle('Age'),
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedGoal,
              dropdownColor: Colors.blue.shade800,
              decoration: _inputStyle('Goal'),
              style: TextStyle(color: Colors.white),
              items: ['Lose weight', 'Gain muscle'].map((goal) {
                return DropdownMenuItem(
                  value: goal,
                  child: Text(goal),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGoal = value!;
                });
              },
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => register(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child:
                  Text("Sign up", style: TextStyle(color: Colors.black, fontSize: 16)),
            ),
            SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () =>
                  captureAndUploadFace(usernameController.text.trim()),
              icon: Icon(Icons.camera_alt),
              label: Text("Scan Face"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                foregroundColor: Colors.lightBlueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
