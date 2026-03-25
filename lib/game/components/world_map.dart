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
    final image = await gameRef.images.load('worldmap.png');
    final treeImage = await gameRef.images.load('forest_demo_objects.png');

    _terrainBatch = SpriteBatch(image);
    size = Vector2.all(3000);

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

    _spawnAdvancedObjects(image, treeImage);

    _addBoundaries();
  }

  void _spawnAdvancedObjects(Image image, Image treeImage) {
    final double dSize = tileSize * visualScale;

    for (double x = dSize * 3; x < size.x - dSize * 3; x += dSize * 5) {
      for (double y = dSize * 3; y < size.y - dSize * 3; y += dSize * 5) {

        if (_random.nextDouble() < 0.3) {
          double roll = _random.nextDouble();

          Vector2 srcPos;
          Vector2 srcSize;
          Vector2 objSize;
          Image currentImage = image;
          bool hasCollision = true;
          bool isCollectible = false;
          int priority = 2;

          if (roll < 0.15) { // дерево 1
            srcPos = Vector2(775, 95);
            srcSize = Vector2(233, 360);
            objSize = Vector2(dSize * 1.5, dSize * 2.2);
            priority = 3;
          } else if (roll < 0.20) { // дерево 2
            currentImage = treeImage;
            srcPos = Vector2(0, 0);
            srcSize = Vector2(60, 80);
            objSize = Vector2(dSize * 1.8, dSize * 2.8);
            priority = 3;
          } else if (roll < 0.25) { // пруд
            srcPos = Vector2(1103, 94);
            srcSize = Vector2(245, 268);
            objSize = Vector2(dSize * 2.5, dSize * 2.5);
            priority = 1;
          } else if (roll < 0.45) { // камень
            srcPos = Vector2(400, 345);
            srcSize = Vector2(95, 82);
            objSize = Vector2(dSize * 0.8, dSize * 0.7);
          } else if (roll < 0.65) { // ягода
            srcPos = Vector2(64, 346);
            srcSize = Vector2(95, 95);
            objSize = Vector2(dSize, dSize);
            isCollectible = true;
          } else if (roll < 0.85) { // красные цветы
            srcPos = Vector2(285, 130);
            srcSize = Vector2(50, 50);
            objSize = Vector2(dSize * 0.6, dSize * 0.6);
            hasCollision = false;
            priority = 1;
          } else { // белые цветы
            srcPos = Vector2(380, 130);
            srcSize = Vector2(50, 50);
            objSize = Vector2(dSize * 0.6, dSize * 0.6);
            hasCollision = false;
            priority = 1;
          }

          double offsetX = (_random.nextDouble() - 0.5) * dSize * 2;
          double offsetY = (_random.nextDouble() - 0.5) * dSize * 2;

          PositionComponent obj;
          if (isCollectible) {
            obj = CollectibleResource(
              sprite: Sprite(currentImage, srcPosition: srcPos, srcSize: srcSize),
              position: Vector2(x + offsetX, y + offsetY),
              size: objSize,
              resourceType: ResourceType.berries,
            );
          } else {
            obj = SpriteComponent(
              sprite: Sprite(currentImage, srcPosition: srcPos, srcSize: srcSize),
              position: Vector2(x + offsetX, y + offsetY),
              size: objSize,
              priority: priority,
            );
          }

          if (hasCollision) {
            obj.add(RectangleHitbox(
              size: objSize * 0.7,
              anchor: Anchor.center,
              position: objSize / 2,
            ));
          }
          add(obj);
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
  CollectibleResource({required Sprite sprite, required Vector2 position, required Vector2 size, required this.resourceType})
      : super(sprite: sprite, position: position, size: size, priority: 2);

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      other.heal(15);
      removeFromParent();
    }
  }
}