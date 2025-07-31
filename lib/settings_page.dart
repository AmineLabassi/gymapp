import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  final String username;

  SettingsPage({required this.username});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedGoal = 'Lose weight';

  Future<void> updateInfo() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.4:5000/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': widget.username,
        'goal': selectedGoal,
        'height': double.tryParse(heightController.text) ?? 0.0,
        'weight': double.tryParse(weightController.text) ?? 0.0,
        'age': int.tryParse(ageController.text) ?? 0,
        'gender': '', 
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(jsonDecode(response.body)['message'])),
    );
  }

  Future<void> changePassword() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.4:5000/change-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': widget.username,
        'password': passwordController.text,
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(jsonDecode(response.body)['message'])),
    );
  }

  Future<void> deleteAccount() async {
    final response = await http.delete(
      Uri.parse('http://192.168.1.4:5000/delete/${widget.username}'),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(jsonDecode(response.body)['message'])));

    if (response.statusCode == 200) {
      Navigator.popUntil(context, (route) => route.isFirst);
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
        title: Text('Settings'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: heightController, decoration: _inputStyle('Height (cm)'), keyboardType: TextInputType.number, style: TextStyle(color: Colors.white)),
            SizedBox(height: 15),
            TextField(controller: weightController, decoration: _inputStyle('Weight (kg)'), keyboardType: TextInputType.number, style: TextStyle(color: Colors.white)),
            SizedBox(height: 15),
            TextField(controller: ageController, decoration: _inputStyle('Age'), keyboardType: TextInputType.number, style: TextStyle(color: Colors.white)),
            SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedGoal,
              dropdownColor: Colors.blue.shade800,
              decoration: _inputStyle('Goal'),
              style: TextStyle(color: Colors.white),
              items: ['Lose weight', 'Gain muscle'].map((goal) {
                return DropdownMenuItem(value: goal, child: Text(goal));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGoal = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateInfo,
              child: Text("Update Info"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: passwordController,
              decoration: _inputStyle('New Password'),
              obscureText: true,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: changePassword,
              child: Text("Change Password"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: deleteAccount,
              child: Text("Delete Account"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
