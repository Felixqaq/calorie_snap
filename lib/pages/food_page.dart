import 'package:calorie_snap/food.dart';
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
    return Scaffold(
      appBar: buildAppBar(context, widget.title),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index];
            final previousFood = index > 0 ? foods[index - 1] : null;
            final isNewDay = previousFood == null ||
                food.dateTime.day != previousFood.dateTime.day;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isNewDay)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '${food.dateTime.year}-${food.dateTime.month.toString().padLeft(2, '0')}-${food.dateTime.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(food.name[0]),
                    ),
                    title: Text(
                      food.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                ),
              ],
            );
          },
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
