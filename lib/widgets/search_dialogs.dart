import 'package:flutter/material.dart';
import '../services/food_service.dart';

class SearchDialogs {
  static Future<void> showSearchFoodDialog(BuildContext context, FoodService foodService) async {
    final searchController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('搜尋食物'),
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
                Navigator.of(context).pop();
                _showSearchResults(context, results);
              }
            }),
          ],
        );
      },
    );
  }

  static void _showSearchResults(BuildContext context, List<FoodInfoItem> results) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('搜尋結果'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];
                return ListTile(
                  title: Text(item.foodName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.scale),
                          SizedBox(width: 5),
                          Text('Weight: ${item.weight}'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.local_fire_department),
                          SizedBox(width: 5),
                          Text('Calories: ${item.calories}'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.opacity),
                          SizedBox(width: 5),
                          Text('Fat: ${item.fat}'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.fastfood),
                          SizedBox(width: 5),
                          Text('Carbs: ${item.carbs}'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.fitness_center),
                          SizedBox(width: 5),
                          Text('Protein: ${item.protein}'),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop(item);
                  },
                );
              },
            ),
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