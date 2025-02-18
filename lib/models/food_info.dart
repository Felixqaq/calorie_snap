abstract class FoodInfo {
  String get foodName;
  List<FoodInfo> get foodItems;
  String get weight;
  String get calories;
  String get fat;
  String get carbs;
  String get protein;
  Map<String, dynamic> toJson();
  
  factory FoodInfo.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson() has not been implemented.');
  }
}