import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeeklyCalorieChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<DateTime> dates; 

  const WeeklyCalorieChart({
    super.key,
    required this.spots,
    required this.dates,  
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
                color: Colors.greenAccent,
                barWidth: 2,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(show: true, color: Colors.greenAccent.withOpacity(0.1)),
                dotData: FlDotData(show: false),
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
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('M/d').format(dates[index]),
                              style: const TextStyle(fontSize: 10, color: Colors.black),
                            ),
                            Text(
                              weekDay,
                              style: const TextStyle(fontSize: 10, color: Colors.black),
                            ),
                          ],
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
                        style: const TextStyle(fontSize: 10, color: Colors.black),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            }),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}