import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../game_core.dart';
import 'interactable_object.dart';

enum PlayerState { down, left, right, up, idleDown, idleLeft, idleRight, idleUp }

class Player extends SpriteAnimationGroupComponent<PlayerState>
    with CollisionCallbacks, HasGameRef<MySurvivalGame> {

  final Vector2 _lastSafePosition = Vector2(2500.0, 2500.0);
  PlayerState _lastDirection = PlayerState.idleDown;

  Player() : super(size: Vector2.all(64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();
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
      PlayerState.idleDown: _makeAnim(0, frames: 1),
      PlayerState.idleLeft: _makeAnim(1, frames: 1),
      PlayerState.idleRight: _makeAnim(2, frames: 1),
      PlayerState.idleUp: _makeAnim(3, frames: 1),
    };

    current = PlayerState.idleDown;
    add(RectangleHitbox(
      size: Vector2(30, 20),
      position: Vector2(17, 40),
    ));
    _lastSafePosition.setFrom(position);
  }

  @override
  void update(double dt) {
    super.update(dt);
    priority = position.y.toInt();
  }

  void move(Vector2 delta, double dt) {
    if (delta.length > 0.1) {
      _lastSafePosition.setFrom(position);
      position.add(delta * 200 * dt);

      if (delta.y.abs() > delta.x.abs()) {
        if (delta.y > 0) {
          current = PlayerState.down;
          _lastDirection = PlayerState.idleDown;
        } else {
          current = PlayerState.up;
          _lastDirection = PlayerState.idleUp;
        }
      } else {
        if (delta.x < 0) {
          current = PlayerState.left;
          _lastDirection = PlayerState.idleLeft;
        } else {
          current = PlayerState.right;
          _lastDirection = PlayerState.idleRight;
        }
      }
    } else {
      current = _lastDirection;
    }
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    if (other is InteractableObject || other is RectangleHitbox) {
      position.setFrom(_lastSafePosition);
    }
  }
}