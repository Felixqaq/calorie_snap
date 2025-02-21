import 'package:calorie_snap/models/food.dart';
import 'package:calorie_snap/providers/calorie_provider.dart';
import 'package:calorie_snap/utils/app_bar.dart';
import 'package:calorie_snap/utils/group_manager.dart';
import 'package:calorie_snap/widgets/food_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calorie_snap/widgets/food_details_dialog.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key, required this.title});

  final String title;

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  bool isMultiSelectMode = false;
  List<int> selectedItems = [];

  late GroupManager groupManager;

  @override
  void initState() {
    super.initState();
    Provider.of<CalorieProvider>(context, listen: false).loadFoods();
    groupManager = GroupManager(context, selectedItems, _clearSelection);
  }

  Future<void> _showAddFoodDialog() async {
    await FoodDialogs.showAddFoodDialog(context);
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

  void _clearSelection(List<int> items) {
    setState(() {
      items.clear();
      isMultiSelectMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('food_page.dart: build method called');
    final foods = Provider.of<CalorieProvider>(context).foods;
    final groupedFoods = groupManager.groupFoodsByDateAndGroup(foods);
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
              title: _buildDateTitle(dateKey, totalCaloriesForDate),
              children: groupedFoods[dateKey]!.entries.expand<Widget>((entry) {
                final groupKey = entry.key;
                final groupFoods = entry.value;
                return _buildGroupTiles(groupKey, groupFoods);
              }).toList(),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: isMultiSelectMode ? _buildBottomAppBar() : null,
      floatingActionButton: isMultiSelectMode ? null : _buildFloatingActionButton(),
    );
  }

  Row _buildDateTitle(DateTime dateKey, int totalCaloriesForDate) {
    return Row(
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
    );
  }

  List<Widget> _buildGroupTiles(String groupKey, List<Food> groupFoods) {
    if (groupKey.isEmpty) {
      return groupFoods.map((food) => _buildFoodTile(food)).toList();
    } else {
      return [
        ExpansionTile(
          initiallyExpanded: true,
          title: _buildGroupTitle(groupKey, groupFoods),
          children: groupFoods.map((food) => _buildFoodTile(food)).toList(),
        )
      ];
    }
  }

  Row _buildGroupTitle(String groupKey, List<Food> groupFoods) {
    return Row(
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
    );
  }

  GestureDetector _buildFoodTile(Food food) {
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
          FoodDetailsDialog.show(context, food);
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
  }

  BottomAppBar _buildBottomAppBar() {
    return BottomAppBar(
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
                onPressed: groupManager.showGroupDialog,
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: groupManager.cancelGroupForSelectedItems,
              ),
            ],
          ),
        ],
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showAddFoodDialog,
      tooltip: '新增食物',
      child: const Icon(Icons.add),
    );
  }
}
