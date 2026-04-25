import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../state/game_state.dart';
import 'components/player.dart';
import 'components/world_map.dart';
import 'components/interactable_object.dart';
import 'day_night_overlay.dart';

enum BlockType { tree, stone, enemy, grass, none }

class MySurvivalGame extends FlameGame with HasCollisionDetection, DragCallbacks {
  final GameState state;
  late Player player;
  late JoystickComponent joystick;

  MySurvivalGame(this.state);

  @override
  Future<void> onLoad() async {
    camera = CameraComponent.withFixedResolution(width: 800, height: 450);

    await world.add(WorldMap()..priority = -1);
    await add(DayNightOverlay(state)..priority = 100);

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

    state.updateGameLoop(dt);
  }

  InteractableObject? findNearestObject() {
    InteractableObject? nearest;
    double minDistance = 100.0;

    for (final component in world.children) {
      if (component is InteractableObject) {
        final distance = player.position.distanceTo(component.position);
        if (distance < minDistance) {
          minDistance = distance;
          nearest = component;
        }
      }
    }
    return nearest;
  }

  bool onAction(ItemType selectedItem) {
    final target = findNearestObject();

    if (target == null) {
      debugPrint("Рядом ничего нет!");
      return false;
    }

    bool isCorrect = false;

    if (selectedItem == ItemType.axe && target.type == BlockType.tree) {
      isCorrect = true;
      state.addMaterial(ItemType.wood);
      FlameAudio.play('sfx/wood_chop.mp3');
    } else if (selectedItem == ItemType.pickaxe && target.type == BlockType.stone) {
      isCorrect = true;
      state.addMaterial(ItemType.stone_material);
      FlameAudio.play('sfx/stone_hit.mp3');
    } else if (selectedItem == ItemType.sword && target.type == BlockType.enemy) {
      isCorrect = true;
      debugPrint("Победил врага!");
    } else if (selectedItem == ItemType.shears && target.type == BlockType.grass) {
      isCorrect = true;
      debugPrint("Срезал траву!");
    }

    if (isCorrect) {
      target.removeFromParent();
      debugPrint("Действие выполнено: ${target.type}");
    }

    return isCorrect;
  }
}