import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartCapacity extends StatelessWidget {
  LineChartCapacity({
    Color? line1Color,
    Color? line2Color,
    Color? betweenColor,
  })  : line1Color = line1Color ?? Colors.green,
        line2Color = line2Color ?? Colors.red,
        betweenColor = betweenColor ?? Colors.red.withOpacity(0.5);

  final Color line1Color;
  final Color line2Color;
  final Color betweenColor;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 18,
          right: 18,
          top: 10,
          bottom: 4,
        ),
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 4),
                  FlSpot(1, 3.5),
                  FlSpot(2, 4.5),
                  FlSpot(3, 1),
                  FlSpot(4, 4),
                  FlSpot(5, 6),
                  FlSpot(6, 6.5),
                  FlSpot(7, 6),
                  FlSpot(8, 4),
                  FlSpot(9, 6),
                  FlSpot(10, 6),
                  FlSpot(11, 7),
                ],
                isCurved: false,
                barWidth: 2,
                colors: [
                  line1Color,
                ],
                dotData: FlDotData(
                  show: false,
                ),
              ),
              LineChartBarData(
                spots: const [
                  FlSpot(0, 7),
                  FlSpot(1, 3),
                  FlSpot(2, 4),
                  FlSpot(3, 2),
                  FlSpot(4, 3),
                  FlSpot(5, 4),
                  FlSpot(6, 5),
                  FlSpot(7, 3),
                  FlSpot(8, 1),
                  FlSpot(9, 8),
                  FlSpot(10, 1),
                  FlSpot(11, 3),
                ],
                isCurved: false,
                barWidth: 2,
                colors: [line2Color],
                dotData: FlDotData(
                  show: false,
                ),
              ),
              LineChartBarData(
                spots: const [
                  FlSpot(0, 4),
                  FlSpot(1, 5),
                  FlSpot(2, 6),
                  FlSpot(3, 7),
                  FlSpot(4, 2),
                  FlSpot(5, 5),
                  FlSpot(6, 3),
                  FlSpot(7, 7),
                  FlSpot(8, 3),
                  FlSpot(9, 6),
                  FlSpot(10, 3),
                  FlSpot(11, 3),
                ],
                isCurved: false,
                barWidth: 2,
                colors: [Colors.orange],
                dotData: FlDotData(
                  show: false,
                ),
              ),
            ],
            betweenBarsData: [
              BetweenBarsData(
                fromIndex: 0,
                toIndex: 1,
                colors: [Colors.transparent],
              )
            ],
            minY: 0,
            borderData: FlBorderData(
              show: false,
            ),
            titlesData: FlTitlesData(
              bottomTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitles: (v) => 'CW ' + (v + 30).toString(),
              ),
              leftTitles: SideTitles(
                showTitles: true,
                getTitles: (value) => (value * 10000 + 5000).toString(),
                interval: 1,
                reservedSize: 50,
              ),
              topTitles: SideTitles(showTitles: false),
              rightTitles: SideTitles(showTitles: false),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              checkToShowHorizontalLine: (double value) {
                return value == 1 || value == 6 || value == 4 || value == 5;
              },
            ),
          ),
        ),
      ),
    );
  }
}
