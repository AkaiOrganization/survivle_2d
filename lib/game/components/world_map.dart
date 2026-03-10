import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'dart:ui';
import 'dart:math';

class WorldMap extends PositionComponent with HasGameRef {
  SpriteBatch? _farmBatch;
  SpriteBatch? _forestBatch;
  final Random _rnd = Random();
  final int mapSize = 20;

  @override
  Future<void> onLoad() async {
    final farmTerrain = await gameRef.images.load('terrain_demo.png');
    final forestTerrain = await gameRef.images.load('forest_demo_terrain.png');
    final forestObjects = await gameRef.images.load('forest_demo_objects.png');

    _farmBatch = SpriteBatch(farmTerrain);
    _forestBatch = SpriteBatch(forestTerrain);
    const double d = 64.0;
    size = Vector2.all(mapSize * d); // Задаем размер самому компоненту карты

    // Рисуем тайлы
    for (int x = 0; x < mapSize; x++) {
      for (int y = 0; y < mapSize; y++) {
        Vector2 pos = Vector2(x * d, y * d);
        _farmBatch!.add(source: const Rect.fromLTWH(48, 0, 16, 16), offset: pos, scale: 4);
      }
    }

    // ГРАНИЦЫ МИРА (Теперь они работают, так как WorldMap - PositionComponent)
    add(RectangleHitbox(position: Vector2(-10, 0), size: Vector2(10, size.y)));
    add(RectangleHitbox(position: Vector2(size.x, 0), size: Vector2(10, size.y)));
    add(RectangleHitbox(position: Vector2(0, -10), size: Vector2(size.x, 10)));
    add(RectangleHitbox(position: Vector2(0, size.y), size: Vector2(size.x, 10)));

    // Рандомные объекты
    for (int i = 0; i < 15; i++) {
      bool isRock = _rnd.nextBool();
      add(SpriteComponent(
        sprite: Sprite(forestObjects,
            srcPosition: isRock ? Vector2(176, 0) : Vector2(224, 48),
            srcSize: isRock ? Vector2(32, 48) : Vector2(16, 16)),
        position: Vector2(_rnd.nextDouble() * size.x, _rnd.nextDouble() * size.y),
        size: isRock ? Vector2(96, 144) : Vector2.all(64),
        anchor: Anchor.bottomCenter,
      )..add(RectangleHitbox()));
    }
  }

  @override
  void render(Canvas canvas) {
    _farmBatch?.render(canvas);
    _forestBatch?.render(canvas);
  }
}