import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../state/game_state.dart';
import 'components/player.dart';
import 'components/world_map.dart';

enum BlockType { tree, stone, enemy, grass, none }

class MySurvivalGame extends FlameGame with HasCollisionDetection, DragCallbacks {
  final GameState state; // Ссылка на состояние игры
  late Player player;
  late JoystickComponent joystick;

  // Конструктор теперь требует состояние игры
  MySurvivalGame(this.state);

  @override
  Future<void> onLoad() async {
    camera = CameraComponent.withFixedResolution(width: 800, height: 450);
    final worldMap = WorldMap();
    await world.add(worldMap..priority = -1);
    player = Player();
    player.position = Vector2(1500, 1500);
    await world.add(player);

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: Paint()..color = Colors.white.withOpacity(0.5)),
      background: CircleComponent(radius: 50, paint: Paint()..color = Colors.black.withOpacity(0.3)),
      position: Vector2(80, 350),
    );

    camera.viewport.add(joystick);
    camera.follow(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    player.move(joystick.relativeDelta, dt);
  }

  BlockType getTargetBlock() => BlockType.tree;

  // --- ЛОГИКА ВЗАИМОДЕЙСТВИЯ ---
  bool onAction(ItemType selectedItem) {
    BlockType target = getTargetBlock();
    bool isCorrect = false;

    // Проверяем инструменты
    if (selectedItem == ItemType.axe && target == BlockType.tree) {
      isCorrect = true;
      state.addMaterial(ItemType.wood); // НАЧИСЛЯЕМ ДЕРЕВО!
      debugPrint("Срубил дерево! +1 дерево");
    } else if (selectedItem == ItemType.pickaxe && target == BlockType.stone) {
      isCorrect = true;
      state.addMaterial(ItemType.stone_material); // НАЧИСЛЯЕМ КАМЕНЬ!
      debugPrint("Добыл камень! +1 камень");
    } else if (selectedItem == ItemType.sword && target == BlockType.enemy) {
      isCorrect = true;
      debugPrint("Победил врага!");
    } else if (selectedItem == ItemType.shears && target == BlockType.grass) {
      isCorrect = true;
      debugPrint("Срезал траву!");
    }

    return isCorrect;
  }
}