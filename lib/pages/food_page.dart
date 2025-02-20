import 'package:calorie_snap/models/food.dart';
import 'package:calorie_snap/providers/calorie_provider.dart';
import 'package:calorie_snap/utils/app_bar.dart';
import 'package:calorie_snap/widgets/food_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key, required this.title});

  final String title;

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<CalorieProvider>(context, listen: false).loadFoods();
  }

  Future<void> _showAddFoodDialog() async {
    await FoodDialogs.showAddFoodDialog(context);
  }

  Future<void> _showEditFoodDialog(Food food) async {
    await FoodDialogs.showEditFoodDialog(context, food);
  }

  @override
  Widget build(BuildContext context) {
    final foods = Provider.of<CalorieProvider>(context).foods;
    Map<String, List<Food>> groupedFoods = {};
    Map<String, int> totalCaloriesPerDay = {};

    for (var food in foods) {
      String date = '${food.dateTime.year}-${food.dateTime.month.toString().padLeft(2, '0')}-${food.dateTime.day.toString().padLeft(2, '0')}';
      if (!groupedFoods.containsKey(date)) {
        groupedFoods[date] = [];
        totalCaloriesPerDay[date] = 0;
      }
      groupedFoods[date]!.add(food);
      totalCaloriesPerDay[date] = totalCaloriesPerDay[date]! + food.calories;
    }

    return Scaffold(
      appBar: buildAppBar(context, widget.title),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: groupedFoods.keys.map((date) {
            return ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${totalCaloriesPerDay[date]}',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              children: groupedFoods[date]!.map((food) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(food.name[0]),
                    ),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          food.nameZh,
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(food.name, style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('${food.calories} 卡路里'),
                        const SizedBox(height: 8),
                        Text(
                          '${food.dateTime.year}-${food.dateTime.month.toString().padLeft(2, '0')}-${food.dateTime.day.toString().padLeft(2, '0')} ${food.dateTime.hour.toString().padLeft(2, '0')}:${food.dateTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await Provider.of<CalorieProvider>(context,
                                    listen: false)
                                .deleteFood(food.id!);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditFoodDialog(food),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        tooltip: '新增食物',
        child: const Icon(Icons.add),
      ),
    );
  }
}
