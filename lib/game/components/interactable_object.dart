import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../game_core.dart'; // Где лежит твой enum BlockType

class InteractableObject extends PositionComponent with CollisionCallbacks {
  final BlockType type;

  InteractableObject({required this.type, required Vector2 position}) {
    this.position = position;
    size = Vector2(64, 64);
    add(RectangleHitbox()); // Важно для обнаружения
  }
}