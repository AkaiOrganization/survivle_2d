import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state.dart';

class SurvivalHUD extends StatelessWidget {
  const SurvivalHUD({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatBar('assets/images/2hp.png', Colors.redAccent, state.hp),
            const SizedBox(height: 8),
            _buildStatBar('assets/images/Hunger.png', Colors.orangeAccent, state.hunger),

            const SizedBox(height: 20),

            Row(
              children: [
                _buildResourceChip('assets/images/stone_item.png', state.getResourceCount(ItemType.stone_material).toString(), Colors.grey),
                const SizedBox(width: 10),
                _buildResourceChip('assets/images/wood_item.png', "0", Colors.brown),
                const SizedBox(width: 10),
                _buildResourceChip('assets/images/berry_item.png', "5", Colors.redAccent),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatBar(String imagePath, Color color, double value) {
    return Row(
      children: [
        Image.asset(imagePath, width: 24, height: 24, errorBuilder: (context, error, stack) => const Icon(Icons.error, color: Colors.white, size: 24)),
        const SizedBox(width: 8),
        Stack(
          children: [
            Container(
              width: 150,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Colors.white12),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 150 * value.clamp(0.0, 1.0),
              height: 14,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResourceChip(String imagePath, String count, Color themeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imagePath, width: 20, height: 20, errorBuilder: (context, error, stack) => const Icon(Icons.help_outline, color: Colors.white, size: 20)),
          const SizedBox(width: 6),
          Text(
            count,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}