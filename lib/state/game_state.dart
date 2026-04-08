import 'package:flutter/material.dart';

class GameState extends ChangeNotifier {
  double hp = 1.0;
  double hunger = 1.0;
  int selectedSlot = 0;
  int stone = 0;

  void selectSlot(int index) {
    selectedSlot = index;
    notifyListeners();
  }

  void addStone() {
    stone++;
    print("Камень собран! Всего: $stone");
    notifyListeners();
  }

  void saveGame() {
    print("Система: Состояние HP ($hp) и камней ($stone) сохранено!");
    notifyListeners();
  }
}