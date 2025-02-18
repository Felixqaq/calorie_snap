class FoodInfoItem {
  final String foodName;
  final String weight;
  final String calories;
  final String fat;
  final String carbs;
  final String protein;

  FoodInfoItem({
    required this.foodName,
    required this.weight,
    required this.calories,
    required this.fat,
    required this.carbs,
    required this.protein,
  });

  factory FoodInfoItem.fromJson(Map<String, dynamic> json) {
    return FoodInfoItem(
      foodName: json['food_name'],
      weight: json['weight'],
      calories: json['calories'],
      fat: json['fat'],
      carbs: json['carbs'],
      protein: json['protein'],
    );
  }
}

class CompositeFoodInfoItem {
  final List<FoodInfoItem> foodItems;

  CompositeFoodInfoItem({required this.foodItems});

  factory CompositeFoodInfoItem.fromJson(List<dynamic> jsonList) {
    List<FoodInfoItem> items =
        jsonList.map((json) => FoodInfoItem.fromJson(json)).toList();
    return CompositeFoodInfoItem(foodItems: items);
  }
}
