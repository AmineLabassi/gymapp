import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String? _username;
  String? _goal;
  int? _calories;
  String? _gender;
  double? _weight;
  double? _height;
  int? _age;

  // Getters
  String? get username => _username;
  String? get goal => _goal;
  int? get calories => _calories;
  String? get gender => _gender;
  double? get weight => _weight;
  double? get height => _height;
  int? get age => _age;

  // Setters
  void setUser(String username) {
    _username = username;
    notifyListeners();
  }

  void setGoalAndCalories(String goal, int calories) {
    _goal = goal;
    _calories = calories;
    notifyListeners();
  }

  void setUserDetails({
    required String gender,
    required double weight,
    required double height,
    required int age,
  }) {
    _gender = gender;
    _weight = weight;
    _height = height;
    _age = age;
    notifyListeners();
  }

  void logout() {
    _username = null;
    _goal = null;
    _calories = null;
    _gender = null;
    _weight = null;
    _height = null;
    _age = null;
    notifyListeners();
  }
}
