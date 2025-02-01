
import 'package:flutter/material.dart';

class CalorieProvider extends ChangeNotifier {
  int _todayCalories = 0;

  int get todayCalories => _todayCalories;

  void updateCalories(int calories) {
    _todayCalories = calories;
    notifyListeners();
  }
}