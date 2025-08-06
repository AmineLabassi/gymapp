import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedGoal = 'Lose weight';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.height != null) heightController.text = appState.height!.toString();
      if (appState.weight != null) weightController.text = appState.weight!.toString();
      if (appState.age != null) ageController.text = appState.age!.toString();
      if (appState.goal != null) selectedGoal = _capitalizeGoal(appState.goal!);
    });
  }

  String _capitalizeGoal(String goal) {
    switch (goal.toLowerCase()) {
      case 'lose weight':
        return 'Lose weight';
      case 'gain muscle':
        return 'Gain muscle';
      default:
        return 'Maintain';
    }
  }

  Future<void> updateInfo() async {
    final appState = Provider.of<AppState>(context, listen: false);

    final response = await http.post(
      Uri.parse('http://192.168.245.59:5000/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': appState.username,
        'goal': selectedGoal,
        'height': double.tryParse(heightController.text) ?? 0.0,
        'weight': double.tryParse(weightController.text) ?? 0.0,
        'age': int.tryParse(ageController.text) ?? 0,
        'gender': appState.gender ?? '',
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(jsonDecode(response.body)['message'] ?? 'Update complete')),
    );

    // Update app state
    appState.setGoalAndCalories(selectedGoal, appState.calories ?? 0);
    appState.setUserDetails(
      gender: appState.gender ?? '',
      height: double.tryParse(heightController.text) ?? 0.0,
      weight: double.tryParse(weightController.text) ?? 0.0,
      age: int.tryParse(ageController.text) ?? 0,
    );
  }

  Future<void> changePassword() async {
    final appState = Provider.of<AppState>(context, listen: false);

    final response = await http.post(
      Uri.parse('http://192.168.245.59:5000/change-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': appState.username,
        'password': passwordController.text,
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(jsonDecode(response.body)['message'] ?? 'Password updated')),
    );
  }

  Future<void> deleteAccount() async {
    final appState = Provider.of<AppState>(context, listen: false);

    final response = await http.delete(
      Uri.parse('http://192.168.245.59:5000/delete/${appState.username}'),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(jsonDecode(response.body)['message'] ?? 'Account deleted')),
    );

    if (response.statusCode == 200) {
      appState.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      hintText: label,
      filled: true,
      fillColor: Colors.blue.shade800,
      hintStyle: const TextStyle(color: Colors.white54),
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
        title: const Text('Settings'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: heightController,
              decoration: _inputStyle('Height (cm)'),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: weightController,
              decoration: _inputStyle('Weight (kg)'),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: ageController,
              decoration: _inputStyle('Age'),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedGoal,
              dropdownColor: Colors.blue.shade800,
              decoration: _inputStyle('Goal'),
              style: const TextStyle(color: Colors.white),
              items: ['Lose weight', 'Gain muscle'].map((goal) {
                return DropdownMenuItem(value: goal, child: Text(goal));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGoal = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Update Info"),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: passwordController,
              decoration: _inputStyle('New Password'),
              obscureText: true,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Change Password"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: deleteAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Delete Account"),
            ),
          ],
        ),
      ),
    );
  }
}
