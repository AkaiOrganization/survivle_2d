import 'package:flutter/material.dart';

class GameState extends ChangeNotifier {
  // Ресурсы
  int stone = 10;
  int iron = 5;
  int gold = 3;

  // Статус (используем double для Progress Bar)
  double hp = 0.8;
  double hunger = 0.6;

  // ИНВЕНТАРЬ
  int selectedSlot = 0; // Текущий выбранный слот (0-8)
  List<String> inventoryItems = List.generate(9, (index) => ""); // Имена предметов в слотах

  void selectSlot(int index) {
    selectedSlot = index;
    notifyListeners();
  }

  void addStone() {
    stone++;
    notifyListeners();
  }

  // Метод для лечения (hp от 0.0 до 1.0)
  void heal(double amount) {
    hp = (hp + amount).clamp(0.0, 1.0);
    notifyListeners();
  }

  void craftAxe() {
    if (stone >= 5) {
      stone -= 5;
      iron += 1;
      inventoryItems[0] = "Axe"; // Кладем топор в первый слот
      notifyListeners();
    }
  }
}