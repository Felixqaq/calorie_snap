import 'package:calorie_snap/food.dart';
import 'package:calorie_snap/providers/calorie_provider.dart';
import 'package:calorie_snap/services/food_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchDialogs {
  static Future<void> showSearchFoodDialog(BuildContext context) async {
    final searchController = TextEditingController();
    final foodService = FoodService();

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

  static void _showSearchResults(
      BuildContext context, List<FoodInfoItem> results) {
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
                      return _buildFoodListItem(context, item);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildLegend(context),
            ],
          ),
          actions: [
            _buildDialogButton('關閉', () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }

  static ListTile _buildFoodListItem(BuildContext context, FoodInfoItem item) {
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
          _buildFoodInfoRow(context, Icons.local_fire_department, item.calories,
              Icons.opacity, item.fat),
          _buildFoodInfoRow(context, Icons.fastfood, item.carbs,
              Icons.fitness_center, item.protein),
        ],
      ),
      onTap: () async {
        final food = parseFoodInfo(item);
        Provider.of<CalorieProvider>(context, listen: false).addFood(food);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.foodName} 已加入')),
        );
      },
    );
  }

  static List<Widget> _buildIconTextPair(
      BuildContext context, IconData icon, String text) {
    return [
      Icon(icon),
      SizedBox(width: 5),
      Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ];
  }

  static Row _buildFoodInfoRow(BuildContext context, IconData icon1,
      String text1, IconData icon2, String text2) {
    return Row(
      children: [
        ..._buildIconTextPair(context, icon1, text1),
        SizedBox(width: 20),
        ..._buildIconTextPair(context, icon2, text2),
      ],
    );
  }

  static Row _buildLegend(BuildContext context) {
    return Row(
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
    );
  }

  static TextButton _buildDialogButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
