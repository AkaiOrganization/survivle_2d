import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/game_core.dart';
import 'package:provider/provider.dart';
import 'state/game_state.dart';
import 'ui/hud.dart';
import 'ui/main_menu.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainMenu(),
      ),
    ),
  );
}

class MainGamePage extends StatelessWidget {
  const MainGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: MySurvivalGame()),
          const Positioned(top: 40, left: 20, child: SurvivalHUD()),
          Positioned(
            bottom: 30,
            left: 20,
            child: FloatingActionButton(
              onPressed: () => context.read<GameState>().addStone(),
              child: const Icon(Icons.handyman),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}