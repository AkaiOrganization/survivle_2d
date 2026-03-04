import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_scaffold.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/menu2.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            ),
          ),

          Container(color: Colors.black.withOpacity(0.3)),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'SURVIVAL 2D',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black,
                        offset: Offset(4, 4),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 60),

                _menuButton(
                  context,
                  title: 'НОВАЯ ИГРА',
                  color: Colors.brown,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GameScaffold()),
                    );
                  },
                ),

                _menuButton(
                  context,
                  title: 'НАСТРОЙКИ',
                  color: Colors.blueGrey,
                  onTap: () => print('Настройки пока не готовы'),
                ),

                _menuButton(
                  context,
                  title: 'ВЫХОД',
                  color: Colors.redAccent,
                  onTap: () => SystemNavigator.pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton(BuildContext context, {
    required String title,
    required Color color,
    required VoidCallback onTap
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: color.withOpacity(0.9),
          minimumSize: const Size(260, 64),
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
        onPressed: onTap,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(offset: Offset(2, 2), color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}