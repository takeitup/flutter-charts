import 'package:flutter/material.dart';

import '../charts/bar_chart.dart';

class BarChartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      data: [180.0, 98.0, 126.0, 64.0, 118.0],
      xAxis: ['一月', '二月', '三月', '四月', '五月'],
    );
  }
}
