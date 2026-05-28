import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ItemType { none, axe, pickaxe, sword, shears, wood, stone_material }

class GameState extends ChangeNotifier {
  // --- Состояние игры (Баланс переведён на 20 HP) ---
  double _hp = 20.0;
  final double _maxHp = 20.0;

  double _hunger = 100.0;
  final double _maxHunger = 100.0;

  double _time = 12.0;
  int _selectedSlot = 0;

  // --- Настройки аудио (Раздельные SFX и Music) ---
  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;

  // --- Внутренние таймеры для точной регенерации и урона ---
  double _damageTimer = 0.0;
  double _healTimer = 0.0;

  // --- Хотбар и Инвентарь ---
  final Map<int, ItemType> _inventory = {
    0: ItemType.axe,
    1: ItemType.pickaxe,
    2: ItemType.sword,
    3: ItemType.shears,
    4: ItemType.none,
  };

  final Map<ItemType, int> _inventoryCount = {
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
  double get maxHp => _maxHp;
  double get hunger => _hunger;
  double get maxHunger => _maxHunger;
  double get time => _time;
  int get selectedSlot => _selectedSlot;

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;

  // --- ЛОГИКА ВЫЖИВАНИЯ (Game Loop) ---
  void updateGameLoop(double dt) {
    // 1. Движение времени с цикличным сбросом через % 24.0
    _time = (_time + dt * 0.05) % 24.0;
    if (_time < 0.0 || _time >= 24.0) {
      _time = 0.0;
    }

    // 2. Трата голода: 1 единица за каждые 1.5 секунды
    if (_hunger > 0) {
      _hunger = (_hunger - dt * (1.0 / 1.5)).clamp(0.0, _maxHunger);
    }

    // 3. Урон от голода: -2 HP каждые 2 секунды, если голод на нуле
    if (_hunger <= 0) {
      _damageTimer += dt;
      if (_damageTimer >= 2.0) {
        _hp = (_hp - 2.0).clamp(0.0, _maxHp);
        _damageTimer = 0.0;
      }
    } else {
      _damageTimer = 0.0;
    }

    // 4. Регенерация здоровья: +1 HP каждые 3 секунды, если сытость >= 80%
    if (_hunger >= 80.0 && _hp < _maxHp && _hp > 0) {
      _healTimer += dt;
      if (_healTimer >= 3.0) {
        _hp = (_hp + 1.0).clamp(0.0, _maxHp);
        _healTimer = 0.0;
      }
    } else {
      _healTimer = 0.0;
    }

    notifyListeners();
  }

  // --- Методы для выживания и восстановления ---
  void eat(double amount) {
    if (_hp > 0) {
      _hunger = (_hunger + amount).clamp(0.0, _maxHunger);
      notifyListeners();
    }
  }

  void heal(double amount) {
    if (_hp > 0) {
      _hp = (_hp + amount).clamp(0.0, _maxHp);
      notifyListeners();
    }
  }

  void takeDamage(double amount) {
    _hp = (_hp - amount).clamp(0.0, _maxHp);
    notifyListeners();
  }

  /// Метод полного сброса параметров при респавне после смерти
  void resetSurvivalState() {
    _hp = _maxHp;
    _hunger = _maxHunger;
    _damageTimer = 0.0;
    _healTimer = 0.0;
    notifyListeners();
  }

  // --- Управление инвентарем ---
  ItemType getItemInSlot(int index) => _inventory[index] ?? ItemType.none;
  int getResourceCount(ItemType item) => _inventoryCount[item] ?? 0;

  /// ИСПРАВЛЕНО: Добавление материалов теперь увеличивает счетчик именно в твоей карте _inventoryCount
  void addMaterial(ItemType material) {
    _inventoryCount[material] = (_inventoryCount[material] ?? 0) + 1;
    notifyListeners();
  }

  void selectSlot(int index) {
    _selectedSlot = index;
    notifyListeners();
  }

  // --- Управление аудио-переключателями ---
  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;
    notifyListeners();
    saveGame();
  }

  void toggleSfx() {
    _isSfxEnabled = !_isSfxEnabled;
    notifyListeners();
    saveGame();
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

  // --- БЕЗОПАСНОЕ СОХРАНЕНИЕ ---
  Future<void> saveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final invCountData = _inventoryCount.map((k, v) => MapEntry(k.name, v));

      // Переводим индексы хотбара int в String, так как ключи JSON должны быть строками
      final hotbarData = _inventory.map((k, v) => MapEntry(k.toString(), v.name));

      Map<String, dynamic> saveData = {
        'hp': _hp,
        'hunger': _hunger,
        'time': _time,
        'isMusicEnabled': _isMusicEnabled,
        'isSfxEnabled': _isSfxEnabled,
        'inventoryCount': invCountData,
        'hotbar': hotbarData,
      };

      await prefs.setString('save_data', jsonEncode(saveData));
    } catch (e) {
      debugPrint("Error saving game data: $e");
    }
  }

  // --- НАДЕЖНАЯ ЗАГРУЗКА ---
  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('save_data');

    if (jsonString != null) {
      try {
        Map<String, dynamic> data = jsonDecode(jsonString);

        _hp = (data['hp'] ?? _maxHp).toDouble().clamp(0.0, _maxHp);
        _hunger = (data['hunger'] ?? _maxHunger).toDouble().clamp(0.0, _maxHunger);
        _time = ((data['time'] ?? 12.0).toDouble()) % 24.0;

        _isMusicEnabled = data['isMusicEnabled'] ?? true;
        _isSfxEnabled = data['isSfxEnabled'] ?? true;

        // Восстановление ресурсов
        if (data['inventoryCount'] != null) {
          Map<String, dynamic> invMap = data['inventoryCount'];
          invMap.forEach((k, v) {
            try {
              _inventoryCount[ItemType.values.byName(k)] = v as int;
            } catch (_) {}
          });
        }

        // Восстановление хотбара
        if (data['hotbar'] != null) {
          Map<String, dynamic> hotbarMap = data['hotbar'];
          hotbarMap.forEach((k, v) {
            try {
              int slotIndex = int.parse(k);
              _inventory[slotIndex] = ItemType.values.byName(v);
            } catch (_) {}
          });
        }

        notifyListeners();
      } catch (e) {
        debugPrint("Error parsing game state data inside loadGame(): $e");
      }
    }
  }
}