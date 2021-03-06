import 'dart:ui';

import 'package:custom_paint/colors.dart';
import 'package:custom_paint/utils/create_animated_path.dart';
import 'package:flutter/material.dart';

class LineChart extends StatefulWidget {
  final List<double> datas;
  final List<String> xAxis;

  const LineChart({
    @required this.datas,
    @required this.xAxis,
  });

  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final _animationPoints = <double>[];

  @override
  void initState() {
    super.initState();
    double begin = 0.0;
    double end = 4.0;

    List<double> datas = widget.datas;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    );

    final interval = 1 / datas.length;

    for (int i = 0; i < datas.length; i++) {
      _animationPoints.add(begin);
      final tween = Tween(begin: begin, end: end);

      Animation<double> animation = tween.animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            interval * i,
            interval * i + interval,
            curve: Curves.ease,
          ),
        ),
      );
      _controller.addListener(() {
        _animationPoints[i] = animation.value;
      });
    }

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(
          painter: LineChartPainter(
            xAxis: widget.xAxis,
            datas: widget.datas,
            animation: _controller,
            points: _animationPoints,
          ),
          child: Container(width: 300, height: 300),
        ),
        SizedBox(height: 48),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            color: Colors.white,
            icon: Icon(Icons.refresh),
            onPressed: () {
              _controller.reset();
              _controller.forward();
            },
          ),
        ),
      ],
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> datas;
  final List<String> xAxis;
  final List<double> points;
  final Animation<double> animation;

  LineChartPainter({
    @required this.datas,
    @required this.xAxis,
    @required this.points,
    @required this.animation,
  }) : super(repaint: animation);

  void drawLines(Canvas canvas, Size size) {
    final sw = size.width;
    final sh = size.height;
    final gap = sw / datas.length;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.5;

    final path = Path()..moveTo(gap / 2, sh - datas[0]);

    for (int i = 1; i < datas.length; i++) {
      final data = datas[i];
      final x = gap * i + gap / 2;
      final y = sh - data;

      path.lineTo(x, y);
    }

    canvas.drawPath(createAnimatedPath(path, animation.value), paint);
  }

  void drawPoints(Canvas canvas, Size size) {
    final sw = size.width;
    final sh = size.height;
    final gap = sw / datas.length;

    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    for (int i = 0; i < datas.length; i++) {
      paint.color = colors[i];
      final data = datas[i];
      final dx = 0.0;
      final dy = sh - data;
      final offset = Offset(dx + gap * i + gap / 2, dy);

      canvas.drawCircle(offset, points[i], paint);

      final textOffset = Offset(dx + gap * i + 14, dy - 30);
      TextPainter(
        text: TextSpan(
          text: '$data',
          style: TextStyle(
            fontSize: points[i] * 3,
            color: Colors.black87,
          ),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout(
          minWidth: 0,
          maxWidth: size.width,
        )
        ..paint(canvas, textOffset);

      final xData = xAxis[i];
      final xOffset = Offset(dx + gap * i + 14, sh);

      TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: '$xData',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout(
          minWidth: 0,
          maxWidth: size.width,
        )
        ..paint(canvas, xOffset);
    }
  }

  void drawAxis(Canvas canvas, Size size) {
    final sw = size.width;
    final sh = size.height;
    final gap = 10.0;

    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final path = Path()
      ..moveTo(0.0 + gap, 0.0 + gap)
      ..lineTo(0.0 + gap, sh - gap)
      ..lineTo(sw - gap, sh - gap);

    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawAxis(canvas, size);
    drawLines(canvas, size);
    drawPoints(canvas, size);
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(LineChartPainter oldDelegate) => false;
}
