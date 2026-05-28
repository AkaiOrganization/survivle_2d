import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_core.dart';

class InteractableObject extends SpriteComponent with HasGameRef<MySurvivalGame> {
  final BlockType type;
  int health = 3;
  double _hitTimer = 0.0;
  late Color _originalColor;

  InteractableObject({required this.type, required Vector2 position})
      : super(position: position, size: Vector2(40, 40), priority: 2);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Задаем цвет в зависимости от типа ресурса
    if (type == BlockType.tree) {
      paint.color = Colors.green;
    } else if (type == BlockType.stone) {
      paint.color = Colors.grey;
    } else {
      paint.color = Colors.orange; // Цвет для костра (BlockType.none)
    }

    _originalColor = paint.color;

    // Добавляем хитбокс, соответствующий размеру объекта
    add(RectangleHitbox(
      size: Vector2(36, 36),
      position: Vector2(2, 2),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Безопасный таймер вспышки получения урона
    if (_hitTimer > 0) {
      _hitTimer -= dt;
      if (_hitTimer <= 0) {
        paint.color = _originalColor;
      }
    }
  }

  // Метод получения удара от игрока
  bool hit() {
    health--;
    paint.color = Colors.redAccent;
    _hitTimer = 0.1;
    return health <= 0; // Возвращает true, если объект уничтожен
  }
}