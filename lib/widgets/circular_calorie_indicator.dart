
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CircularCalorieIndicator extends StatelessWidget {
  final int todayCalories;
  final int targetCalories;

  const CircularCalorieIndicator({
    super.key,
    required this.todayCalories,
    required this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildMainIndicator(),
        if (todayCalories > targetCalories) _buildExcessIndicator(),
      ],
    );
  }

  Widget _buildMainIndicator() {
    return CircularPercentIndicator(
      radius: 120.0,
      lineWidth: 15.0,
      animation: true,
      percent: (todayCalories <= targetCalories) ? todayCalories / targetCalories : 1.0,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$todayCalories kcal',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('/ $targetCalories kcal',
              style: const TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.greenAccent,
      backgroundColor: Colors.grey.shade300,
    );
  }

  Widget _buildExcessIndicator() {
    return CircularPercentIndicator(
      radius: 120.0,
      lineWidth: 15.0,
      animation: true,
      percent: (todayCalories <= 2 * targetCalories) 
          ? (todayCalories - targetCalories) / targetCalories 
          : 1,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.redAccent,
      backgroundColor: Colors.transparent,
    );
  }
}