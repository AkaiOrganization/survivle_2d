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

  final Random _random = Random(777);
  final List<Vector2> _allObjectsPositions = [];

  late double islandStartX;
  late double islandEndX;
  late double islandStartY;
  late double islandEndY;

  @override
  Future<void> onLoad() async {
    final grassImage = await gameRef.images.load('worldmap.png');
    final objectsImage = await gameRef.images.load('forest_demo_objects.png');

    size = Vector2.all(5000);

    const double oceanWidth = 500.0;
    islandStartX = oceanWidth;
    islandEndX = size.x - oceanWidth;
    islandStartY = oceanWidth;
    islandEndY = size.y - oceanWidth;

    _terrainBatch = SpriteBatch(grassImage);
    final double dSize = tileSize * visualScale;

    for (double x = 0; x < size.x; x += dSize) {
      for (double y = 0; y < size.y; y += dSize) {
        if (x >= islandStartX && x < islandEndX && y >= islandStartY && y < islandEndY) {
          _terrainBatch!.add(
            source: const Rect.fromLTWH(120, 164, 16, 16),
            offset: Vector2(x, y),
            scale: visualScale,
          );
        }
      }
    }

    _spawnDetailedDecorations(objectsImage);
    _addBoundaries();
  }

  void _spawnDetailedDecorations(Image objectsImage) {
    final double dSize = tileSize * visualScale;
    _allObjectsPositions.clear();

    final Vector2 mapCenter = Vector2(size.x / 2, size.y / 2);

    // Деревья
    for (int i = 0; i < 15; i++) {
      Vector2 finalPos = _getSafeSeparatedPosition(minDistance: 300.0, mapCenter: mapCenter);
      _allObjectsPositions.add(finalPos);

      final sprite = Sprite(objectsImage, srcPosition: Vector2(0, 0), srcSize: Vector2(64, 96));
      final treeSize = Vector2(dSize * 2, dSize * 3);

      final tree = StaticObstacle(sprite: sprite, position: finalPos, size: treeSize, priority: 3);
      tree.anchor = Anchor.center;
      tree.add(RectangleHitbox(
        size: Vector2(60, 30),
        position: Vector2((treeSize.x - 60) / 2, treeSize.y - 45),
      ));
      add(tree);
    }

    // Камни
    for (int i = 0; i < 15; i++) {
      Vector2 finalPos = _getSafeSeparatedPosition(minDistance: 300.0, mapCenter: mapCenter);
      _allObjectsPositions.add(finalPos);

      final sprite = Sprite(objectsImage, srcPosition: Vector2(145, 3), srcSize: Vector2(31, 29));
      final stoneSize = Vector2(dSize * 1.2, dSize * 1.2);

      final stone = StaticObstacle(sprite: sprite, position: finalPos, size: stoneSize, priority: 2);
      stone.anchor = Anchor.center;
      stone.add(RectangleHitbox(
        size: Vector2(stoneSize.x * 0.8, stoneSize.y * 0.5),
        position: Vector2(stoneSize.x * 0.1, stoneSize.y * 0.4),
      ));
      add(stone);
    }

    // Кусты и ягоды
    final massObjects = [
      {'name': 'bush', 'srcPos': Vector2(176, 0), 'srcSize': Vector2(31, 32), 'objSize': Vector2(dSize * 1.2, dSize * 1.2), 'prio': 2, 'isColl': false, 'hasHitbox': true, 'chance': 0.3},
      {'name': 'berries', 'srcPos': Vector2(96, 16), 'srcSize': Vector2(16, 16), 'objSize': Vector2(dSize, dSize * 0.9), 'prio': 2, 'isColl': true, 'hasHitbox': false, 'chance': 0.4},
      {'name': 'small_stone', 'srcPos': Vector2(192, 51), 'srcSize': Vector2(14, 12), 'objSize': Vector2(dSize * 0.6, dSize * 0.6), 'prio': 1, 'isColl': false, 'hasHitbox': false, 'chance': 0.4},
      {'name': 'red_mushrooms', 'srcPos': Vector2(192, 96), 'srcSize': Vector2(16, 16), 'objSize': Vector2(dSize * 0.5, dSize * 0.5), 'prio': 1, 'isColl': false, 'hasHitbox': false, 'chance': 0.5},
    ];

    for (double x = islandStartX + dSize; x < islandEndX - dSize; x += dSize * 5) {
      for (double y = islandStartY + dSize; y < islandEndY - dSize; y += dSize * 5) {
        if (_random.nextDouble() < 0.6) {
          for (var item in massObjects) {
            if (_random.nextDouble() < (item['chance'] as num).toDouble()) {
              double offsetX = (_random.nextDouble() - 0.5) * dSize * 4.5;
              double offsetY = (_random.nextDouble() - 0.5) * dSize * 4.5;
              Vector2 finalPos = Vector2(x + offsetX, y + offsetY);

              if (finalPos.x < islandStartX || finalPos.x > islandEndX || finalPos.y < islandStartY || finalPos.y > islandEndY) continue;
              if (finalPos.distanceTo(mapCenter) < 250.0) continue;

              bool isTooClose = false;
              for (var existingPos in _allObjectsPositions) {
                if (finalPos.distanceTo(existingPos) < 80.0) {
                  isTooClose = true;
                  break;
                }
              }
              if (isTooClose) continue;

              _allObjectsPositions.add(finalPos);
              final sprite = Sprite(objectsImage, srcPosition: item['srcPos'] as Vector2, srcSize: item['srcSize'] as Vector2);
              final Vector2 objSize = item['objSize'] as Vector2;

              PositionComponent obj;
              if (item['isColl'] as bool) {
                obj = CollectibleResource(sprite: sprite, position: finalPos, size: objSize, resourceType: ResourceType.berries);
                obj.anchor = Anchor.center;
                obj.add(RectangleHitbox(
                  size: Vector2(objSize.x * 0.7, objSize.y * 0.5),
                  anchor: Anchor.bottomCenter,
                  position: Vector2(objSize.x / 2, objSize.y * 0.9),
                ));
              } else {
                if (item['hasHitbox'] as bool) {
                  obj = StaticObstacle(sprite: sprite, position: finalPos, size: objSize, priority: (item['prio'] as num).toInt());
                  obj.anchor = Anchor.center;
                  obj.add(RectangleHitbox(
                    size: Vector2(objSize.x * 0.7, objSize.y * 0.4),
                    position: Vector2(objSize.x * 0.15, objSize.y * 0.5),
                  ));
                } else {
                  obj = SpriteComponent(sprite: sprite, position: finalPos, size: objSize, priority: (item['prio'] as num).toInt());
                  obj.anchor = Anchor.center;
                }
              }
              add(obj);
            }
          }
        }
      }
    }
  }

  Vector2 _getSafeSeparatedPosition({required double minDistance, required Vector2 mapCenter}) {
    final double minX = islandStartX + 100.0;
    final double maxX = islandEndX - 100.0;
    final double minY = islandStartY + 100.0;
    final double maxY = islandEndY - 100.0;

    while (true) {
      double x = minX + _random.nextDouble() * (maxX - minX);
      double y = minY + _random.nextDouble() * (maxY - minY);
      Vector2 candidatePos = Vector2(x, y);

      if (candidatePos.distanceTo(mapCenter) < 250.0) continue;

      bool isTooClose = false;
      for (var existingPos in _allObjectsPositions) {
        if (candidatePos.distanceTo(existingPos) < minDistance) {
          isTooClose = true;
          break;
        }
      }
      if (!isTooClose) return candidatePos;
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

class StaticObstacle extends SpriteComponent with CollisionCallbacks {
  StaticObstacle({required Sprite sprite, required Vector2 position, required Vector2 size, required int priority})
      : super(sprite: sprite, position: position, size: size, priority: priority);
}

class CollectibleResource extends SpriteComponent with CollisionCallbacks, HasGameRef<MySurvivalGame> {
  final ResourceType resourceType;
  CollectibleResource({required Sprite sprite, required Vector2 position, required Vector2 size, required this.resourceType})
      : super(sprite: sprite, position: position, size: size, priority: 2);

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      gameRef.state.eat(20.0);
      gameRef.state.heal(2.0);
      removeFromParent();
    }
  }
}