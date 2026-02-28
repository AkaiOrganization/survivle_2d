import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameState extends ChangeNotifier {
  int stone = 10;
  int iron = 5;
  int gold = 3;
  double hp = 0.8;
  double hunger = 0.6;

  void addStone() {
    stone++;
    notifyListeners();
  }

  void craftAxe() {
    if (stone >= 5) {
      stone -= 5;
      iron += 1;
      notifyListeners();
    }
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: GameScaffold(),
      ),
    ),
  );
}

class GameScaffold extends StatelessWidget {
  const GameScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: MySurvivalGame()),

          Positioned(
            top: 40,
            left: 20,
            child: Consumer<GameState>(
              builder: (context, state, _) => Container(
                padding: const EdgeInsets.all(10),
                color: Colors.black54,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatBar("HP", Colors.red, state.hp),
                    const SizedBox(height: 5),
                    _buildStatBar("Hunger", Colors.orange, state.hunger),
                    const SizedBox(height: 10),
                    Text(
                      "Stone: ${state.stone}  Iron: ${state.iron}  Gold: ${state.gold}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.grey[800],
              onPressed: () => context.read<GameState>().addStone(),
              child: const Icon(Icons.handyman, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.brown[700],
              onPressed: () => _showCraftMenu(context),
              child: const Icon(Icons.build, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, Color color, double value) {
    return Row(
      children: [
        SizedBox(width: 50, child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10))),
        Container(
          width: 120,
          height: 12,
          decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1)),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.transparent,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showCraftMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.brown[100],
        title: const Text("Crafting Menu"),
        content: Consumer<GameState>(
          builder: (context, state, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Craft Iron Axe"),
                subtitle: const Text("Cost: 5 Stone"),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                  onPressed: state.stone >= 5 ? () => state.craftAxe() : null,
                  child: const Text("Craft"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MySurvivalGame extends FlameGame {
  late PositionComponent player;
  late JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    world.add(RectangleComponent(
      size: Vector2(2000, 2000),
      paint: Paint()..color = const Color(0xff2d5a27),
    ));

    final knobPaint = Paint()..color = Colors.white.withOpacity(0.5);
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.3);

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 25, paint: knobPaint),
      background: CircleComponent(radius: 50, paint: backgroundPaint),
      position: Vector2(80, size.y - 80),
      priority: 10,
    );

    player = RectangleComponent(
      size: Vector2(40, 40),
      paint: Paint()..color = Colors.blue,
      position: Vector2(100, 100),
      anchor: Anchor.center,
    );

    world.add(player);

    camera.viewport.add(joystick);

    camera.follow(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!joystick.delta.isZero()) {
      player.position.add(joystick.relativeDelta * 500 * dt);
    }
  }
}