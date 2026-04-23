import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';
import 'package:flame_audio/flame_audio.dart';

// Твои модули
import 'game/game_core.dart';
import 'state/game_state.dart';
import 'ui/hud.dart';
import 'ui/main_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Инициализируем состояние и загружаем сохранение
  final state = GameState();
  await state.loadGame();

  // 2. Предварительная загрузка аудио
  try {
    await FlameAudio.audioCache.loadAll(['music/Sergio.mp3', 'sfx/click.mp3']);
  } catch (e) {
    debugPrint("Ошибка загрузки аудио: $e");
  }

  // 3. Запуск приложения с уже загруженным состоянием
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
    // Передаем состояние в игру один раз при запуске
    _game = MySurvivalGame(context.read<GameState>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Движок
          GameWidget(game: _game),

          // 2. Интерфейс (Consumer обновляет экран при изменении данных)
          Consumer<GameState>(
            builder: (context, state, child) => Stack(
              children: [
                // Счетчики ресурсов
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

                // HUD
                const Positioned(top: 40, left: 20, child: SurvivalHUD()),

                // Кнопка сбора ресурсов
                Positioned(
                  bottom: 30, left: 20,
                  child: FloatingActionButton(
                    backgroundColor: Colors.brown,
                    onPressed: () {
                      if (state.isSoundEnabled) FlameAudio.play('sfx/click.mp3');
                      state.addMaterial(ItemType.wood); // Пример: добыча дерева
                    },
                    child: const Icon(Icons.handyman, color: Colors.white),
                  ),
                ),

                // Кнопка выхода (с сохранением)
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