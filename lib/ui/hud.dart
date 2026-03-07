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
        // Убираем черный фон, чтобы не мешал пиксельному бару под ним
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Здесь был код полосок HP и Hunger — мы его убрали,
            // потому что теперь они рисуются через Flame (HealthBar)

            // Оставляем только ресурсы
            const SizedBox(height: 40), // Отступ сверху, чтобы текст не наложился на полоску HP
            Text(
              "Stone: ${state.stone}  Iron: ${state.iron}  Gold: ${state.gold}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}