import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../food_db.dart';
import '../providers/calorie_provider.dart';
import '../widgets/circular_calorie_indicator.dart';
import '../widgets/weekly_calorie_chart.dart';

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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final foods = await _foodDb.getFoodsByDate(today);
    final todayCalories = foods.fold(0, (sum, food) => sum + food.calories);
    if (mounted) {
      Provider.of<CalorieProvider>(context, listen: false).updateCalories(todayCalories);
    }
  }

  Future<List<FlSpot>> _loadWeeklyCalories() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final foods = await _foodDb.getFoodsByDate(date);
      final dayCalories = foods.fold(0, (sum, food) => sum + food.calories);
      spots.add(FlSpot(i.toDouble(), dayCalories.toDouble()));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Intake',
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Consumer<CalorieProvider>(
                  builder: (context, calorieProvider, child) {
                    return CircularCalorieIndicator(
                      todayCalories: calorieProvider.todayCalories,
                      targetCalories: _targetCalories,
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: 250,
              child: FutureBuilder<List<FlSpot>>(
                future: _loadWeeklyCalories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available'));
                  }
                  return WeeklyCalorieChart(spots: snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
