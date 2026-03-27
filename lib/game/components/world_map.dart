import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'dart:ui';
import '../game_core.dart';
import 'player.dart';

class WorldMap extends PositionComponent with HasGameRef<MySurvivalGame> {
  final double visualScale = 4.0;
  final double tileSize = 16.0;
  SpriteBatch? _terrainBatch;
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    final grassImage = await gameRef.images.load('worldmap.png');
    final objectsImage = await gameRef.images.load('forest_demo_objects.png');

    size = Vector2.all(3000);

    _terrainBatch = SpriteBatch(grassImage);
    final double dSize = tileSize * visualScale;

    for (double x = 0; x < size.x; x += dSize) {
      for (double y = 0; y < size.y; y += dSize) {
        _terrainBatch!.add(
          source: const Rect.fromLTWH(120, 164, 16, 16),
          offset: Vector2(x, y),
          scale: visualScale,
        );
      }
    }

    _spawnDetailedDecorations(objectsImage);
    _addBoundaries();
  }

  void _spawnDetailedDecorations(Image objectsImage) {
    final double dSize = tileSize * visualScale;

    for (double x = dSize * 4; x < size.x - dSize * 4; x += dSize * 12) {
      for (double y = dSize * 4; y < size.y - dSize * 4; y += dSize * 12) {

        if (_random.nextDouble() < 0.6) {

          final allPossibleObjects = [
            {
              'name': 'tree',
              'srcPos': Vector2(0, 0),
              'srcSize': Vector2(64, 96),
              'objSize': Vector2(dSize * 2, dSize * 3),
              'hitSize': Vector2(dSize * 0.8, dSize * 0.4),
              'prio': 3,
              'isColl': false,
              'chance': 0.25
            },
            {
              'name': 'big_stone',
              'srcPos': Vector2(145, 3),
              'srcSize': Vector2(31, 29),
              'objSize': Vector2(dSize * 1.2, dSize * 1.2),
              'hitSize': Vector2(dSize, dSize * 0.7),
              'prio': 2,
              'isColl': false,
              'chance': 0.2
            },
            {
              'name': 'berries',
              'srcPos': Vector2(96, 16),
              'srcSize': Vector2(16, 16),
              'objSize': Vector2(dSize, dSize * 0.7),
              'hitSize': Vector2(dSize * 0.7, dSize * 0.6),
              'prio': 2,
              'isColl': true,
              'chance': 0.2
            },
            {
              'name': 'small_stone',
              'srcPos': Vector2(192, 51),
              'srcSize': Vector2(14, 12),
              'objSize': Vector2(dSize * 0.6, dSize * 0.6),
              'hitSize': Vector2.zero(),
              'prio': 1,
              'isColl': false,
              'chance': 0.4
            },
            {
              'name': 'red_mushrooms',
              'srcPos': Vector2(192, 96),
              'srcSize': Vector2(16, 16),
              'objSize': Vector2(dSize * 0.5, dSize * 0.5),
              'hitSize': Vector2.zero(),
              'prio': 1,
              'isColl': false,
              'chance': 0.5
            },
            {
              'name': 'yellow_flower',
              'srcPos': Vector2(256, 16),
              'srcSize': Vector2(16, 16),
              'objSize': Vector2(dSize * 0.5, dSize * 0.5),
              'hitSize': Vector2.zero(),
              'prio': 1,
              'isColl': false,
              'chance': 0.6
            },
            {
              'name': 'purple_flower',
              'srcPos': Vector2(272, 16),
              'srcSize': Vector2(16, 16),
              'objSize': Vector2(dSize * 0.5, dSize * 0.5),
              'hitSize': Vector2.zero(),
              'prio': 1,
              'isColl': false,
              'chance': 0.6
            },
            {
              'name': 'tall_grass',
              'srcPos': Vector2(128, 64),
              'srcSize': Vector2(16, 16),
              'objSize': Vector2(dSize * 0.6, dSize * 0.6),
              'hitSize': Vector2.zero(),
              'prio': 1,
              'isColl': false,
              'chance': 0.7
            },
          ];

          for (var item in allPossibleObjects) {
            if (_random.nextDouble() < (item['chance'] as double)) {

              double offsetX = (_random.nextDouble() - 0.5) * dSize * 10;
              double offsetY = (_random.nextDouble() - 0.5) * dSize * 10;
              Vector2 finalPos = Vector2(x + offsetX, y + offsetY);

              if (finalPos.length < 150) continue;

              final sprite = Sprite(objectsImage,
                  srcPosition: item['srcPos'] as Vector2,
                  srcSize: item['srcSize'] as Vector2
              );

              PositionComponent obj;
              if (item['isColl'] as bool) {
                obj = CollectibleResource(
                  sprite: sprite,
                  position: finalPos,
                  size: item['objSize'] as Vector2,
                  resourceType: ResourceType.berries,
                );
              } else {
                obj = SpriteComponent(
                  sprite: sprite,
                  position: finalPos,
                  size: item['objSize'] as Vector2,
                  priority: item['prio'] as int,
                );
              }
              obj.anchor = Anchor.center;

              Vector2 hSize = item['hitSize'] as Vector2;
              if (hSize != Vector2.zero()) {
                obj.add(RectangleHitbox(
                  size: hSize,
                  anchor: Anchor.bottomCenter,
                  position: Vector2((item['objSize'] as Vector2).x / 2, (item['objSize'] as Vector2).y),
                ));
              }

              add(obj);
            }
          }
        }
      }
    }
  }

  void _addBoundaries() {
    const double wallThickness = 100.0;
    addAll([
      RectangleHitbox(position: Vector2(0, -wallThickness), size: Vector2(size.x, wallThickness)),
      RectangleHitbox(position: Vector2(0, size.y), size: Vector2(size.x, wallThickness)),
      RectangleHitbox(position: Vector2(-wallThickness, 0), size: Vector2(wallThickness, size.y)),
      RectangleHitbox(position: Vector2(size.x, 0), size: Vector2(wallThickness, size.y)),
    ]);
  }

  @override
  void render(Canvas canvas) {
    _terrainBatch?.render(canvas);
    super.render(canvas);
  }
}

enum ResourceType { berries }

class CollectibleResource extends SpriteComponent with CollisionCallbacks, HasGameRef<MySurvivalGame> {
  final ResourceType resourceType;

  CollectibleResource({
    required Sprite sprite,
    required Vector2 position,
    required Vector2 size,
    required this.resourceType
  }) : super(sprite: sprite, position: position, size: size, priority: 2);

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      if (other.hp < 100) {
        other.heal(15);
        removeFromParent();
      }
    }
  }
}