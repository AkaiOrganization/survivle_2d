import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

enum PlayerState { down, left, right, up, idle }

class Player extends SpriteAnimationGroupComponent<PlayerState> with HasGameRef {
  Player() : super(size: Vector2.all(64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final spriteSheet = await gameRef.images.load('player.png');
    final double frameWidth = spriteSheet.width / 4;
    final double frameHeight = spriteSheet.height / 4;
    final Vector2 frameSize = Vector2(frameWidth, frameHeight);

    SpriteAnimation _buildAnim(int row, {int amount = 4, bool loop = true}) {
      return SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: 0.15,
          textureSize: frameSize,
          texturePosition: Vector2(0, row * frameHeight),
          loop: loop,
        ),
      );
    }

    animations = {
      PlayerState.down:  _buildAnim(0),
      PlayerState.left:  _buildAnim(1),
      PlayerState.right: _buildAnim(2),
      PlayerState.up:    _buildAnim(3),
      PlayerState.idle:  _buildAnim(0, amount: 1, loop: false),
    };

    current = PlayerState.idle;
    position = Vector2(1500, 1500);
  }

  void move(Vector2 delta, double dt) {
    if (delta.length > 0.1) {
      position.add(delta * 250 * dt);

      if (delta.y.abs() > delta.x.abs()) {
        current = delta.y > 0 ? PlayerState.down : PlayerState.up;
      } else {
        current = delta.x < 0 ? PlayerState.right : PlayerState.left;
      }
    } else {
      current = PlayerState.idle;
    }

    position.x = position.x.clamp(32, 2968);
    position.y = position.y.clamp(32, 2968);
  }
}