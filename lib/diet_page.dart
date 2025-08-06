import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  Map<String, dynamic>? dietData;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      final username = appState.username ?? 'user';
      final calories = _calculateCalories(
        gender: appState.gender ?? 'male',
        weight: appState.weight ?? 70,
        height: appState.height ?? 170,
        age: appState.age ?? 25,
        goal: appState.goal ?? 'maintain',
      ).round();

      fetchDietFromBackend(username, calories).then((data) {
        setState(() {
          dietData = data;
          loading = false;
        });
      }).catchError((err) {
        setState(() {
          error = err.toString();
          loading = false;
        });
      });
    });
  }

  double _calculateCalories({
    required String gender,
    required double weight,
    required double height,
    required int age,
    required String goal,
  }) {
    double bmr;
    if (gender.toLowerCase() == 'female') {
      bmr = 447.6 + (9.2 * weight) + (3.1 * height) - (4.3 * age);
    } else {
      bmr = 88.36 + (13.4 * weight) + (4.8 * height) - (5.7 * age);
    }

    switch (goal.toLowerCase()) {
      case 'lose weight':
        return bmr * 0.85;
      case 'gain muscle':
        return bmr * 1.15;
      default:
        return bmr;
    }
  }

  Future<Map<String, dynamic>> fetchDietFromBackend(String username, int calories) async {
    final url = Uri.parse('http://192.168.245.59:5000/diet');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": username,
        "calories_to_maintain_weight": calories
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load diet plan: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      appBar: AppBar(
        title: const Text('Your Diet Plan'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Text(
                    error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  )
                : dietData == null
                    ? const Text('No data received.')
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Calories target: ${dietData!["calories"]} kcal',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildMealSection("🍳 Breakfast", dietData!["breakfast"]),
                            _buildMealSection("🍛 Lunch", dietData!["lunch"]),
                            _buildMealSection("🍝 Dinner", dietData!["dinner"]),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildMealSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
