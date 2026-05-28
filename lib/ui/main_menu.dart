import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flame_audio/flame_audio.dart';
import '../utils/audio_manager.dart';
import '../state/game_state.dart';
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
    _startBackgroundMusic();
  }

  void _startBackgroundMusic() {
    final gameState = context.read<GameState>();
    if (gameState.isMusicEnabled) {
      try {
        AudioManager.playBackgroundMusic();
      } catch (e) {
        debugPrint("Music failed to start: $e");
      }
    }
  }

  void _playClick() {
    final isSfxOn = context.read<GameState>().isSfxEnabled;
    if (isSfxOn) {
      try {
        FlameAudio.play('sfx/click.mp3');
      } catch (e) {
        debugPrint("Click SFX not found: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Если музыка заблокирована системой, она включится при первом тапе по экрану
          if (context.read<GameState>().isMusicEnabled) {
            AudioManager.playBackgroundMusic();
          }
        },
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/menu2.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
                errorBuilder: (context, e, s) => Container(color: Colors.black),
              ),
            ),

            // Dark overlay
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'SURVIVAL 2D',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'monospace',
                      letterSpacing: 6,
                      shadows: [
                        Shadow(blurRadius: 15, color: Colors.black, offset: Offset(4, 4))
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  // PLAY BUTTON
                  _buildMenuButton(
                    context,
                    imagePath: 'assets/images/play.png',
                    fallbackText: "PLAY",
                    iconFallback: Icons.play_arrow,
                    onTap: () {
                      _playClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WorldSelectionScreen()),
                      );
                    },
                  ),

                  // SETTINGS BUTTON
                  _buildMenuButton(
                    context,
                    imagePath: 'assets/images/settings.png',
                    fallbackText: "SETTINGS",
                    iconFallback: Icons.settings,
                    onTap: () {
                      _playClick();
                      _showSettings(context);
                    },
                  ),

                  // EXIT BUTTON
                  _buildMenuButton(
                    context,
                    imagePath: 'assets/images/exit.png',
                    fallbackText: "EXIT",
                    iconFallback: Icons.exit_to_app,
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

  // --- АНГЛИЙСКОЕ ОКНО НАСТРОЕК (МЕДИА-РАЗДЕЛЫ) ---
  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3A2518),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text(
            "SETTINGS",
            style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 2)
        ),
        content: Consumer<GameState>(
          builder: (context, gameState, child) {
            return SizedBox(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. ПУНК Т: ФОНОВАЯ МУЗЫКА
                  SwitchListTile(
                    title: const Text("Music", style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 15)),
                    subtitle: const Text("Background melodies", style: TextStyle(color: Colors.white38, fontFamily: 'monospace', fontSize: 11)),
                    value: gameState.isMusicEnabled,
                    activeColor: Colors.amber,
                    onChanged: (bool value) {
                      gameState.toggleMusic();
                      if (!value) {
                        AudioManager.stopMusic();
                      } else {
                        AudioManager.playBackgroundMusic();
                      }
                    },
                  ),
                  const Divider(color: Colors.white12),
                  // 2. ПУНКТ: ЗВУКОВЫЕ ЭФФЕКТЫ (SFX)
                  SwitchListTile(
                    title: const Text("Sound Effects", style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 15)),
                    subtitle: const Text("Actions, hits and clicks", style: TextStyle(color: Colors.white38, fontFamily: 'monospace', fontSize: 11)),
                    value: gameState.isSfxEnabled,
                    activeColor: Colors.amber,
                    onChanged: (bool value) {
                      gameState.toggleSfx();
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _playClick();
              Navigator.pop(context);
            },
            child: const Text("CLOSE", style: TextStyle(color: Colors.amber, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Адаптивные мобильные кнопки
  Widget _buildMenuButton(BuildContext context, {
    required String imagePath,
    required String fallbackText,
    required IconData iconFallback,
    required VoidCallback onTap
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 240,
          height: 58,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
            errorBuilder: (context, e, s) => Container(
              decoration: BoxDecoration(
                color: const Color(0xFF543224),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(iconFallback, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    fallbackText,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 16),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}