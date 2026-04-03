import 'package:flutter/material.dart';

class GameState extends ChangeNotifier {
  int stone = 10;
  int iron = 5;
  int gold = 3;

  double hp = 0.8;
  double hunger = 0.6;

  int selectedSlot = 0;
  List<String> inventoryItems = List.generate(5, (index) => "");

  void selectSlot(int index) {
    if (index >= 0 && index < 5) {
      selectedSlot = index;
      notifyListeners();
    }
  }

  void addStone() {
    stone++;
    notifyListeners();
  }

  void heal(double amount) {
    hp = (hp + amount).clamp(0.0, 1.0);
    notifyListeners();
  }
}