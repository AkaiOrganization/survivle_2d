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
      body: Stack(
        children: [
          GameWidget(
            game: MySurvivalGame(),
          ),

          const Positioned(
              top: 40,
              left: 20,
              child: SurvivalHUD()
          ),

          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

        ],
      ),
    );
  }
}