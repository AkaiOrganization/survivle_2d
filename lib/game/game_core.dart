import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'components/player.dart';
import 'components/world_map.dart';

class MySurvivalGame extends FlameGame with HasCollisionDetection {
  late Player player;
  late JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    camera = CameraComponent.withFixedResolution(
      world: world,
      width: 800,
      height: 450,
    );

    final worldMap = WorldMap();
    await world.add(worldMap..priority = -1);

    player = Player();
    player.position = Vector2(1500, 1500);
    await world.add(player);

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 25, paint: Paint()..color = Colors.white.withAlpha(128)),
      background: CircleComponent(radius: 50, paint: Paint()..color = Colors.black.withAlpha(77)),
      position: Vector2(80, 350),
      priority: 100,
    );

    final healthBar = HealthBar();
    camera.viewport.addAll([joystick, healthBar]);
    camera.follow(player);
    camera.setBounds(Rectangle.fromLTWH(0, 0, 3000, 3000));
  }

  @override
  void update(double dt) {
    super.update(dt);
    player.move(joystick.relativeDelta, dt);
  }
}

class HealthBar extends SpriteGroupComponent<int> with HasGameRef<MySurvivalGame> {
  HealthBar() : super(
    size: Vector2(160, 80),
    position: Vector2(20, 20),
    priority: 100,
  );

  @override
  Future<void> onLoad() async {
    final image = await gameRef.images.load('hp.png');
    final sheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 2,
      rows: 3,
    );

    sprites = {
      0: sheet.getSprite(0, 0),
      1: sheet.getSprite(0, 1),
      2: sheet.getSprite(1, 0),
      3: sheet.getSprite(1, 1),
      4: sheet.getSprite(2, 0),
      5: sheet.getSprite(2, 1),
    };
    current = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.player != null) {
      double hpPercent = (gameRef.player.hp / 100).clamp(0.0, 1.0);
      int index = (5 * (1.0 - hpPercent)).floor();
      current = index.clamp(0, 5);
    }
  }
}