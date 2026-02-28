import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/player.dart';

class MySurvivalGame extends FlameGame {
  late Player player;
  late JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    world.add(RectangleComponent(
      size: Vector2(2000, 2000),
      paint: Paint()..color = const Color(0xff2d5a27),
    ));

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 25, paint: Paint()..color = Colors.white.withAlpha(128)),
      background: CircleComponent(radius: 50, paint: Paint()..color = Colors.black.withAlpha(77)),
      position: Vector2(80, size.y - 80),
      priority: 10,
    );

    player = Player();
    world.add(player);

    camera.viewport.add(joystick);
    camera.follow(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!joystick.delta.isZero()) {
      player.position.add(joystick.relativeDelta * 500 * dt);
    }
  }
}