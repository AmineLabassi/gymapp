import 'package:flutter/material.dart';
import 'login_page.dart';
import 'settings_page.dart';
import 'gym_program_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String gender;
  final double weight;
  final double height;
  final int age;
  final String goal;

  HomePage({
    required this.username,
    required this.gender,
    required this.weight,
    required this.height,
    required this.age,
    required this.goal,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  double calculateCalories() {
    double bmr;
    if (widget.gender.toLowerCase() == 'female') {
      bmr = 447.6 + (9.2 * widget.weight) + (3.1 * widget.height) - (4.3 * widget.age);
    } else {
      bmr = 88.36 + (13.4 * widget.weight) + (4.8 * widget.height) - (5.7 * widget.age);
    }
    if (widget.goal.toLowerCase() == 'lose weight') {
      return bmr * 0.85;
    } else if (widget.goal.toLowerCase() == 'gain muscle') {
      return bmr * 1.15;
    }
    return bmr;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home, rien à faire, on y est
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GymProgramPage(goal: widget.goal),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsPage(username: widget.username),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final calories = calculateCalories().round();

    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Text("Your Daily Plan"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome, ${widget.username}!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                "Your estimated daily calorie needs are:",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              SizedBox(height: 10),
              Text(
                "$calories kcal",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue.shade800,
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Gym'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }
}
