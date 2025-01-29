import 'package:flutter/material.dart';
import '../food_db.dart';
import '../utils/app_bar.dart';

class ShowFoodPage extends StatefulWidget {
  const ShowFoodPage({super.key, required this.title});

  final String title;

  @override
  State<ShowFoodPage> createState() => _ShowFoodPageState();
}

class _ShowFoodPageState extends State<ShowFoodPage> {
  final FoodDatabase _foodDb = FoodDatabase.instance;
  List<Food> _foods = [];

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    final foods = await _foodDb.getAllFoods();
    setState(() {
      _foods = foods;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, widget.title),
      body: ListView.builder(
        itemCount: _foods.length,
        itemBuilder: (context, index) {
          final food = _foods[index];
          return ListTile(
            title: Text(food.name),
            subtitle: Text('${food.calories} 卡路里 - ${food.dateTime.toString()}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _foodDb.insertFood(
            Food(
              name: '測試食物',
              calories: 100,
              dateTime: DateTime.now(),
            ),
          );
          _loadFoods();
        },
        tooltip: '新增食物',
        child: const Icon(Icons.add),
      ),
    );
  }
}