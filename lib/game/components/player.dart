import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Player extends RectangleComponent {
  Player() : super(
    size: Vector2(40, 40),
    paint: Paint()..color = Colors.blue,
    position: Vector2(100, 100),
    anchor: Anchor.center,
  );
}