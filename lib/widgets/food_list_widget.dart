
import 'package:flutter/material.dart';
import '../food_db.dart';

class FoodListWidget extends StatelessWidget {
  final List<Food> foods;

  const FoodListWidget({
    super.key,
    required this.foods,
  });

  @override
  Widget build(BuildContext context) {
    if (foods.isEmpty) {
      return const Center(
        child: Text(
          '今日還未記錄任何食物',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: foods.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final food = foods[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://picsum.photos/56',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.fastfood),
            ),
          ),
          title: Text(
            food.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${food.calories} 卡路里',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          trailing: Text(
            food.dateTime.toString().substring(11, 16),
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }
}