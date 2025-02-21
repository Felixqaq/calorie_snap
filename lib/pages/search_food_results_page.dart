import 'package:calorie_snap/models/food_info.dart';
import 'package:calorie_snap/services/food_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calorie_provider.dart';

class SearchFoodResultsPage extends StatefulWidget {
  final List<FoodInfo> results;

  const SearchFoodResultsPage({Key? key, required this.results}) : super(key: key);

  @override
  _SearchFoodResultsPageState createState() => _SearchFoodResultsPageState();
}

class _SearchFoodResultsPageState extends State<SearchFoodResultsPage> {
  void _addFood(BuildContext context, FoodInfo item, int index) {
    final food = FoodService.parseFood(item);
    Provider.of<CalorieProvider>(context, listen: false).addFood(food);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.foodNameZh} 已新增')),
    );
    setState(() {
      widget.results.removeAt(index);
      if (widget.results.isEmpty) {
        Navigator.pop(context);
      }
    });
  }

  void _addAllFoods(BuildContext context) {
    if (widget.results.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final calorieProvider = Provider.of<CalorieProvider>(context, listen: false);
    for (var item in widget.results) {
      final food = FoodService.parseFood(item);
      calorieProvider.addFood(food);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('所有食物已新增')),
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
                itemCount: widget.results.length,
                itemBuilder: (context, index) {
                  final item = widget.results[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            item.foodNameZh,
                            style: TextStyle(fontSize: 18), 
                          ),
                          const SizedBox(width: 8),
                          Text(item.foodName, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
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
                      onTap: () => _addFood(context, item, index),
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
