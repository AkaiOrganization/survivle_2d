import 'package:flutter/material.dart';

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