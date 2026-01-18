import 'dart:math';
import 'package:flutter/material.dart';

class SignalChart extends StatelessWidget {
  final List<double> data;
  final double frequency;

  const SignalChart({
    Key? key,
    required this.data,
    this.frequency = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(child: Text('No data'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _SignalPainter(data, frequency),
        );
      },
    );
  }
}

class _SignalPainter extends CustomPainter {
  final List<double> data;
  final double frequency;

  _SignalPainter(this.data, this.frequency);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Define margins for axes
    const double leftMargin = 40.0;
    const double bottomMargin = 20.0;
    const double topMargin = 10.0;
    const double rightMargin = 10.0;

    final chartRect = Rect.fromLTWH(
      leftMargin,
      topMargin,
      size.width - leftMargin - rightMargin,
      size.height - topMargin - bottomMargin,
    );

    // Paint for the signal
    final paintSignal = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Paint for axes
    final paintAxis = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 1. Calculate Min/Max Y
    double minVal = data[0];
    double maxVal = data[0];
    for (var val in data) {
      if (val < minVal) minVal = val;
      if (val > maxVal) maxVal = val;
    }

    // Add padding
    final range = maxVal - minVal;
    final padding = range == 0 ? 1.0 : range * 0.1;
    final effectiveMin = minVal - padding;
    final effectiveMax = maxVal + padding;
    final effectiveRange = effectiveMax - effectiveMin;

    double getY(double val) {
      if (effectiveRange == 0) return chartRect.center.dy;
      // Flip Y because canvas 0 is top
      return chartRect.bottom -
          ((val - effectiveMin) / effectiveRange) * chartRect.height;
    }

    // 2. Draw Y Axis and Ticks
    canvas.drawLine(chartRect.bottomLeft, chartRect.topLeft, paintAxis);

    // Draw simple Y ticks (min, mid, max)
    final yTickValues = [
      effectiveMin,
      effectiveMin + effectiveRange / 2,
      effectiveMax
    ];
    for (final val in yTickValues) {
      final y = getY(val);
      canvas.drawLine(
          Offset(chartRect.left - 5, y), Offset(chartRect.left, y), paintAxis);

      final textSpan = TextSpan(
        text: val.toStringAsFixed(1),
        style: TextStyle(color: Colors.black, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(chartRect.left - textPainter.width - 6,
              y - textPainter.height / 2));
    }

    // 3. Draw X Axis and Ticks (Time)
    canvas.drawLine(chartRect.bottomLeft, chartRect.bottomRight, paintAxis);

    // Duration in seconds
    final duration = data.length / (frequency == 0 ? 1 : frequency);

    // Draw X ticks (0, mid, end)
    final xTickValues = [0.0, duration / 2, duration];

    for (final t in xTickValues) {
      final xRatio = t / duration; // 0.0 to 1.0
      final x = chartRect.left + xRatio * chartRect.width;

      canvas.drawLine(Offset(x, chartRect.bottom),
          Offset(x, chartRect.bottom + 5), paintAxis);

      final textSpan = TextSpan(
        text: '${t.toStringAsFixed(1)}s',
        style: TextStyle(color: Colors.black, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(x - textPainter.width / 2, chartRect.bottom + 6));
    }

    // 4. Draw Signal
    final path = Path();

    // If usage is huge, simplify.
    final pointCount = data.length;
    // Map index to X pixel
    double getX(int i) {
      return chartRect.left + (i / (pointCount - 1)) * chartRect.width;
    }

    path.moveTo(getX(0), getY(data[0]));

    if (pointCount > chartRect.width * 2) {
      // Decimation
      final step = (pointCount / (chartRect.width * 2)).ceil();
      for (var i = 1; i < pointCount; i += step) {
        path.lineTo(getX(i), getY(data[i]));
      }
    } else {
      for (var i = 1; i < pointCount; i++) {
        path.lineTo(getX(i), getY(data[i]));
      }
    }

    canvas.drawPath(path, paintSignal);
  }

  @override
  bool shouldRepaint(covariant _SignalPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.frequency != frequency;
  }
}
