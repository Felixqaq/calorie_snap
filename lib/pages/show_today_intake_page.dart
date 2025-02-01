import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../food_db.dart';
import '../providers/calorie_provider.dart';
import '../widgets/circular_calorie_indicator.dart';
import '../widgets/weekly_calorie_chart.dart';
import '../widgets/food_list_widget.dart';

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

  Future<Map<String, dynamic>> _loadWeeklyCalories() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    List<FlSpot> spots = [];
    List<DateTime> dates = [];
    
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      dates.add(date);
      final foods = await _foodDb.getFoodsByDate(date);
      final dayCalories = foods.fold(0, (sum, food) => sum + food.calories);
      spots.add(FlSpot(i.toDouble(), dayCalories.toDouble()));
    }
    return {
      'spots': spots,
      'dates': dates,
    };
  }

  Future<List<Food>> _loadTodayFoods() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return await _foodDb.getFoodsByDate(today);
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
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: Consumer<CalorieProvider>(
                      builder: (context, calorieProvider, child) {
                        return CircularCalorieIndicator(
                          todayCalories: calorieProvider.todayCalories,
                          targetCalories: _targetCalories,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),  // 添加間距
                  Flexible(
                    flex: 1,
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: _loadWeeklyCalories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData) {
                          return const Center(child: Text('無資料'));
                        }
                        return WeeklyCalorieChart(
                          spots: snapshot.data!['spots'],
                          dates: snapshot.data!['dates'],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Food>>(
                future: _loadTodayFoods(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  
                  return FoodListWidget(foods: snapshot.data ?? []);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
