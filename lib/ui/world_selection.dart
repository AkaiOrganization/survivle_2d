import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_scaffold.dart';

class WorldSelectionScreen extends StatefulWidget {
  const WorldSelectionScreen({super.key});

  @override
  State<WorldSelectionScreen> createState() => _WorldSelectionScreenState();
}

class _WorldSelectionScreenState extends State<WorldSelectionScreen> {
  List<String> worlds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorlds();
  }

  Future<void> _loadWorlds() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      worlds = prefs.getStringList('saved_worlds') ?? [];
      isLoading = false;
    });
  }

  Future<void> _saveWorlds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_worlds', worlds);
  }

  void _createNewWorld() async {
    setState(() {
      worlds.add("Мир #${worlds.length + 1}");
    });
    await _saveWorlds();
  }

  void _deleteWorld(int index) async {
    setState(() {
      worlds.removeAt(index);
    });
    await _saveWorlds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/gui/bg_menu.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, e, s) => Container(color: const Color(0xFF1A1A1A)),
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.5))),

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
                  ),
                ),

                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                      : worlds.isEmpty
                      ? const Center(child: Text("ПУСТО", style: TextStyle(color: Colors.white24)))
                      : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: worlds.length,
                    itemBuilder: (context, index) => _buildWorldCard(index),
                  ),
                ),

                _buildCreateButton(),
                const SizedBox(height: 30),
              ],
            ),
          ),

          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF543224).withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        leading: const Icon(Icons.public, color: Colors.green, size: 40),
        title: Text(
          worlds[index],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.green, size: 30),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScaffold())),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _deleteWorld(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: _createNewWorld,
      child: Container(
        width: 280,
        height: 60,
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/create1.png',
          fit: BoxFit.fill,
          filterQuality: FilterQuality.none,
          errorBuilder: (context, error, stackTrace) =>
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text("CREATE", style: TextStyle(color: Colors.white)),
                ),
              ),
        ),
      ),
    );
  }
}