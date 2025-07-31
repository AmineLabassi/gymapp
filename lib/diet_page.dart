import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



const openRouterApiKey = ''; // starts with org-...

class DietPage extends StatefulWidget {
  final String goal;
  final int calories;

  const DietPage({required this.goal, required this.calories});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  String? dietPlan;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchDietPlan(widget.goal, widget.calories).then((plan) {
      setState(() {
        dietPlan = plan;
        loading = false;
      });
    }).catchError((error) {
      setState(() {
        dietPlan = 'Error generating diet plan: $error';
        loading = false;
      });
    });
  }

  Future<String> fetchDietPlan(String goal, int calories) async {
    final prompt = '''
Create a complete daily diet plan for a person with the goal "$goal" and a calorie target of $calories kcal.
Include breakfast, lunch, dinner, and 2 snacks.
List meals with ingredients and estimated calories per meal.
Keep it simple and practical.dont write  sure... just give only the answer and write This is your personalized diet plan with $calories
''';

    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Authorization': openRouterApiKey,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://yourappname.com', 
        'X-Title': 'gym',        
      },
      body: jsonEncode({
        "model": "openai/gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "You are a certified nutritionist."},
          {"role": "user", "content": prompt}
        ],
        "max_tokens": 700,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to generate diet plan: ${response.body}');
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
            : SingleChildScrollView(
                child: Text(
                  dietPlan ?? 'No plan generated.',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
      ),
    );
  }
}
