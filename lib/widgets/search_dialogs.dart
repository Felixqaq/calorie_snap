import 'package:flutter/material.dart';
import '../services/food_service.dart';
import '../food_db.dart';

class SearchDialogs {
  static Future<void> showSearchFoodDialog(BuildContext context, FoodService foodService) async {
    final searchController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '搜尋食物',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(labelText: '食物名稱'),
          ),
          actions: [
            _buildDialogButton('取消', () => Navigator.of(context).pop()),
            _buildDialogButton('搜尋', () async {
              final query = searchController.text;
              if (query.isNotEmpty) {
                final results = await foodService.searchFood(query);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _showSearchResults(context, results);
                }
              }
            }),
          ],
        );
      },
    );
  }

  static Food parseFoodInfo(FoodInfoItem item) {
    return Food(
      name: item.foodName,
      calories: int.parse(item.calories.replaceAll('kcal', '').trim()),
      dateTime: DateTime.now(),
      fat: double.tryParse(item.fat.replaceAll('g', '').trim()),
      carbs: double.tryParse(item.carbs.replaceAll('g', '').trim()),
      protein: double.tryParse(item.protein.replaceAll('g', '').trim()),
    );
  }

  static void _showSearchResults(BuildContext context, List<FoodInfoItem> results) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '搜尋結果',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          content: Column(
            children: [
              Expanded(
                child: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return ListTile(
                        title: Text(
                          item.foodName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.weight,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.local_fire_department),
                                SizedBox(width: 5),
                                Text(
                                  item.calories,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                SizedBox(width: 20),
                                Icon(Icons.opacity),
                                SizedBox(width: 5),
                                Text(
                                  item.fat,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.fastfood),
                                SizedBox(width: 5),
                                Text(
                                  item.carbs,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                SizedBox(width: 20),
                                Icon(Icons.fitness_center),
                                SizedBox(width: 5),
                                Text(
                                  item.protein,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () async {
                          final foodDb = FoodDatabase.instance;
                          final food = parseFoodInfo(item);
                          await foodDb.insertFood(food);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${item.foodName} 已加入')),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.local_fire_department, size: 16),
                  Text('Calories',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 12, color: Colors.grey)),
                  Icon(Icons.opacity, size: 16),
                  Text('Fat',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 12, color: Colors.grey)),
                  Icon(Icons.fastfood, size: 16),
                  Text('Carbs',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 12, color: Colors.grey)),
                  Icon(Icons.fitness_center, size: 16),
                  Text('Protein',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          actions: [
            _buildDialogButton('關閉', () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }

  static TextButton _buildDialogButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}