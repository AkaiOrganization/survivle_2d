import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_core.dart';
import '../state/game_state.dart';
import 'hud.dart';

class GameScaffold extends StatelessWidget {
  const GameScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Сама игра (Flame) - всегда первым слоем
          GameWidget(
            game: MySurvivalGame(),
          ),

          // 2. HUD (Здоровье и ресурсы)
          const Positioned(
              top: 40,
              left: 20,
              child: SurvivalHUD()
          ),

          // 3. Кнопка выхода
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // 4. НИЖНИЙ ИНВЕНТАРЬ (Исправлено перекрытие джойстика)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              // Исправлено: используем .only для отступа снизу
              padding: const EdgeInsets.only(bottom: 30),
              // Исправлено: удален const, так как инвентарь динамический
              child: InventoryHotbar(),
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryHotbar extends StatelessWidget {
  const InventoryHotbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(9, (index) {
              final isSelected = state.selectedSlot == index;
              return GestureDetector(
                onTap: () => state.selectSlot(index),
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white24 : Colors.black45,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? Colors.red : Colors.white10,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      state.inventoryItems[index].isNotEmpty
                          ? state.inventoryItems[index].substring(0, 1)
                          : "${index + 1}",
                      style: TextStyle(
                        color: isSelected ? Colors.red : Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}