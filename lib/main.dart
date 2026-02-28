import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';
import 'state/game_state.dart';
import 'game/game_core.dart';
import 'ui/hud.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainGamePage(),
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
        ],
      ),
    );
  }
}