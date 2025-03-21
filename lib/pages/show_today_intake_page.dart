import 'package:calorie_snap/models/food.dart';
import 'package:calorie_snap/providers/calorie_provider.dart';
import 'package:calorie_snap/utils/app_bar.dart';
import 'package:calorie_snap/widgets/circular_calorie_indicator.dart';
import 'package:calorie_snap/widgets/food_list_widget.dart';
import 'package:calorie_snap/widgets/weekly_calorie_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class ShowTodayIntakePage extends StatefulWidget {
  const ShowTodayIntakePage({super.key});

  @override
  State<ShowTodayIntakePage> createState() => _ShowTodayIntakePageState();
}

class _ShowTodayIntakePageState extends State<ShowTodayIntakePage> {
  final int _targetCalories = 2400;

  @override
  void initState() {
    super.initState();
    _loadTodayCalories();
  }

  DateTime _getTodayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _getStartOfWeekDate() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  Future<void> _loadTodayCalories() async {
    Provider.of<CalorieProvider>(context, listen: false).loadFoods();
  }

  Future<List<Food>> _loadTodayFoods() async {
    final today = _getTodayDate();
    return Provider.of<CalorieProvider>(context, listen: false)
        .getFoodsByDate(today);
  }

  Future<Map<String, dynamic>> _loadWeeklyCalories() async {
    final startOfWeek = _getStartOfWeekDate();
    List<FlSpot> spots = [];
    List<DateTime> dates = [];
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      dates.add(date);
      final foods = await Provider.of<CalorieProvider>(context, listen: false)
          .getFoodsByDate(date);
      final dayCalories = foods.fold(0, (sum, food) => sum + food.calories);
      spots.add(FlSpot(i.toDouble(), dayCalories.toDouble()));
    }
    return {
      'spots': spots,
      'dates': dates,
    };
  }

  Widget _buildWeeklyChart() {
    return Consumer<CalorieProvider>(
      builder: (context, calorieProvider, child) {
        return FutureBuilder<Map<String, dynamic>>(
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
        );
      },
    );
  }

  Widget _buildFoodList() {
    return Consumer<CalorieProvider>(
      builder: (context, calorieProvider, child) {
        return FutureBuilder<List<Food>>(
          future: _loadTodayFoods(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final foods = snapshot.data ?? [];
            
            return FoodListWidget(foods: foods);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Daily Intake'),
      body: RefreshIndicator(
        onRefresh: _loadTodayCalories,
        child: Column(
          children: [
            Container(
              height: 300,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Consumer<CalorieProvider>(
                      builder: (context, calorieProvider, child) {
                        return CircularCalorieIndicator(
                          todayCalories: calorieProvider.todayCalories,
                          targetCalories: _targetCalories,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.005),
                  Expanded(
                    child: _buildWeeklyChart(),
                  ),
                ],
              ),
            ),
            // 刪除 _buildGroupSummary 的呼叫，讓 FoodListWidget 同時顯示群組摘要與清單
            Expanded(
              flex: 1,
              child: _buildFoodList(),
            ),
          ],
        ),
      ),
    );
  }
}
