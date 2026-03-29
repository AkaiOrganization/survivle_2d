import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'components/player.dart';
import 'components/world_map.dart';

class MySurvivalGame extends FlameGame with HasCollisionDetection, DragCallbacks {
  late Player player;
  late JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    camera = CameraComponent.withFixedResolution(width: 800, height: 450);

    final worldMap = WorldMap();
    await world.add(worldMap..priority = -1);

    player = Player();
    player.position = Vector2(1500, 1500);
    await world.add(player);

    // Создаем джойстик
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: Paint()..color = Colors.white.withOpacity(0.5)),
      background: CircleComponent(radius: 50, paint: Paint()..color = Colors.black.withOpacity(0.3)),
      position: Vector2(80, 350),
    );

    // Добавляем в viewport, чтобы он не двигался вместе с картой
    camera.viewport.add(joystick);
    camera.follow(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Передаем данные джойстика игроку для движения и анимации
    player.move(joystick.relativeDelta, dt);
  }
}