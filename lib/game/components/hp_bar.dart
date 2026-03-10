import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../game_core.dart';

class HealthBar extends SpriteGroupComponent<int> with HasGameRef<MySurvivalGame> {
  HealthBar() : super(
    size: Vector2(200, 100),
    position: Vector2(5, 1),
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
      0: sheet.getSprite(0, 0), // 100%
      1: sheet.getSprite(0, 1), // 80%
      2: sheet.getSprite(1, 0), // 60%
      3: sheet.getSprite(1, 1), // 40%
      4: sheet.getSprite(2, 0), // 20%
      5: sheet.getSprite(2, 1), // 0%
    };

    current = 0;
    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    double hpPercent = (gameRef.player.hp / 100).clamp(0.0, 1.0);

    int index = 5 - (hpPercent * 5).round();

    current = index;
  }
}