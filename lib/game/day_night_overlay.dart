import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../state/game_state.dart';

class DayNightOverlay extends RectangleComponent with HasGameRef {
  final GameState state;

  DayNightOverlay(this.state) {
    size = Vector2(800, 450); // Размер твоего экрана
    paint.color = const Color(0xFF000033); // Темно-синий цвет ночи
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Математика: 12:00 -> прозрачность 0, 00:00 -> прозрачность 0.7
    double hoursFromNoon = (state.time - 12).abs();
    double opacity = (hoursFromNoon / 12) * 0.7;

    // Применяем прозрачность
    paint.color = paint.color.withOpacity(opacity.clamp(0.0, 0.7));
  }
}