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
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularPercentIndicator(
              radius: 120.0, // 增加半徑
              lineWidth: 15.0, // 增加線條寬度
              animation: true,
              percent: (_todayCalories <= 2400) ? _todayCalories / 2400 : 1.0,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_todayCalories kcal',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    '/ 2400 kcal',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.greenAccent, // 更改進度條顏色
              backgroundColor: Colors.grey.shade300, // 更改背景顏色
            ),
            if (_todayCalories > 2400)
              CircularPercentIndicator(
                radius: 120.0,
                lineWidth: 15.0,
                animation: true,
                percent: (_todayCalories - 2400) / 2400,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.redAccent, // 更改進度條顏色
                backgroundColor: Colors.transparent,
              ),
          ],
        ),
      ),
    );
  }
}