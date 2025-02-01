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
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth * 0.7;
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildMainIndicator(size),
            if (todayCalories > targetCalories) _buildExcessIndicator(size),
          ],
        );
      },
    );
  }

  Widget _buildMainIndicator(double size) {
    return CircularPercentIndicator(
      radius: size / 2,
      lineWidth: size / 15,
      animation: true,
      percent: (todayCalories <= targetCalories) ? todayCalories / targetCalories : 1.0,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$todayCalories kcal',
            style: TextStyle(
              fontSize: size / 10,
              fontWeight: FontWeight.bold
            ),
          ),
          Text(
            '/ $targetCalories kcal',
            style: TextStyle(
              fontSize: size / 15,
              color: Colors.black54
            ),
          ),
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.greenAccent,
      backgroundColor: Colors.grey.shade300,
    );
  }

  Widget _buildExcessIndicator(double size) {
    return CircularPercentIndicator(
      radius: size / 2,
      lineWidth: size / 15,
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