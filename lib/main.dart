import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';
import 'package:flame_audio/flame_audio.dart';

// Импорты модулей
import 'game/game_core.dart';
import 'state/game_state.dart';
import 'ui/hud.dart';
import 'ui/main_menu.dart';
import 'ui/time_clock.dart'; // Убедись, что файл существует в lib/ui/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final state = GameState();
  await state.loadGame();

  try {
    await FlameAudio.audioCache.loadAll(['music/Sergio.mp3', 'sfx/click.mp3']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Движок игры
          GameWidget(game: _game),

          // 2. Интерфейс (UI)
          Consumer<GameState>(
            builder: (context, state, child) => Stack(
              children: [
                // Ресурсы
                Positioned(
                  top: 50, left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black54,
                    child: Text(
                      "Дерево: ${state.getResourceCount(ItemType.wood)} | Камень: ${state.getResourceCount(ItemType.stone_material)}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                // Индикаторы выживания (HP и Голод)
                Positioned(
                  top: 100, left: 20, width: 200,
                  child: Column(
                    children: [
                      LinearProgressIndicator(value: state.hp / 100, color: Colors.red, backgroundColor: Colors.grey[800]),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(value: state.hunger / 100, color: Colors.orange, backgroundColor: Colors.grey[800]),
                    ],
                  ),
                ),

                // Часы
                Positioned(
                  top: 50, right: 100,
                  child: TimeClockWidget(state: state),
                ),

                // HUD
                const Positioned(top: 40, left: 20, child: SurvivalHUD()),

                // Кнопка сбора
                Positioned(
                  bottom: 30, left: 20,
                  child: FloatingActionButton(
                    backgroundColor: Colors.brown,
                    onPressed: () => _game.onAction(ItemType.axe),
                    child: const Icon(Icons.handyman, color: Colors.white),
                  ),
                ),

                // Сохранение
                Positioned(
                  top: 40, right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.save, color: Colors.green, size: 35),
                    onPressed: () async {
                      await state.saveGame();
                      if (mounted) Navigator.of(context).pop();
                    },
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