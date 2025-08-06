import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'gym_program_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  double calculateCalories({
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

    if (goal.toLowerCase() == 'lose weight') {
      return bmr * 0.85;
    } else if (goal.toLowerCase() == 'gain muscle') {
      return bmr * 1.15;
    }

    return bmr;
  }

 void _onItemTapped(int index, AppState appState) {
  if (_selectedIndex == index) return;

  setState(() {
    _selectedIndex = index;
  });

  switch (index) {
    case 1:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GymProgramPage(),
        ),
      );
      break;
    case 2:
      Navigator.pushNamed(context, '/diet');
      break;
    case 3:
      Navigator.pushNamed(context, '/settings');
      break;
    case 4:
      appState.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      break;
  }
}


  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final username = appState.username ?? 'User';
    final gender = appState.gender ?? 'male';
    final weight = appState.weight ?? 70;
    final height = appState.height ?? 170;
    final age = appState.age ?? 25;
    final goal = appState.goal ?? 'maintain';

    final calories = calculateCalories(
      gender: gender,
      weight: weight,
      height: height,
      age: age,
      goal: goal,
    ).round();

    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text("Your Daily Plan"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome, $username!",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Your estimated daily calorie needs are:",
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "$calories kcal",
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue.shade800,
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (index) => _onItemTapped(index, appState),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Gym'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Diet'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }
}
