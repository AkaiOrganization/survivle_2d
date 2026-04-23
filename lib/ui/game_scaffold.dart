import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_core.dart';
import '../state/game_state.dart';
import '../utils/audio_manager.dart';

class GameScaffold extends StatefulWidget {
  const GameScaffold({super.key});

  @override
  State<GameScaffold> createState() => _GameScaffoldState();
}

class _GameScaffoldState extends State<GameScaffold> {
  late final MySurvivalGame _game;

  @override
  void initState() {
    super.initState();
    // Получаем доступ к GameState из Provider
    final state = Provider.of<GameState>(context, listen: false);
    // Передаем state в игру
    _game = MySurvivalGame(state);
  }
  // --- МЕНЮ КРАФТА ---
  void _showCraftingMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF543224),
          title: const Text("ВЕРСТАК", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Consumer<GameState>(
            builder: (context, state, _) {
              return SizedBox(
                width: 300,
                child: ListView(
                  shrinkWrap: true,
                  children: state.recipes.keys.map((item) {
                    final canCraft = state.canCraft(item);
                    return ListTile(
                      title: Text(item.name.toUpperCase(), style: const TextStyle(color: Colors.white)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: canCraft ? Colors.green : Colors.grey),
                        onPressed: canCraft ? () => state.craft(item) : null,
                        child: const Text("Крафт"),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Закрыть", style: TextStyle(color: Colors.white)))],
        );
      },
    );
  }

  // --- МЕНЮ ПАУЗЫ ---
  void _showPauseMenu(BuildContext context) {
    _game.pauseEngine();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF543224), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 3)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("ПАУЗА", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                const SizedBox(height: 20),
                _pauseButton("ПРОДОЛЖИТЬ", Colors.green, () { _game.resumeEngine(); Navigator.pop(context); }),
                _pauseButton("НАСТРОЙКИ", Colors.blueGrey, () => _showSettings(context)),
                _pauseButton("СОХРАНИТЬ И ВЫЙТИ", Colors.orange.shade800, () { context.read<GameState>().saveGame(); _exitToMainMenu(context); }),
              ],
            ),
          ),
        );
      },
    ).then((_) => _game.resumeEngine());
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text("Настройки", style: TextStyle(color: Colors.white)),
        content: Consumer<GameState>(
          builder: (context, state, _) => SwitchListTile(
            title: const Text("Звук", style: TextStyle(color: Colors.white)),
            value: state.isSoundEnabled,
            onChanged: (val) {
              state.toggleSound();
              if (!val) AudioManager.stopMusic(); else AudioManager.playBackgroundMusic();
            },
            activeColor: Colors.green,
          ),
        ),
      ),
    );
  }

  void _exitToMainMenu(BuildContext context) { Navigator.pop(context); Navigator.pop(context); }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
  }

  Widget _pauseButton(String text, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(double.infinity, 50)),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GameWidget(game: _game),
          Consumer<GameState>(
            builder: (context, state, _) {
              return Stack(
                children: [
                  // ВЕРХНЯЯ ПАНЕЛЬ (Ресурсы, Верстак, Пауза)
                  Positioned(
                    top: 40, left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Дерево: ${state.getResourceCount(ItemType.wood)}", style: const TextStyle(color: Colors.white, fontFamily: 'monospace')),
                        Text("Камень: ${state.getResourceCount(ItemType.stone_material)}", style: const TextStyle(color: Colors.white, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 40, right: 20,
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.handyman, size: 40, color: Colors.white70), onPressed: () => _showCraftingMenu(context)),
                        IconButton(icon: const Icon(Icons.pause_circle_filled, size: 45, color: Colors.white70), onPressed: () => _showPauseMenu(context)),
                      ],
                    ),
                  ),

                  // КНОПКА ДЕЙСТВИЯ (Справа снизу)
                  Positioned(
                    bottom: 100, right: 30,
                    child: GestureDetector(
                      onTap: () {
                        final item = state.getItemInSlot(state.selectedSlot);
                        if (!_game.onAction(item)) _showWarning("Неверный инструмент!");
                        else AudioManager.playSfx('sfx/click.mp3', isSoundEnabled: state.isSoundEnabled);
                      },
                      child: Container(
                        width: 80, height: 80,
                        decoration: const BoxDecoration(color: Color(0xFF8B5E3C), shape: BoxShape.circle),
                        child: const Icon(Icons.pan_tool, color: Colors.white, size: 40),
                      ),
                    ),
                  ),

                  // СТАТИСТИКА И ХОТБАР
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 340, padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatBar("HP", state.hp, Colors.redAccent, Icons.favorite),
                                _buildStatBar("FOOD", state.hunger, Colors.orangeAccent, Icons.restaurant, isRight: true),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildHotbarUI(state),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHotbarUI(GameState state) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: const Color(0xFF543224), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black, width: 2)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) => GestureDetector(
          onTap: () => state.selectSlot(index),
          child: _slotSquare(
            content: state.getItemInSlot(index) != ItemType.none
                ? Icon(_getIconForItem(state.getItemInSlot(index)), color: Colors.white)
                : const SizedBox(),
            isSelected: state.selectedSlot == index,
          ),
        )),
      ),
    );
  }

  IconData _getIconForItem(ItemType item) {
    switch (item) {
      case ItemType.axe: return Icons.handyman;
      case ItemType.pickaxe: return Icons.construction;
      case ItemType.sword: return Icons.colorize;
      case ItemType.shears: return Icons.content_cut;
      default: return Icons.question_mark;
    }
  }

  Widget _slotSquare({required Widget content, required bool isSelected}) {
    return Container(
      width: 60, height: 60, margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF8B5E3C) : const Color(0xFF3A2518),
        borderRadius: BorderRadius.circular(4), border: Border.all(color: isSelected ? const Color(0xFFFFD700) : Colors.black45, width: isSelected ? 4 : 2),
      ),
      child: Center(child: content),
    );
  }

  Widget _buildStatBar(String label, double value, Color color, IconData icon, {bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (!isRight) Icon(icon, color: color, size: 12),
            Text(" $label", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            if (isRight) Icon(icon, color: color, size: 12),
          ],
        ),
        Container(
          width: 130, height: 10,
          decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.grey.shade800, width: 1.5)),
          child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: value.clamp(0.0, 1.0), child: Container(color: color)),
        ),
      ],
    );
  }
}