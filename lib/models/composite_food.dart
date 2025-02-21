import 'food.dart';

class CompositeFood {
  final String name;
  final List<Food> foods;

  CompositeFood({
    required this.name,
    required this.foods,
  });

  int get totalCalories => foods.fold(0, (sum, food) => sum + food.calories);
  double get totalFat => foods.fold(0, (sum, food) => sum + (food.fat ?? 0));
  double get totalCarbs => foods.fold(0, (sum, food) => sum + (food.carbs ?? 0));
  double get totalProtein => foods.fold(0, (sum, food) => sum + (food.protein ?? 0));

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'foods': foods.map((food) => food.toMap()).toList(),
      'totalCalories': totalCalories,
      'totalFat': totalFat,
      'totalCarbs': totalCarbs,
      'totalProtein': totalProtein,
    };
  }
}
