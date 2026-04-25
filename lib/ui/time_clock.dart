import 'dart:math';
import 'package:flutter/material.dart';
import '../state/game_state.dart';

class TimeClockWidget extends StatelessWidget {
  final GameState state;

  const TimeClockWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(60, 60), // Размер часов
      painter: _ClockPainter(state.time),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final double time; // 0.0 - 24.0
  _ClockPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Рисуем круг (циферблат)
    final paint = Paint()..color = Colors.white54..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawCircle(center, radius, paint);

    // Рисуем стрелку
    // Переводим 24 часа в 360 градусов (2 * pi).
    // -pi/2 нужен, чтобы 12:00 было вверху.
    double angle = (time / 24) * 2 * pi - (pi / 2);
    final needle = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));

    canvas.drawLine(center, needle, Paint()..color = Colors.yellow..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}