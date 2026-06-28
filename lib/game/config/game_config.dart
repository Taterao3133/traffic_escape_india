import 'package:flutter/material.dart';

class GameConfig {
  // ----------------------------
  // Screen
  // ----------------------------

  static const double roadWidth = 600;

  // ----------------------------
  // Player
  // ----------------------------

  static const Size playerSize =
      Size(160, 100);

  static const double playerBottomPadding = 250;

  static const double laneChangeDuration = 0.18;

  // ----------------------------
  // Enemy
  // ----------------------------

  static const Size enemySize =
      Size(160, 100);

  static const double enemySpeed = 400;

  static const int enemyCount = 5;

  static const double enemySpawnGap = 800;

}