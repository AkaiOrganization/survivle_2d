import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../game_core.dart';

enum PlayerState { down, left, right, up, idle }

class Player extends SpriteAnimationGroupComponent<PlayerState>
    with CollisionCallbacks, HasGameRef<MySurvivalGame> {

  double hp = 100.0;
  Vector2 _lastPos = Vector2.zero();

  Player() : super(size: Vector2.all(64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final image = await gameRef.images.load('player.png');

    final frameWidth = image.width / 4;
    final frameHeight = image.height / 4;
    final sz = Vector2(frameWidth, frameHeight);

    SpriteAnimation _makeAnim(int row, {int frames = 4}) => SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: frames,
        stepTime: 0.15,
        textureSize: sz,
        texturePosition: Vector2(0, row * sz.y),
      ),
    );

    animations = {
      PlayerState.down: _makeAnim(0),
      PlayerState.left: _makeAnim(1),
      PlayerState.right: _makeAnim(2),
      PlayerState.up: _makeAnim(3),
      PlayerState.idle: _makeAnim(0, frames: 1),
    };

    current = PlayerState.idle;

    add(RectangleHitbox(
      size: Vector2(30, 20),
      position: Vector2(17, 40),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    priority = position.y.toInt();
  }

  void heal(double amount) {
    hp = (hp + amount).clamp(0, 100);
  }

  void move(Vector2 delta, double dt) {
    _lastPos = position.clone();
    if (delta.length > 0.1) {
      position.add(delta * 200 * dt);

      if (delta.y.abs() > delta.x.abs()) {
        current = delta.y > 0 ? PlayerState.down : PlayerState.up;
      } else {
        current = delta.x < 0 ? PlayerState.left : PlayerState.right;
      }
    } else {
      current = PlayerState.idle;
    }
  }
  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    if (other is! ScreenHitbox) {
      position = _lastPos;
    }
  }
}