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
  bool isMultiSelectMode = false;
  List<int> selectedItems = [];

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

  void _toggleSelection(int foodId) {
    setState(() {
      if (selectedItems.contains(foodId)) {
        selectedItems.remove(foodId);
        if (selectedItems.isEmpty) {
          isMultiSelectMode = false;
        }
      } else {
        selectedItems.add(foodId);
      }
    });
  }

  void _deleteSelectedItems() async {
    final calorieProvider = Provider.of<CalorieProvider>(context, listen: false);
    for (var id in selectedItems) {
      await calorieProvider.deleteFood(id);
    }
    setState(() {
      selectedItems.clear();
      isMultiSelectMode = false;
    });
  }

  Future<void> _showGroupDialog() async {
    final TextEditingController groupController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('輸入群組名稱'),
          content: TextField(
            controller: groupController,
            decoration: const InputDecoration(labelText: '群組名稱'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                final groupName = groupController.text;
                if (groupName.isNotEmpty) {
                  await _updateGroupForSelectedItems(groupName);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('確定'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateGroupForSelectedItems(String groupName) async {
    final calorieProvider = Provider.of<CalorieProvider>(context, listen: false);
    for (var id in selectedItems) {
      final food = calorieProvider.foods.firstWhere((food) => food.id == id);
      final updatedFood = Food(
        id: food.id,
        name: food.name,
        nameZh: food.nameZh,
        calories: food.calories,
        dateTime: food.dateTime,
        fat: food.fat,
        carbs: food.carbs,
        protein: food.protein,
        group: groupName,
      );
      await calorieProvider.updateFood(updatedFood);
    }
    setState(() {
      selectedItems.clear();
      isMultiSelectMode = false;
    });
  }

  Future<void> _cancelGroupForSelectedItems() async {
    final calorieProvider = Provider.of<CalorieProvider>(context, listen: false);
    for (var id in selectedItems) {
      final food = calorieProvider.foods.firstWhere((food) => food.id == id);
      final updatedFood = Food(
        id: food.id,
        name: food.name,
        nameZh: food.nameZh,
        calories: food.calories,
        dateTime: food.dateTime,
        fat: food.fat,
        carbs: food.carbs,
        protein: food.protein,
        group: '', 
      );
      await calorieProvider.updateFood(updatedFood);
    }
    setState(() {
      selectedItems.clear();
      isMultiSelectMode = false;
    });
  }

  void _showFoodDetails(Food food) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await Provider.of<CalorieProvider>(context, listen: false).deleteFood(food.id!);
                      Navigator.of(context).pop();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showEditFoodDialog(food);
                    },
                  ),
                ],
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('名稱: ${food.name}'),
              Text('熱量: ${food.calories} 卡路里'),
              Text('脂肪: ${food.fat ?? 0} g'),
              Text('碳水化合物: ${food.carbs ?? 0} g'),
              Text('蛋白質: ${food.protein ?? 0} g'),
              Text(
                '日期: ${food.dateTime.year}-${food.dateTime.month.toString().padLeft(2, '0')}-${food.dateTime.day.toString().padLeft(2, '0')} ${food.dateTime.hour.toString().padLeft(2, '0')}:${food.dateTime.minute.toString().padLeft(2, '0')}',
              ),
              Text('群組: ${food.group ?? "無"}'),
            ],
          ),
        );
      },
    );
  }

  List<Food> sortFoodsByDate(List<Food> foods) {
    foods.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return foods;
  }

  Map<DateTime, Map<String, List<Food>>> groupFoodsByDateAndGroup(List<Food> foods) {
    Map<DateTime, Map<String, List<Food>>> grouped = {};
    for (var food in foods) {
      final dateKey = DateTime(food.dateTime.year, food.dateTime.month, food.dateTime.day);
      final groupKey = food.group ?? '';
      grouped.putIfAbsent(dateKey, () => {});
      grouped[dateKey]!.putIfAbsent(groupKey, () => []);
      grouped[dateKey]![groupKey]!.add(food);
    }
  
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('food_page.dart: build method called');
    final foods = Provider.of<CalorieProvider>(context).foods;
    final groupedFoods = groupFoodsByDateAndGroup(foods);
    return Scaffold(
      appBar: buildAppBar(context, widget.title),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: groupedFoods.keys.map((dateKey) {
            final totalCaloriesForDate = groupedFoods[dateKey]!.values
                .expand((groupFoods) => groupFoods)
                .fold(0, (sum, food) => sum + food.calories);
            return ExpansionTile(
              initiallyExpanded: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${dateKey.year}-${dateKey.month.toString().padLeft(2, '0')}-${dateKey.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$totalCaloriesForDate',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              children: groupedFoods[dateKey]!.entries.expand<Widget>((entry) {
                final groupKey = entry.key;
                final groupFoods = entry.value;
                if (groupKey.isEmpty) {
                  return groupFoods.map((food) {
                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          isMultiSelectMode = true;
                          selectedItems.add(food.id!);
                        });
                      },
                      onTap: () {
                        if (isMultiSelectMode) {
                          _toggleSelection(food.id!);
                        } else {
                          _showFoodDetails(food);
                        }
                      },
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(food.name[0]),
                            ),
                            title: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
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
                            trailing: isMultiSelectMode
                                ? (selectedItems.contains(food.id)
                                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                                    : null)
                                : null,
                          ),
                        ),
                      ),
                    );
                  }).toList();
                } else {
                  return [
                    ExpansionTile(
                      initiallyExpanded: true,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            groupKey,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${groupFoods.fold(0, (sum, food) => sum + food.calories)}',
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      children: groupFoods.map((food) {
                        return GestureDetector(
                          onLongPress: () {
                            setState(() {
                              isMultiSelectMode = true;
                              selectedItems.add(food.id!);
                            });
                          },
                          onTap: () {
                            if (isMultiSelectMode) {
                              _toggleSelection(food.id!);
                            } else {
                              _showFoodDetails(food);
                            }
                          },
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(food.name[0]),
                                ),
                                title: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
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
                                trailing: isMultiSelectMode
                                    ? (selectedItems.contains(food.id)
                                        ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                                        : null)
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  ];
                }
              }).toList(),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: isMultiSelectMode
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteSelectedItems,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.group),
                        onPressed: _showGroupDialog,
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _cancelGroupForSelectedItems, // 新增取消群組的功能
                      ),
                    ],
                  ),
                ],
              ),
            )
          : null,
      floatingActionButton: isMultiSelectMode
          ? null
          : FloatingActionButton(
              onPressed: _showAddFoodDialog,
              tooltip: '新增食物',
              child: const Icon(Icons.add),
            ),
    );
  }
}
