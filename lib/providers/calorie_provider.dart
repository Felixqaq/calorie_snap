import 'package:flutter/material.dart';
import '../food_db.dart';

class CalorieProvider extends ChangeNotifier {
  int _todayCalories = 0;
  final FoodDatabase _foodDb = FoodDatabase.instance;
  List<Food> _foods = [];

  int get todayCalories => _todayCalories;
  List<Food> get foods => _foods;

  Future<void> loadFoods() async {
    final foods = await _foodDb.getAllFoods();
    _foods = foods.toList();

    final today = DateTime.now();
    final todayFoods = foods.where((food) => food.dateTime.day == today.day).toList();
    _todayCalories = todayFoods.fold(0, (sum, food) => sum + food.calories);
    notifyListeners();
  }
}