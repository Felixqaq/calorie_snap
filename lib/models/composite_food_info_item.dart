import 'package:calorie_snap/models/food_info.dart';
import 'package:calorie_snap/models/food_info_item.dart';

class CompositeFoodInfoItem implements FoodInfo {
  String foodName;
  List<FoodInfo> foodItems;

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

  CompositeFoodInfoItem({required this.foodName, required this.foodItems});

  factory CompositeFoodInfoItem.fromJson(Map<String, dynamic> json) {
    List<FoodInfo> items = (json['food_items'] as List?)
        ?.map((item) => FoodInfoItem.fromJson(item))
        .toList() ?? [];
    return CompositeFoodInfoItem(
      foodName: json['food_name'] ?? '',
      foodItems: items,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'food_items': foodItems.map((item) => item.toJson()).toList(),
    };
  }
}