import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Импортируем main.dart, чтобы был доступен класс MainGamePage

class WorldSelectionScreen extends StatefulWidget {
  const WorldSelectionScreen({super.key});

  @override
  State<WorldSelectionScreen> createState() => _WorldSelectionScreenState();
}

class _WorldSelectionScreenState extends State<WorldSelectionScreen> {
  List<String> worlds = [];
  bool isLoading = true;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWorlds();
  }

  // Очищаем контроллер при уничтожении виджета для предотвращения утечек памяти
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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

  // Окно для ввода кастомного названия нового мира
  void _showCreateWorldDialog() {
    _nameController.text = "Мир #${worlds.length + 1}";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF543224),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
            "СОЗДАТЬ МИР",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace')
        ),
        content: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Название мира",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ОТМЕНА", style: TextStyle(color: Colors.white70, fontFamily: 'monospace')),
          ),
          TextButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                setState(() {
                  worlds.add(_nameController.text.trim());
                });
                _saveWorlds();
              }
              Navigator.pop(context);
            },
            child: const Text("СОЗДАТЬ", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          ),
        ],
      ),
    );
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
          // Задний фон
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
                      ? const Center(
                    child: Text(
                        "НЕТ СОХРАНЕННЫХ МИРОВ",
                        style: TextStyle(color: Colors.white24, fontFamily: 'monospace')
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: worlds.length,
                    itemBuilder: (context, index) => _buildWorldCard(index),
                  ),
                ),

                // Кнопка создания мира (адаптированная по высоте под телефоны)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5E3C),
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: Colors.black, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _showCreateWorldDialog,
                    child: const Text(
                      "СОЗДАТЬ НОВЫЙ МИР",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Кнопка «Назад» в верхнем левом углу экрана
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

  // Компактный виджет карточки мира
  Widget _buildWorldCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF543224).withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: const Icon(Icons.public, color: Colors.green, size: 35),
        title: Text(
          worlds[index],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 16),
        ),
        subtitle: const Text(
          "Режим: Выживание",
          style: TextStyle(color: Colors.white60, fontSize: 11, fontFamily: 'monospace'),
        ),
        // Переход на страницу игры, прописанную в твоем main.dart
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainGamePage()),
          );
        },
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 24),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF3A2518),
                title: const Text("Удалить мир?", style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
                content: Text("Вы хотите удалить ${worlds[index]}?", style: const TextStyle(color: Colors.white70, fontFamily: 'monospace')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("ОТМЕНА", style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
                  ),
                  TextButton(
                    onPressed: () {
                      _deleteWorld(index);
                      Navigator.pop(context);
                    },
                    child: const Text("УДАЛИТЬ", style: TextStyle(color: Colors.redAccent, fontFamily: 'monospace')),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}