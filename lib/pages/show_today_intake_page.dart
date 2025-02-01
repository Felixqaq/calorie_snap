import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
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
                  return LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: snapshot.data!,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
                          dotData: FlDotData(show: true),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              return Text(days[value.toInt()], style: TextStyle(fontSize: 12));
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                      ),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                    ),
                  );
                },
              ),
            ),
          ],
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
          Text('$todayCalories kcal',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('/ $_targetCalories kcal',
              style: const TextStyle(fontSize: 16, color: Colors.black54)),
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
