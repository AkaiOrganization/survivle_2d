import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ItemType { none, axe, pickaxe, sword, shears, wood, stone_material }

class GameState extends ChangeNotifier {
  // --- Состояние игры ---
  double _hp = 100.0;
  double _hunger = 100.0;
  double _time = 12.0;
  int _stone = 0;
  int _selectedSlot = 0;
  bool _isSoundEnabled = true;

  // --- Хотбар и Инвентарь ---
  Map<int, ItemType> _inventory = {
    0: ItemType.axe, 1: ItemType.pickaxe, 2: ItemType.sword, 3: ItemType.shears, 4: ItemType.none,
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
  double get time => _time;
  int get stone => _stone;
  int get selectedSlot => _selectedSlot;
  bool get isSoundEnabled => _isSoundEnabled;

  // --- ЛОГИКА ВЫЖИВАНИЯ (Game Loop) ---

  // Вставь этот метод в update(double dt) твоего FlameGame
  void updateGameLoop(double dt) {
    // 1. Движение времени
    _time = (_time + dt * 0.05) % 24.0;

    // 2. Постепенная трата голода (0.5 единицы в секунду)
    // Ты можешь настроить скорость траты голода здесь
    _hunger = (_hunger - dt * 0.5).clamp(0.0, 100.0);

    // 3. Урон от голода
    if (_hunger <= 0) {
      _hp = (_hp - dt * 2.0).clamp(0.0, 100.0);
    }

    notifyListeners();
  }

  // Методы для UI (например, для кнопки "Поесть")
  void eat(double amount) {
    _hunger = (_hunger + amount).clamp(0.0, 100.0);
    notifyListeners();
  }

  void takeDamage(double amount) {
    _hp = (_hp - amount).clamp(0.0, 100.0);
    notifyListeners();
  }

  // --- Управление ---
  ItemType getItemInSlot(int index) => _inventory[index] ?? ItemType.none;
  int getResourceCount(ItemType item) => _inventoryCount[item] ?? 0;

  void addMaterial(ItemType material) {
    _inventoryCount[material] = (_inventoryCount[material] ?? 0) + 1;
    notifyListeners();
  }

  void selectSlot(int index) {
    _selectedSlot = index;
    notifyListeners();
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    notifyListeners();
  }

  // --- КРАФТ ---
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

  // --- СОХРАНЕНИЕ ---
  Future<void> saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    final invCountData = _inventoryCount.map((k, v) => MapEntry(k.name, v));
    final hotbarData = _inventory.map((k, v) => MapEntry(k.toString(), v.name));

    Map<String, dynamic> saveData = {
      'hp': _hp,
      'hunger': _hunger,
      'time': _time,
      'inventoryCount': invCountData,
      'hotbar': hotbarData,
    };

    await prefs.setString('save_data', jsonEncode(saveData));
  }

  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('save_data');
    if (jsonString != null) {
      Map<String, dynamic> data = jsonDecode(jsonString);
      _hp = data['hp'];
      _hunger = data['hunger'];
      _time = data['time'];
      Map<String, dynamic> invMap = data['inventoryCount'];
      invMap.forEach((k, v) => _inventoryCount[ItemType.values.byName(k)] = v);
      notifyListeners();
    }
  }
}