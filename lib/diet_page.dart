import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DietPage extends StatefulWidget {
  final String username;
  final double calories;

  const DietPage({required this.username, required this.calories});

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
    fetchDietFromBackend(widget.username, widget.calories).then((data) {
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
  }

  Future<Map<String, dynamic>> fetchDietFromBackend(String username, double calories) async {
    final url = Uri.parse('http://192.168.1.4:5000/diet'); // or your public server address

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": username,
        "calories_to_maintain_weight": calories.round()
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
                                  fontWeight: FontWeight.bold),
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
