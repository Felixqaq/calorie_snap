import 'package:calorie_snap/models/food_info_item.dart';
import 'package:calorie_snap/services/food_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calorie_provider.dart';

class SearchFoodResultsPage extends StatelessWidget {
  final List<FoodInfoItem> results;

  const SearchFoodResultsPage({Key? key, required this.results})
      : super(key: key);

  void _addFood(BuildContext context, FoodInfoItem item) {
    final food = FoodService.parseFood(item);
    Provider.of<CalorieProvider>(context, listen: false).addFood(food);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.foodName} added')),
    );
  }

  void _addAllFoods(BuildContext context) {
    final calorieProvider =
        Provider.of<CalorieProvider>(context, listen: false);
    for (var item in results) {
      final food = FoodService.parseFood(item);
      calorieProvider.addFood(food);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All foods added')),
    );
    Navigator.pop(context);
  }

  static Row _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(Icons.scale, size: 16),
        Text('Weight',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 12, color: Colors.grey)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addAllFoods(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLegend(context),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(item.foodName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.scale, size: 16),
                              const SizedBox(width: 4),
                              Text(item.weight),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.local_fire_department, size: 16),
                              const SizedBox(width: 4),
                              Text(item.calories),
                              const SizedBox(width: 20),
                              Icon(Icons.opacity, size: 16),
                              const SizedBox(width: 4),
                              Text(item.fat),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.fastfood, size: 16),
                              const SizedBox(width: 4),
                              Text(item.carbs),
                              const SizedBox(width: 20),
                              Icon(Icons.fitness_center, size: 16),
                              const SizedBox(width: 4),
                              Text(item.protein),
                            ],
                          ),
                        ],
                      ),
                      onTap: () => _addFood(context, item),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
