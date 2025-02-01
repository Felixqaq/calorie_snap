import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../food_db.dart';
import '../providers/calorie_provider.dart';

class ShowTodayIntakePage extends StatefulWidget {
  const ShowTodayIntakePage({super.key});

  @override
  State<ShowTodayIntakePage> createState() => _ShowTodayIntakePageState();
}

class _ShowTodayIntakePageState extends State<ShowTodayIntakePage> {
  final FoodDatabase _foodDb = FoodDatabase.instance;
  int _targetCalories = 2400;

  @override
  void initState() {
    super.initState();
    _loadTodayCalories();
  }

  Future<void> _loadTodayCalories() async {
    final today = DateTime.now();
    final foods = await _foodDb.getFoodsByDate(today);
    final todayCalories = foods.fold(0, (sum, food) => sum + food.calories);
    Provider.of<CalorieProvider>(context, listen: false).updateCalories(todayCalories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '今日攝取熱量',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTodayCalories,
        child: Center(
          child: Consumer<CalorieProvider>(
            builder: (context, calorieProvider, child) {
              final _todayCalories = calorieProvider.todayCalories;
              return Stack(
                alignment: Alignment.center,
                children: [
                  _buildCircularIndicator(_todayCalories),
                  if (_todayCalories > _targetCalories)
                    _buildExcessCaloriesIndicator(_todayCalories),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCircularIndicator(int todayCalories) {
    return CircularPercentIndicator(
      radius: 120.0,
      lineWidth: 15.0,
      animation: true,
      percent: (todayCalories <= _targetCalories) ? todayCalories / _targetCalories : 1.0,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$todayCalories kcal',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            '/ $_targetCalories kcal',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.greenAccent,
      backgroundColor: Colors.grey.shade300,
    );
  }

  Widget _buildExcessCaloriesIndicator(int todayCalories) {
    return CircularPercentIndicator(
      radius: 120.0,
      lineWidth: 15.0,
      animation: true,
      percent: (todayCalories <= 2 * _targetCalories) ? (todayCalories - _targetCalories) / _targetCalories : 1,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.redAccent,
      backgroundColor: Colors.transparent,
    );
  }
}