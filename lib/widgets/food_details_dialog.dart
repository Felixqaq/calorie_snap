import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calorie_snap/models/food.dart';
import 'package:calorie_snap/providers/calorie_provider.dart';
import 'package:calorie_snap/widgets/food_dialogs.dart';

class FoodDetailsDialog {
  static void show(BuildContext context, Food food) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: _buildFoodDetailsTitle(context, food),
          content: _buildFoodDetailsContent(food),
        );
      },
    );
  }

  static Row _buildFoodDetailsTitle(BuildContext context, Food food) {
    return Row(
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
                FoodDialogs.showEditFoodDialog(context, food);
              },
            ),
          ],
        ),
      ],
    );
  }

  static Column _buildFoodDetailsContent(Food food) {
    return Column(
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
    );
  }
}
