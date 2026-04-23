import 'dart:convert'; // Для JSON
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Для хранения

enum ItemType { none, axe, pickaxe, sword, shears, wood, stone_material }

class GameState extends ChangeNotifier {
  double _hp = 100.0;
  double _hunger = 100.0;
  int _stone = 0;
  int _selectedSlot = 0;
  bool _isSoundEnabled = true;

  final Map<int, ItemType> _inventory = {
    0: ItemType.axe,
    1: ItemType.pickaxe,
    2: ItemType.sword,
    3: ItemType.shears,
    4: ItemType.none,
  };

  Map<ItemType, int> _inventoryCount = {
    ItemType.wood: 0,
    ItemType.stone_material: 0,
  };

  final Map<ItemType, Map<ItemType, int>> recipes = {
    ItemType.axe: {ItemType.wood: 3, ItemType.stone_material: 2},
    ItemType.pickaxe: {ItemType.wood: 2, ItemType.stone_material: 3},
    ItemType.sword: {ItemType.wood: 1, ItemType.stone_material: 4},
  };

  // --- Геттеры ---
  double get hp => _hp;
  double get hunger => _hunger;
  int get stone => _stone;
  int get selectedSlot => _selectedSlot;
  bool get isSoundEnabled => _isSoundEnabled;

  // --- Методы работы с данными ---
  ItemType getItemInSlot(int index) => _inventory[index] ?? ItemType.none;
  int getResourceCount(ItemType item) => _inventoryCount[item] ?? 0;

  void addMaterial(ItemType material) {
    _inventoryCount[material] = (_inventoryCount[material] ?? 0) + 1;
    notifyListeners();
  }

  // --- СОХРАНЕНИЕ ---
  Future<void> saveGame() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Превращаем Map с Enum в Map с String для JSON
    final inventoryData = _inventoryCount.map((key, value) => MapEntry(key.name, value));

    // 2. Создаем структуру данных
    Map<String, dynamic> saveData = {
      'hp': _hp,
      'hunger': _hunger,
      'stone': _stone,
      'selectedSlot': _selectedSlot,
      'isSoundEnabled': _isSoundEnabled,
      'inventoryCount': inventoryData,
    };

    // 3. Кодируем в строку и сохраняем
    await prefs.setString('save_data', jsonEncode(saveData));
    debugPrint("Игра сохранена: $saveData");
  }

  // --- ЗАГРУЗКА ---
  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('save_data');

    if (jsonString != null) {
      Map<String, dynamic> data = jsonDecode(jsonString);

      _hp = data['hp'];
      _hunger = data['hunger'];
      _stone = data['stone'];
      _selectedSlot = data['selectedSlot'];
      _isSoundEnabled = data['isSoundEnabled'];

      Map<String, dynamic> invMap = data['inventoryCount'];
      invMap.forEach((key, value) {
        ItemType type = ItemType.values.byName(key);
        _inventoryCount[type] = value;
      });

      notifyListeners();
      debugPrint("Игра загружена!");
    }
  }

  bool canCraft(ItemType item) {
    final recipe = recipes[item];
    if (recipe == null) return false;
    for (var entry in recipe.entries) {
      if ((_inventoryCount[entry.key] ?? 0) < entry.value) return false;
    }
    return true;
  }

  void craft(ItemType item) {
    if (!canCraft(item)) return;
    final recipe = recipes[item]!;
    for (var entry in recipe.entries) {
      _inventoryCount[entry.key] = _inventoryCount[entry.key]! - entry.value;
    }
    notifyListeners();
  }

  void toggleSound() { _isSoundEnabled = !_isSoundEnabled; notifyListeners(); }
  void selectSlot(int index) { _selectedSlot = index; notifyListeners(); }
  void updateStats(double newHp, double newHunger) { _hp = newHp; _hunger = newHunger; notifyListeners(); }
}