class Food {
  final int? id;
  final String name;
  final int calories;
  final DateTime dateTime;
  final double? fat;
  final double? carbs;
  final double? protein;

  Food({
    this.id,
    required this.name,
    required this.calories,
    required this.dateTime,
    this.fat,
    this.carbs,
    this.protein,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'dateTime': dateTime.toIso8601String(),
      'fat': fat,
      'carbs': carbs,
      'protein': protein,
    };
  }
}
