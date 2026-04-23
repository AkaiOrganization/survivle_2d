import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Обязательно импорт
import 'package:flame_audio/flame_audio.dart';
import '../utils/audio_manager.dart';
import '../state/game_state.dart'; // Импорт состояния
import 'world_selection.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  void initState() {
    super.initState();
    AudioManager.playBackgroundMusic();
  }

  // Обновленный метод клика: теперь проверяет состояние звука
  void _playClick() {
    final isSoundOn = context.read<GameState>().isSoundEnabled;
    if (isSoundOn) {
      try {
        FlameAudio.play('sfx/click.mp3');
      } catch (e) {
        debugPrint("Звук не найден: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => AudioManager.playBackgroundMusic(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/menu2.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
                errorBuilder: (context, e, s) => Container(color: Colors.black),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'SURVIVAL 2D',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'monospace',
                      letterSpacing: 8,
                      shadows: [
                        Shadow(blurRadius: 20, color: Colors.black, offset: Offset(5, 5))
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),

                  _buildMenuButton(
                    context,
                    imagePath: 'assets/images/play.png',
                    onTap: () {
                      _playClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WorldSelectionScreen()),
                      );
                    },
                  ),

                  _buildMenuButton(
                    context,
                    imagePath: 'assets/images/settings.png',
                    onTap: () {
                      _playClick();
                      _showSettings(context);
                    },
                  ),

                  _buildMenuButton(
                    context,
                    imagePath: 'assets/images/exit.png',
                    onTap: () {
                      _playClick();
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Метод настроек с переключателем
  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text("Настройки", style: TextStyle(color: Colors.white)),
        // Используем Consumer, чтобы слушать изменения GameState
        content: Consumer<GameState>(
          builder: (context, gameState, child) {
            return SwitchListTile(
              title: const Text("Звук", style: TextStyle(color: Colors.white)),
              value: gameState.isSoundEnabled,
              onChanged: (bool value) {
                gameState.toggleSound(); // Переключаем звук

                // Если выключили - останавливаем музыку, если включили - запускаем
                if (!value) {
                  AudioManager.stopMusic();
                } else {
                  AudioManager.playBackgroundMusic();
                }
              },
              activeColor: Colors.green,
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Закрыть", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required String imagePath, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 320,
          height: 85,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
            errorBuilder: (context, e, s) => Container(
              decoration: BoxDecoration(
                color: Colors.brown.shade800,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white54, width: 3),
              ),
              child: const Center(
                child: Icon(Icons.settings, color: Colors.white, size: 40),
              ),
            ),
          ),
        ),
      ),
    );
  }
}