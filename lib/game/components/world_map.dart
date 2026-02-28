import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class ObstacleTree extends SpriteComponent with HasGameRef {
  ObstacleTree({required Vector2 position}) : super(position: position, size: Vector2(32, 48));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('Objects/Maple Tree.png');

    add(RectangleHitbox());
  }
}