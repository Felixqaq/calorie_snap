import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../food_db.dart';

class ShowTodayIntakePage extends StatefulWidget {
  const ShowTodayIntakePage({super.key});

  @override
  State<ShowTodayIntakePage> createState() => _ShowTodayIntakePageState();
}

class _ShowTodayIntakePageState extends State<ShowTodayIntakePage> {
  final FoodDatabase _foodDb = FoodDatabase.instance;
  int _todayCalories = 0;

  @override
  void initState() {
    super.initState();
    _loadTodayCalories();
  }

  Future<void> _loadTodayCalories() async {
    final today = DateTime.now();
    final foods = await _foodDb.getFoodsByDate(today);
    setState(() {
      _todayCalories = foods.fold(0, (sum, food) => sum + food.calories);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日攝取熱量'),
      ),
      body: Center(
        child: CircularPercentIndicator(
          radius: 100.0,
          lineWidth: 13.0,
          animation: true,
          percent: _todayCalories / 2400,
          center: Text(
            '$_todayCalories / 2400 卡路里',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: Colors.green,
        ),
      ),
    );
  }
}