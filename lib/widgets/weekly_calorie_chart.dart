import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeeklyCalorieChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<DateTime> dates;  // 新增日期列表參數

  const WeeklyCalorieChart({
    super.key,
    required this.spots,
    required this.dates,  // 新增參數
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            minY: 0,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
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
                    final index = value.toInt();
                    if (index >= 0 && index < dates.length) {
                      final weekDay = ['一', '二', '三', '四', '五', '六', '日'][dates[index].weekday - 1];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${DateFormat('M/d').format(dates[index])}\n$weekDay',
                          style: const TextStyle(fontSize: 8),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const Text('');
                  },
                  reservedSize: 32,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 1000,
                  getTitlesWidget: (value, meta) {
                    if (value % 1000 == 0 && value <= 3000 && value > 0) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}