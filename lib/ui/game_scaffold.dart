import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_core.dart';
import '../state/game_state.dart';

class GameScaffold extends StatefulWidget {
  const GameScaffold({super.key});

  @override
  State<GameScaffold> createState() => _GameScaffoldState();
}

class _GameScaffoldState extends State<GameScaffold> {
  late final MySurvivalGame _game;

  @override
  void initState() {
    super.initState();
    _game = MySurvivalGame();
  }

  void _showPauseMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF543224),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("ПАУЗА", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace', decoration: TextDecoration.none)),
                const SizedBox(height: 20),
                _pauseButton("ПРОДОЛЖИТЬ", Colors.green, () => Navigator.pop(context)),
                _pauseButton("СОХРАНИТЬ", Colors.blueGrey, () => print("Saved")),
                _pauseButton("ВЫЙТИ", Colors.redAccent, () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pauseButton(String text, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(double.infinity, 45)),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GameWidget(game: _game),

          Consumer<GameState>(
            builder: (context, state, child) {
              return Stack(
                children: [
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.pause_circle_filled, size: 45, color: Colors.white70),
                      onPressed: () => _showPauseMenu(context),
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 340,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatBar("HP", state.hp, Colors.redAccent, Icons.favorite),
                                _buildStatBar("FOOD", state.hunger, Colors.orangeAccent, Icons.restaurant, isRight: true),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          _buildHotbarUI(state),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHotbarUI(GameState state) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF543224),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (index) {
            final isSelected = state.selectedSlot == index;
            return GestureDetector(
              onTap: () => state.selectSlot(index),
              child: _slotSquare(
                content: Text("${index + 1}", style: TextStyle(color: isSelected ? Colors.white : Colors.white12, fontWeight: FontWeight.bold)),
                isSelected: isSelected,
              ),
            );
          }),

          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => print("Открываем инвентарь..."),
            child: _slotSquare(
              content: const Icon(Icons.backpack, color: Colors.white70, size: 28),
              isSelected: false,
              isSpecial: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _slotSquare({required Widget content, required bool isSelected, bool isSpecial = false}) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF8B5E3C) : (isSpecial ? Colors.black26 : const Color(0xFF3A2518)),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected ? const Color(0xFFFFD700) : Colors.black45,
          width: isSelected ? 4 : 2,
        ),
      ),
      child: Center(child: content),
    );
  }

  Widget _buildStatBar(String label, double value, Color color, IconData icon, {bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isRight) Icon(icon, color: color, size: 12),
            Text(" $label", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            if (isRight) Icon(icon, color: color, size: 12),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          width: 130,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey.shade800, width: 1.5),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(margin: const EdgeInsets.all(1), color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}