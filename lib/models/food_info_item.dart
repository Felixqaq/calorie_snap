import 'package:calorie_snap/models/food_info.dart';

class FoodInfoItem implements FoodInfo {
  final String foodName;
  final String foodNameZh;
  @override
  final String weight;
  @override
  final String calories;
  @override
  final String fat;
  @override
  final String carbs;
  @override
  final String protein;
  final List<FoodInfo> foodItems = [];

  FoodInfoItem({
    required this.foodName,
    required this.foodNameZh,
    required this.weight,
    required this.calories,
    required this.fat,
    required this.carbs,
    required this.protein,
  });

  factory FoodInfoItem.fromJson(Map<String, dynamic> json) {
    return FoodInfoItem(
      foodName: json['food_name'],
      foodNameZh: json['food_name_zh'],
      weight: json['weight'],
      calories: json['calories'],
      fat: json['fat'],
      carbs: json['carbs'],
      protein: json['protein'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'food_name_zh': foodNameZh,
      'weight': weight,
      'calories': calories,
      'fat': fat,
      'carbs': carbs,
      'protein': protein,
    };
  }
}