import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../game_core.dart';

enum PlayerState { down, left, right, up, idle }

class Player extends SpriteAnimationGroupComponent<PlayerState>
    with CollisionCallbacks, HasGameRef<MySurvivalGame> {

  double hp = 100.0; // ОБЯЗАТЕЛЬНО: переменная здоровья
  Vector2 _lastPos = Vector2.zero();

  Player() : super(size: Vector2.all(64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    animations = {};
    final sheet = await gameRef.images.load('player.png');
    final sz = Vector2(sheet.width / 4, sheet.height / 4);

    SpriteAnimation _a(int r, {int c = 4}) => SpriteAnimation.fromFrameData(sheet,
        SpriteAnimationData.sequenced(amount: c, stepTime: 0.15, textureSize: sz, texturePosition: Vector2(0, r * sz.y)));

    animations = {
      PlayerState.down: _a(0), PlayerState.left: _a(1),
      PlayerState.right: _a(2), PlayerState.up: _a(3),
      PlayerState.idle: _a(0, c: 1),
    };

    current = PlayerState.idle;
    add(RectangleHitbox(size: Vector2(30, 20), position: Vector2(17, 40)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    priority = position.y.toInt();
  }

  void move(Vector2 delta, double dt) {
    _lastPos = position.clone();
    if (delta.length > 0.1) {
      position.add(delta * 200 * dt);
      current = delta.y.abs() > delta.x.abs()
          ? (delta.y > 0 ? PlayerState.down : PlayerState.up)
          : (delta.x < 0 ? PlayerState.left : PlayerState.right);
    } else {
      current = PlayerState.idle;
    }
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    position = _lastPos;
  }
}