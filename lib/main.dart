import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'diet_page.dart';
import 'gym_program_page.dart';
import 'settings_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
        '/diet': (context) => const DietPage(),
        '/gym': (context) => const GymProgramPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
