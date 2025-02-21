import 'package:calorie_snap/models/food.dart';
import 'package:calorie_snap/db/food_db.dart';
import 'package:flutter/material.dart';

class CalorieProvider extends ChangeNotifier {
  int _todayCalories = 0;
  final FoodDatabase _foodDb = FoodDatabase.instance;
  List<Food> _foods = [];

  int get todayCalories => _todayCalories;
  List<Food> get foods => _foods;

  Future<void> loadFoods() async {
    await updateFoodsAndCalories();
  }

  Future<void> addFood(Food food) async {
    await _foodDb.insertFood(food);
    await updateFoodsAndCalories();
  }

  Future<void> updateFood(Food food) async {
    await _foodDb.updateFood(food);
    await updateFoodsAndCalories();
  }

  Future<void> deleteFood(int id) async {
    await _foodDb.deleteFood(id);
    await updateFoodsAndCalories();
  }

  Future<List<Food>> getFoodsByDate(DateTime date) async {
    return await _foodDb.getFoodsByDate(date);
  }

  Future<void> updateFoodsAndCalories() async {
    _foods = await _foodDb.getAllFoods();
    final today = DateTime.now();
    final todayFoods =
        _foods.where((food) => food.dateTime.day == today.day).toList();
    _todayCalories = todayFoods.fold(0, (sum, food) => sum + food.calories);
    notifyListeners();
  }

  void updateFoodGroup(Food food, String newGroup) async {
    food.group = newGroup;
    await updateFoodsAndCalories();
  }
}
