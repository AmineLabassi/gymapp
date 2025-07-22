import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login/Signup Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
      routes: {
        '/signup': (context) => SignupPage(),
      },
    );
  }
}
