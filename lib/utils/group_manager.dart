import 'package:calorie_snap/models/food.dart';
import 'package:calorie_snap/providers/calorie_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupManager {
  final BuildContext context;
  final List<int> selectedItems;
  final Function(List<int>) clearSelection;

  GroupManager(this.context, this.selectedItems, this.clearSelection);

  Future<void> showGroupDialog() async {
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

  Future<void> cancelGroupForSelectedItems() async {
    await _updateGroupForItems('');
  }

  Future<void> _updateGroupForSelectedItems(String groupName) async {
    await _updateGroupForItems(groupName);
  }

  Future<void> _updateGroupForItems(String groupName) async {
    final calorieProvider = Provider.of<CalorieProvider>(context, listen: false);
    for (var id in selectedItems) {
      final food = calorieProvider.foods.firstWhere((food) => food.id == id);
      final updatedFood = food.copyWith(group: groupName);
      await calorieProvider.updateFood(updatedFood);
    }
    clearSelection(selectedItems);
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
}
