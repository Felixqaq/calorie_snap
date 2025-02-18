import 'package:calorie_snap/models/food.dart';
import 'package:calorie_snap/food_db.dart';
import 'package:flutter/material.dart';

class CalorieProvider extends ChangeNotifier {
  int _todayCalories = 0;
  final FoodDatabase _foodDb = FoodDatabase.instance;
  List<Food> _foods = [];

  int get todayCalories => _todayCalories;
  List<Food> get foods => _foods;

  Future<void> loadFoods() async {
    final foods = await _foodDb.getAllFoods();
    _updateFoodsAndCalories(foods);
  }

  Future<void> addFood(Food food) async {
    await _foodDb.insertFood(food);
    await loadFoods();
  }

  Future<void> updateFood(Food food) async {
    await _foodDb.updateFood(food);
    await loadFoods();
  }

  Future<void> deleteFood(int id) async {
    await _foodDb.deleteFood(id);
    await loadFoods();
  }

  Future<List<Food>> getFoodsByDate(DateTime date) async {
    return await _foodDb.getFoodsByDate(date);
  }

  void _updateFoodsAndCalories(List<Food> foods) {
    _foods = foods.toList();
    final today = DateTime.now();
    final todayFoods =
        foods.where((food) => food.dateTime.day == today.day).toList();
    _todayCalories = todayFoods.fold(0, (sum, food) => sum + food.calories);
    notifyListeners();
  }
}
