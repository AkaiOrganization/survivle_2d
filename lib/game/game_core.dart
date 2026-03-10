import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/sprite.dart'; // Добавлено для работы спрайтов
import 'package:flutter/material.dart';
import 'components/player.dart';
import 'components/world_map.dart';

// ОСНОВНОЙ КЛАСС ИГРЫ
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

    // 1. Карта
    await world.add(WorldMap()..priority = -1);

    // 2. Игрок
    player = Player();
    player.position = Vector2(400, 400);
    await world.add(player);

    // 3. Джойстик
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 25, paint: Paint()..color = Colors.white.withAlpha(128)),
      background: CircleComponent(radius: 50, paint: Paint()..color = Colors.black.withAlpha(77)),
      position: Vector2(80, size.y - 100),
      priority: 100,
    );

    // 4. Полоска здоровья (Класс описан ниже)
    final healthBar = HealthBar();

    // Добавляем UI элементы в камеру
    camera.viewport.addAll([joystick, healthBar]);

    camera.follow(player);
    camera.setBounds(Rectangle.fromLTWH(0, 0, 1280, 1280));
  }

  @override
  void update(double dt) {
    super.update(dt);
    player.move(joystick.relativeDelta, dt);
  }
}

// КЛАСС ПОЛОСКИ ЗДОРОВЬЯ (ТЕПЕРЬ ТУТ)
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