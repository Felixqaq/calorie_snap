import 'package:calorie_snap/models/food_info.dart';
import 'package:calorie_snap/models/food_info_item.dart';

class CompositeFoodInfoItem implements FoodInfo {
  String foodName = '';
  String foodNameZh = '';
  List<FoodInfo> foodItems;
  String compositeName = '';
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

  CompositeFoodInfoItem({required this.compositeName, required this.foodItems});

  factory CompositeFoodInfoItem.fromJson(List<dynamic> json, String name) {
    List<FoodInfo> foodList = [];
    for (var item in json) {
      foodList.add(FoodInfoItem.fromJson(item));
    }
    return CompositeFoodInfoItem(
      compositeName: name,
      foodItems: foodList,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'food_name_zh': foodNameZh,
      'food_items': foodItems.map((item) => item.toJson()).toList(),
    };
  }
}