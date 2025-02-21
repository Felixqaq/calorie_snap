class Food {
  final int? id;
  final String name;
  final String nameZh;
  final int calories;
  final DateTime dateTime;
  final double? fat;
  final double? carbs;
  final double? protein;
  String? group;

  Food({
    this.id,
    required this.name,
    required this.nameZh,
    required this.calories,
    required this.dateTime,
    this.fat,
    this.carbs,
    this.protein,
    this.group,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameZh': nameZh,
      'calories': calories,
      'dateTime': dateTime.toIso8601String(),
      'fat': fat,
      'carbs': carbs,
      'protein': protein,
      'food_group': group, 
    };
  }

  Food copyWith({
    int? id,
    String? name,
    String? nameZh,
    int? calories,
    DateTime? dateTime,
    double? fat,
    double? carbs,
    double? protein,
    String? group,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      nameZh: nameZh ?? this.nameZh,
      calories: calories ?? this.calories,
      dateTime: dateTime ?? this.dateTime,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      protein: protein ?? this.protein,
      group: group ?? this.group,
    );
  }
}
