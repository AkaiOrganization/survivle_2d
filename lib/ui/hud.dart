import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state.dart';

class SurvivalHUD extends StatelessWidget {
  const SurvivalHUD({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, _) => Container(
        padding: const EdgeInsets.all(10),
        color: Colors.black54,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _statBar("HP", Colors.red, state.hp),
            const SizedBox(height: 5),
            _statBar("Hunger", Colors.orange, state.hunger),
            const SizedBox(height: 10),
            Text(
              "Stone: ${state.stone}  Iron: ${state.iron}  Gold: ${state.gold}",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBar(String label, Color color, double value) {
    return Row(
      children: [
        SizedBox(width: 50, child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10))),
        Container(
          width: 120,
          height: 12,
          decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1)),
          child: LinearProgressIndicator(value: value, color: color, backgroundColor: Colors.transparent),
        ),
      ],
    );
  }
}