import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../game_core.dart';

class HealthBar extends SpriteGroupComponent<int> with HasGameRef<MySurvivalGame> {
  HealthBar() : super(
    size: Vector2(160, 80),
    position: Vector2(20, 20),
    priority: 100,
  );

  @override
  Future<void> onLoad() async {
    final image = await gameRef.images.load('hp.png');
    final sheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 2,
      rows: 3,
    );

    sprites = {
      0: sheet.getSprite(0, 0),
      1: sheet.getSprite(0, 1),
      2: sheet.getSprite(1, 0),
      3: sheet.getSprite(1, 1),
      4: sheet.getSprite(2, 0),
      5: sheet.getSprite(2, 1),
    };
    current = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.player != null) {
      double hpPercent = (gameRef.player.hp / 100).clamp(0.0, 1.0);
      int index = (5 * (1.0 - hpPercent)).floor();
      current = index.clamp(0, 5);
    }
  }
}