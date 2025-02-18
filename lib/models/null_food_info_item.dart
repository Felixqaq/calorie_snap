import 'package:calorie_snap/models/food_info.dart';

class NullFoodInfoItem implements FoodInfo {
  @override
  String get foodName => 'No Food';
  final List<FoodInfo> foodItems = [];
  @override
  String get weight => '0';
  @override
  String get calories => '0';
  @override
  String get fat => '0';
  @override
  String get carbs => '0';
  @override
  String get protein => '0';

  @override
  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'weight': '0',
      'calories': '0',
      'fat': '0',
      'carbs': '0',
      'protein': '0',
    };
  }
}