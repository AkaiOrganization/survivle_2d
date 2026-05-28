import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';
import 'package:flame_audio/flame_audio.dart';

import 'game/game_core.dart';
import 'state/game_state.dart';
import 'ui/hud.dart';
import 'ui/main_menu.dart';
import 'ui/time_clock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final state = GameState();
  await state.loadGame();

  try {
    // Кешируем аудиофайлы заранее, чтобы игра не фризила в моменты ударов
    await FlameAudio.audioCache.loadAll([
      'music/Sergio.mp3',
      'sfx/click.mp3',
      'sfx/wood_chop.mp3',
      'sfx/stone_hit.mp3'
    ]);
  } catch (e) {
    debugPrint("Ошибка загрузки аудио: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => state,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Survival 2D',
      theme: ThemeData(brightness: Brightness.dark, fontFamily: 'monospace'),
      home: const MainMenu(),
    );
  }
}

class MainGamePage extends StatefulWidget {
  const MainGamePage({super.key});

  @override
  State<MainGamePage> createState() => _MainGamePageState();
}

class _MainGamePageState extends State<MainGamePage> {
  late MySurvivalGame _game;

  @override
  void initState() {
    super.initState();
    _game = MySurvivalGame(context.read<GameState>());
  }

  // --- УМЕНЬШЕННОЕ МЕНЮ КРАФТА ПОД ТЕЛЕФОНЫ ---
  void _showCraftingMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF543224),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          title: const Text(
              "ВЕРСТАК",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'monospace')
          ),
          content: Consumer<GameState>(
            builder: (context, state, _) {
              return SizedBox(
                width: 260, // Компактная ширина под мобильный экран
                child: ListView(
                  shrinkWrap: true,
                  children: state.recipes.keys.map((item) {
                    final canCraft = state.canCraft(item);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14)),
                      trailing: SizedBox(
                        height: 32, // Аккуратная низкая кнопка
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canCraft ? Colors.green : Colors.grey.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          onPressed: canCraft ? () => state.craft(item) : null,
                          child: const Text("Крафт", style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Закрыть", style: TextStyle(color: Colors.white70, fontSize: 14)),
            )
          ],
        );
      },
    );
  }

  // Иконки для предметов в хотбаре и на кнопке действия
  IconData _getIconForItem(ItemType item) {
    switch (item) {
      case ItemType.axe: return Icons.handyman;
      case ItemType.pickaxe: return Icons.construction;
      case ItemType.sword: return Icons.colorize;
      case ItemType.shears: return Icons.content_cut;
      default: return Icons.block;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Игровой движок Flame
          GameWidget(game: _game),

          // 2. Адаптивный мобильный интерфейс (UI)
          Consumer<GameState>(
            builder: (context, state, child) => Stack(
              children: [
                // ВЕРХНИЙ ЛЕВЫЙ УГОЛ: Красивый HUD (Ресурсы и полоски HP/Голода из SurvivalHUD)
                const Positioned(
                  top: 30,
                  left: 15,
                  child: SurvivalHUD(),
                ),

                // ВЕРХНИЙ ПРАВЫЙ УГОЛ: Компактный блок времени, крафта и сейва
                Positioned(
                  top: 30,
                  right: 15,
                  child: Row(
                    children: [
                      // Маленькие аккуратные часы
                      Transform.scale(
                        scale: 0.8, // Сжали круг часов, чтобы не занимал место
                        child: TimeClockWidget(state: state),
                      ),
                      const SizedBox(width: 8),
                      // Кнопка открытия Верстака
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF543224),
                        child: IconButton(
                          icon: const Icon(Icons.gavel, color: Colors.amber, size: 18),
                          onPressed: () => _showCraftingMenu(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Кнопка сохранения игры и выхода в меню
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF543224),
                        child: IconButton(
                          icon: const Icon(Icons.save, color: Colors.green, size: 18),
                          onPressed: () async {
                            await state.saveGame();
                            if (mounted) Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // СНИЗУ СПРАВА: Уменьшенная кнопка действия (бьет тем, что выбрано в хотбаре)
                Positioned(
                  bottom: 25,
                  right: 25,
                  child: SizedBox(
                    width: 64,  // Оптимальный мобильный размер кнопки под большой палец
                    height: 64,
                    child: FloatingActionButton(
                      backgroundColor: const Color(0xFF8B5E3C),
                      shape: const CircleBorder(),
                      onPressed: () {
                        final currentItem = state.getItemInSlot(state.selectedSlot);
                        _game.onAction(currentItem);
                      },
                      child: Icon(
                        _getIconForItem(state.getItemInSlot(state.selectedSlot)),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),

                // СНИЗУ ПО ЦЕНТРУ: Компактный Хотбар (Сжатые ячейки, чтобы не мешать джойстику)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF543224),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final item = state.getItemInSlot(index);
                          final isSelected = state.selectedSlot == index;
                          return GestureDetector(
                            onTap: () => state.selectSlot(index),
                            child: Container(
                              width: 44,  // Ширина уменьшена с 55 до 44 под экраны телефонов
                              height: 44, // Высота уменьшена с 55 до 44
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF8B5E3C) : const Color(0xFF3A2518),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFFFD700) : Colors.black45,
                                  width: isSelected ? 2.5 : 1.0,
                                ),
                              ),
                              child: Center(
                                child: item != ItemType.none
                                    ? Icon(_getIconForItem(item), color: Colors.white, size: 20)
                                    : const SizedBox(),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}