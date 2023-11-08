import 'package:alati_app/Tabs/line_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

//placeholder za funkciju
class Tab3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          LineChartSample7(),
          ElevatedButton(
            onPressed: () {
              final math.Random random = math.Random();
              final int dataPointCount = 5;
              List<DataPoint> dataPoints = [];

              for (int i = 0; i < dataPointCount; i++) {
                dataPoints.add(DataPoint('Item $i', random.nextDouble()));
              }

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Report'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: dataPoints
                        .map(
                          (point) => ListTile(
                            title: Text(point.label),
                            subtitle: LinearProgressIndicator(
                              value: point.value,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.maybePop(context);
                      },
                      child: Text('Close'),
                    )
                  ],
                ),
              );
            },
            child: Text('Get Report'),
          ),
        ],
      ),
    );
  }
}

class DataPoint {
  final String label;
  final double value;

  DataPoint(this.label, this.value);
}
