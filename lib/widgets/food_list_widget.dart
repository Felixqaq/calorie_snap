import 'package:calorie_snap/models/food.dart';
import 'package:flutter/material.dart';

class FoodListWidget extends StatelessWidget {
  final List<Food> foods;

  const FoodListWidget({
    super.key,
    required this.foods,
  });

  @override
  Widget build(BuildContext context) {
    var formattedDate = DateTime.now().toString().substring(0, 10);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            formattedDate,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).disabledColor
            ),
          ),
        ),
        Expanded(
          child: foods.isEmpty
              ? const Center(
                  child: Text(
                    '今日還未記錄任何食物',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: foods.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final food = foods[foods.length - 1 - index]; 
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
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            food.nameZh,
                            style: TextStyle(fontSize: 18), 
                          ),
                          const SizedBox(width: 4),
                          Text(food.name, style: TextStyle(color: Colors.grey)),
                        ],
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
                ),
        )
      ],
    );
  }
}