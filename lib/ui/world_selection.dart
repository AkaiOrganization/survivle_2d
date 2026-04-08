import 'package:flutter/material.dart';
import 'game_scaffold.dart';

class WorldSelectionScreen extends StatefulWidget {
  const WorldSelectionScreen({super.key});

  @override
  State<WorldSelectionScreen> createState() => _WorldSelectionScreenState();
}

class _WorldSelectionScreenState extends State<WorldSelectionScreen> {
  List<String> worlds = ["My Survival World", "Test Map"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/gui/main_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, e, s) => Container(color: const Color(0xFF1A1A1A)),
            ),
          ),

          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "ВЫБОР МИРА",
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    shadows: [Shadow(color: Colors.black, offset: Offset(2, 2))],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    itemCount: worlds.length,
                    itemBuilder: (context, index) => _buildWorldCard(index),
                  ),
                ),

                _buildCreateButton(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 110,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/gui/panel_world_card.png',
              fit: BoxFit.fill,
              errorBuilder: (context, e, s) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF543224),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 3),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _guiIcon('assets/images/gui/icon_world.png', Icons.map),

                const SizedBox(width: 15),

                Expanded(
                  child: Text(
                    worlds[index],
                    style: const TextStyle(
                      color: Color(0xFF3A2518),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),

                _actionButton('assets/images/gui/btn_play.png', Colors.green, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScaffold()));
                }),

                const SizedBox(width: 8),

                _actionButton('assets/images/gui/btn_delete.png', Colors.red, () {
                  setState(() => worlds.removeAt(index));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: () {
        setState(() => worlds.add("World ${worlds.length + 1}"));
        Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScaffold()));
      },
      child: Container(
        width: 300,
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/gui/button_long_wood.png',
              fit: BoxFit.fill,
              errorBuilder: (context, e, s) => Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade800,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
            ),
            const Text(
              "СОЗДАТЬ МИР",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black, offset: Offset(1, 1))],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String path, Color fallback, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        path,
        width: 48,
        height: 48,
        errorBuilder: (context, e, s) => Container(
          width: 45, height: 45,
          decoration: BoxDecoration(color: fallback, border: Border.all(color: Colors.black, width: 2)),
          child: Icon(fallback == Colors.red ? Icons.delete : Icons.play_arrow, color: Colors.white),
        ),
      ),
    );
  }

  Widget _guiIcon(String path, IconData fallback) {
    return Image.asset(
      path,
      width: 55,
      height: 55,
      errorBuilder: (context, e, s) => Icon(fallback, color: Colors.green, size: 40),
    );
  }
}
 