import 'package:flutter/material.dart';
import 'package:calorie_snap/models/food.dart';

class FoodListWidget extends StatelessWidget {
  final List<Food> foods;

  const FoodListWidget({
    Key? key,
    required this.foods,
  }) : super(key: key);

  String _formatTime(DateTime dateTime) {
    return dateTime.toString().substring(11, 16);
  }

  List<Food> _computeMergedList() {
    final sortedFoods = List<Food>.from(foods)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final insertedGroups = <String>{};
    final mergedList = <Food>[];
    final groupMap = <String, List<Food>>{};
    for (var food in sortedFoods) {
      if (food.group?.isNotEmpty ?? false) {
        groupMap.putIfAbsent(food.group!, () => []).add(food);
      }
    }
    for (var food in sortedFoods) {
      if (food.group?.isNotEmpty ?? false) {
        if (!insertedGroups.contains(food.group)) {
          insertedGroups.add(food.group!);
          final groupFoods = groupMap[food.group!]!;
          final totalCalories = groupFoods.fold(0, (sum, f) => sum + f.calories);
          final latestTime = groupFoods
              .map((f) => f.dateTime)
              .reduce((a, b) => a.isAfter(b) ? a : b);
          final summaryFood = Food(
            name: '',
            nameZh: food.group!,
            calories: totalCalories,
            dateTime: latestTime,
            group: food.group,
          );
          mergedList.add(summaryFood);
        }
      }
      if(food.group == "")mergedList.add(food);
    }
    return mergedList;
  }

  Widget _buildFoodListTile(Food item) {
    final leadingText = item.name.isEmpty ? item.nameZh[0] : item.name[0];
    return ListTile(
      leading: CircleAvatar(child: Text(leadingText)),
      title: Text(item.nameZh),
      subtitle: Text('${item.calories} 卡路里'),
      trailing: Text(
        _formatTime(item.dateTime),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  Widget _buildMergedFoodList(BuildContext context) {
    final mergedList = _computeMergedList();
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: mergedList.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = mergedList[index];
        return _buildFoodListTile(item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateTime.now().toString().substring(0, 10);

    return Column(
      children: [
        // 日期顯示字串
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            formattedDate,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).disabledColor,
            ),
          ),
        ),
        // 移除原有群組總結區塊，改用合併列表顯示
        Expanded(
          child: foods.isEmpty
              ? const Center(
                  child: Text(
                    '今日還未記錄任何食物',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                )
              : _buildMergedFoodList(context),
        )
      ],
    );
  }
}